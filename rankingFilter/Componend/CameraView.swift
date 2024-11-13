import AVFoundation
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
        let screenRecorder = RPScreenRecorder.shared()
        screenRecorder.isMicrophoneEnabled = true // Bật mic nếu muốn ghi lại âm thanh

        screenRecorder.startRecording { error in
            if let error = error {
                print("Start recording failed with error: \(error.localizedDescription)")
            } else {
                print("Recording started successfully")
            }
        }
    }

    func stopRecording() {
        let screenRecorder = RPScreenRecorder.shared()
        let outputDirectory = FileManager.default.temporaryDirectory
        let outputURL = outputDirectory.appendingPathComponent("recordedVideo.mov")
        // Xóa file gốc nếu có
        if FileManager.default.fileExists(atPath: outputURL.path) {
            do {
                try FileManager.default.removeItem(at: outputURL)
                print("Đã xóa video cũ tại \(outputURL.path)")
            } catch {
                print("Không thể xóa video cũ: \(error.localizedDescription)")
            }
        }
        screenRecorder.stopRecording(withOutput: outputURL) { error in
            if let error = error {
                print("Lỗi khi dừng quay: \(error.localizedDescription)")
            } else {
                print("Quá trình quay kết thúc và video đã được lưu tại \(outputURL.path)")
                UISaveVideoAtPathToSavedPhotosAlbum(outputURL.path, nil, nil, nil)
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
