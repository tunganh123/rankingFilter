import AVFoundation
import DKImagePickerController
import LouisPod
import ReplayKit
import UIKit

class CameraView: UIView {
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!

    var photoOutput: AVCapturePhotoOutput!
    var currentDevice: AVCaptureDevice!
    var videoInput: AVCaptureDeviceInput!
    var isFlash = false
    var handleFailCamera: (() -> Void)?
    var screenRecorder: RPScreenRecorder!
    var arrVideos: [AVAsset] = []
    var count = 0
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configUI()
    }

    func configUI() {
        backgroundColor = .white
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .iFrame960x540
        screenRecorder = RPScreenRecorder.shared()
        screenRecorder.isMicrophoneEnabled = true // Bật mic nếu muốn ghi lại âm thanh
        guard let rearCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            guard let parent = UIApplication.topViewController() else { return }
            parent.showToast(message: "Your Camera rear crash.")
            return
        }

        currentDevice = rearCamera
        do {
            let input = try AVCaptureDeviceInput(device: rearCamera)
            captureSession.addInput(input)
        } catch {
            after(interval: 0.2) { [weak self] in
                self?.handleFailCamera?()
            }
            return
        }

        photoOutput = AVCapturePhotoOutput()
        photoOutput.isHighResolutionCaptureEnabled = true
        captureSession.addOutput(photoOutput)

        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.frame = bounds
        layer.addSublayer(videoPreviewLayer)

        openFlash(isFlash: isFlash)
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    func startRecording() {
        screenRecorder.startRecording { error in
            if let error = error {
                print("Start recording failed with error: \(error.localizedDescription)")
            } else {
                print("Recording started successfully")
            }
        }
    }

    func stopRecording() {
        count += 1
        let screenRecorder = RPScreenRecorder.shared()
        let outputDirectory = FileManager.default.temporaryDirectory
        let outputURL = outputDirectory.appendingPathComponent("recordedVideo\(count).mov")

        // Delete existing file if necessary
        if FileManager.default.fileExists(atPath: outputURL.path) {
            do {
                try FileManager.default.removeItem(at: outputURL)
                print("Deleted old video at \(outputURL.path)")
            } catch {
                print("Failed to delete old video: \(error.localizedDescription)")
            }
        }

        screenRecorder.stopRecording(withOutput: outputURL) { error in
            if let error = error {
                print("Error stopping recording: \(error.localizedDescription)")
            } else {
                let asset = AVAsset(url: outputURL)
                let duration = asset.duration.seconds
                let trimEnd = duration - 1.5 // Trim last second

                if trimEnd > 0 {
                    let trimmedURL = outputDirectory.appendingPathComponent("trimmedVideo\(self.count).mov")
                    self.trimVideo(asset: asset, startTime: 0.0, endTime: trimEnd, outputURL: trimmedURL) { trimmedAsset in
                        if let trimmedAsset = trimmedAsset {
                            self.arrVideos.append(trimmedAsset)
                            UISaveVideoAtPathToSavedPhotosAlbum(trimmedURL.path, nil, nil, nil)
                            print("Recording finished and trimmed video saved at \(trimmedURL.path)")
                        }
                    }
                } else {
                    print("Video too short to trim")
                }
            }
        }
    }

    // Helper function to trim video
    func trimVideo(asset: AVAsset, startTime: Double, endTime: Double, outputURL: URL, completion: @escaping (AVAsset?) -> Void) {
        let start = CMTime(seconds: startTime, preferredTimescale: 600)
        let end = CMTime(seconds: endTime, preferredTimescale: 600)
        let timeRange = CMTimeRange(start: start, end: end)

        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
            print("Export session could not be created")
            completion(nil)
            return
        }

        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mov
        exportSession.timeRange = timeRange

        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                print("Video trimmed successfully")
                completion(AVAsset(url: outputURL))
            case .failed:
                print("Trimming failed: \(String(describing: exportSession.error?.localizedDescription))")
                completion(nil)
            default:
                completion(nil)
            }
        }
    }

    func mergeVideo() {
        KVVideoManager.shared.merge(arrayVideos: arrVideos) { [weak self] outputURL, error in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    print("Error:\(error.localizedDescription)")
                } else if let url = outputURL {
                    print("urlzzzzzz", url)
                    UISaveVideoAtPathToSavedPhotosAlbum(url.path, nil, nil, nil)
                }
            }
        }
    }

    func appDidEnterBackground() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }

    func appWillEnterForeground() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.captureSession.startRunning()
        }
        openFlash(isFlash: isFlash)
    }

    func openFlash(isFlash: Bool) {
        self.isFlash = isFlash
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                device.torchMode = isFlash ? .on : .off
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
}

extension CameraView: RPPreviewViewControllerDelegate {
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        previewController.dismiss(animated: true, completion: nil)
    }
}
