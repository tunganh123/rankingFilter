//
//  Recoder.swift
//  rankingFilter
//
//  Created by TungAnh on 12/11/24.
//

import Foundation

import AVFoundation
import AVKit
import LouisPod
import ReplayKit
import UIKit

protocol RecorderDelegate: AnyObject {
    func recorderWillStartWriting()
    func recorderDidFinishWriting(videoUrl: URL, previewImageUrl: URL)
    func recorderDidUpdate(recordingSeconds: TimeInterval)
    func recorderDidFail(with error: RecorderError)
    func recorderDidGetVideoDimensions(videoDimensions: CMVideoDimensions)
}

final class Recorder: NSObject, AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    weak var delegate: RecorderDelegate?
    
    private let screenRecorder = RPScreenRecorder.shared()
    
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private var captureVideoDataOutput: AVCaptureVideoDataOutput!
    private var captureAudioDataOutput: AVCaptureAudioDataOutput?
    private var assetWriter: AVAssetWriter?
    private var videoAssetWriterInput: AVAssetWriterInput?
    private var audioAssetWriterInput: AVAssetWriterInput?
    private var assetWriterInputPixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    
    private var fileName = ""
    private var videoUrl: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(fileName).mov")
    }

    private var segments: [URL] = []
    private var isRecording = false
    private var isMicrophoneOn = true
    
    private var currentVideoDimensions: CMVideoDimensions?
    private var videoWritingStartTime: CMTime?
    private var currentVideoTime = CMTime() {
        didSet {
            /// cause video was separated multi child video, then merge together,
            /// so every time begin recording, time was reset to zero
            let durations = recordedTime.reduce(.zero) { $0 + $1 }
            let totalTime = durations + recordingSeconds
            after(interval: 0) {
                self.delegate?.recorderDidUpdate(recordingSeconds: totalTime)
            }
        }
    }

    private var isUsingFrontCamera = true
    var recordedTime: [TimeInterval] = []
 
    private var recordingSeconds: TimeInterval {
        guard assetWriter != nil else { return 0 }
        let diff = currentVideoTime - (videoWritingStartTime ?? .zero)
        let seconds = CMTimeGetSeconds(diff)
        guard !(seconds.isNaN || seconds.isInfinite) else { return 0 }
        return seconds
    }
    
    init(delegate: RecorderDelegate?) {
        super.init()
        self.delegate = delegate
    }
}

// MARK: - Public Functions

extension Recorder {
    func setupSession(previewView: UIView,
                      isEnableMicrophone: Bool,
                      isUsingFrontCamera: Bool) async throws
    {
        self.isUsingFrontCamera = isUsingFrontCamera
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        do {
            // video capture
            let backCamera = getCamera(with: isUsingFrontCamera ? .front : .back)
            let videoInput = try AVCaptureDeviceInput(device: backCamera)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            }
            
            captureVideoDataOutput = AVCaptureVideoDataOutput()
            captureVideoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "recorder.video"))
            if captureSession.canAddOutput(captureVideoDataOutput) {
                captureSession.addOutput(captureVideoDataOutput)
            }
            
            // audio capture
            toggleMicrophone(isOn: isEnableMicrophone)
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        } catch {
            delegate?.recorderDidFail(with: .sessionSetupFailed(error))
        }
    }
    
    func setupVideoPreviewLayer(containerView: UIView) {
        guard videoPreviewLayer.isNil else { return }
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.frame = containerView.bounds
        containerView.layer.addSublayer(videoPreviewLayer)
    }
    
    func startRecording(completion: ((Result<Void, Error>) -> Void)?) {
        if screenRecorder.isAvailable {
            startNewRecordingSegment()
            screenRecorder.isMicrophoneEnabled = isMicrophoneOn
            screenRecorder.startCapture(handler: { [weak self] sampleBuffer, sampleBufferType, error in
                guard let self = self, self.isRecording else { return }
                if let error = error {
                    self.cancelRecording()
                    completion?(.failure(error))
                } else {
                    let isAudio = sampleBufferType == .audioMic
                    let isVideo = sampleBufferType == .video
                    let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                    if self.videoWritingStartTime.isNil {
                        self.videoWritingStartTime = timestamp
                        self.assetWriter?.startSession(atSourceTime: self.videoWritingStartTime ?? .zero)
                    }
                    if self.isMicrophoneOn, isAudio, self.audioAssetWriterInput?.isReadyForMoreMediaData == true {
                        self.audioAssetWriterInput?.append(sampleBuffer)
                    } else if isVideo, let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                        self.assetWriterInputPixelBufferAdaptor?.append(pixelBuffer, withPresentationTime: timestamp)
                        self.currentVideoTime = timestamp
                    }
                }
            }, completionHandler: { error in
                if let error {
                    self.cancelRecording()
                    completion?(.failure(error))
                } else {
                    completion?(.success(()))
                }
            })
        } else {
            //  completion?(.failure(ErrorInfo(message: "Recording is not available.")))
        }
    }
    
    func pauseRecording() {
        stopRecordingSegment(completion: nil)
    }
    
    func finishRecording() {
        //   delegate?.recorderWillStartWriting()
         
        stopRecordingSegment { [weak self] in
            guard let self = self else { return }
            self.stitchSegments { finalVideoUrl in
                if let finalVideoUrl = finalVideoUrl {
                    self.generateThumbnail(from: finalVideoUrl) { previewImageUrl in
                        DispatchQueue.main.async {
                            if let previewImageUrl = previewImageUrl {
                                self.delegate?.recorderDidFinishWriting(videoUrl: finalVideoUrl, previewImageUrl: previewImageUrl)
                            } else {
                                self.delegate?.recorderDidFail(with: .couldNotGeneratePreviewImage)
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.delegate?.recorderDidFail(with: .stitchingFailed)
                    }
                }
                self.cleanUpTempFiles()
            }
        }
    }
    
    func cancelRecording() {
        stopRecordingSegment(completion: nil)
        cleanUpTempFiles()
    }
    
    func toggleFlash(isOn: Bool) {
        let backCamera = getCamera(with: .back)
        
        if backCamera.hasTorch {
            try? backCamera.lockForConfiguration()
            if isOn {
                try? backCamera.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
            } else {
                backCamera.torchMode = .off
            }
            backCamera.unlockForConfiguration()
        }
    }
    
    func toggleMicrophone(isOn: Bool) {
        isMicrophoneOn = isOn
        
        if isOn {
            // Check if the microphone input is already added
            guard captureSession.inputs.first(where: { ($0 as? AVCaptureDeviceInput)?.device.hasMediaType(.audio) == true }).isNil else { return }
            
            // Add audio input if not already added
            if let microphone = AVCaptureDevice.default(for: .audio),
               let audioInput = try? AVCaptureDeviceInput(device: microphone),
               captureSession.canAddInput(audioInput)
            {
                captureSession.addInput(audioInput)
                
                // Add audio output
                captureAudioDataOutput = AVCaptureAudioDataOutput()
                captureAudioDataOutput?.setSampleBufferDelegate(self, queue: DispatchQueue(label: "recorder.audio"))
                if let captureAudioDataOutput = captureAudioDataOutput, captureSession.canAddOutput(captureAudioDataOutput) {
                    captureSession.addOutput(captureAudioDataOutput)
                }
            }
        } else {
            // Remove the audio input
            if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
                for input in inputs where input.device.hasMediaType(.audio) {
                    captureSession.removeInput(input)
                }
            }
            
            // Remove the audio output
            if let captureAudioDataOutput = captureAudioDataOutput {
                captureSession.removeOutput(captureAudioDataOutput)
                self.captureAudioDataOutput = nil
            }
        }
    }
    
    func toggleCamera(isUsingFrontCamera: Bool) {
        self.isUsingFrontCamera = isUsingFrontCamera
        guard let currentInput = captureSession.inputs.first(where: {
            ($0 as? AVCaptureDeviceInput)?.device.hasMediaType(.video) == true
        }) as? AVCaptureDeviceInput else { return }

        captureSession.beginConfiguration()
        captureSession.removeInput(currentInput)
        let newCamera = getCamera(with: isUsingFrontCamera ? .front : .back)
        do {
            let newInput = try AVCaptureDeviceInput(device: newCamera)
            if captureSession.canAddInput(newInput) {
                captureSession.addInput(newInput)
            }
        } catch {
            print("### toggleCamera error:", error)
        }
        captureSession.commitConfiguration()
    }
}

// MARK: - Private Functions

extension Recorder {
    func previewVideo(url: URL) {
        // Tạo AVPlayer từ URL video
        let player = AVPlayer(url: url)
        // Tạo AVPlayerViewController để hiển thị video
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        // Đưa AVPlayerViewController lên màn hình
        UIApplication.topViewController()!.present(playerViewController, animated: true) {
            // Khi video được hiển thị, tự động phát video
            player.play()
        }
    }

    private func startNewRecordingSegment() {
        fileName = UUID().uuidString
        print("videoUrl", videoUrl)

        segments.append(videoUrl)
        
        do {
            assetWriter = try AVAssetWriter(outputURL: videoUrl, fileType: .mp4)
            videoAssetWriterInput = makeAssetWriterVideoInput()
            assetWriter?.add(videoAssetWriterInput!)
            
            assetWriterInputPixelBufferAdaptor = makeAssetWriterInputPixelBufferAdaptor(with: videoAssetWriterInput!)
            
            if let captureAudioDataOutput = captureAudioDataOutput {
                let audioSettings = captureAudioDataOutput.recommendedAudioSettingsForAssetWriter(writingTo: .mov)
                audioAssetWriterInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
                audioAssetWriterInput?.expectsMediaDataInRealTime = true
                
                if assetWriter?.canAdd(audioAssetWriterInput!) == true {
                    assetWriter?.add(audioAssetWriterInput!)
                }
            }

            assetWriter?.startWriting()
            isRecording = true
        } catch {
            delegate?.recorderDidFail(with: .couldNotCreateAssetWriter(error))
        }
    }
    
    private func makeAssetWriterVideoInput() -> AVAssetWriterInput {
        let settings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.hevc,
            AVVideoWidthKey: screenSize.width,
            AVVideoHeightKey: screenSize.height,
        ]
        
        let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
        input.expectsMediaDataInRealTime = true
        return input
    }
    
    // create a pixel buffer adaptor for the asset writer; we need to obtain pixel buffers for rendering later from its pixel buffer pool
    private func makeAssetWriterInputPixelBufferAdaptor(with input: AVAssetWriterInput) -> AVAssetWriterInputPixelBufferAdaptor {
        let attributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String: screenSize.width,
            kCVPixelBufferHeightKey as String: screenSize.height,
            kCVPixelFormatOpenGLESCompatibility as String: kCFBooleanTrue!,
        ]
        return AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: input,
            sourcePixelBufferAttributes: attributes
        )
    }
    
    private func stopRecordingSegment(completion: (() -> Void)?) {
        if screenRecorder.isRecording {
            screenRecorder.stopCapture(handler: nil)
        }
        recordedTime.append(recordingSeconds)
        print("recordedTime", recordedTime)
        guard let writer = assetWriter else {
            completion?()
            return
        }
        isRecording = false
        
        writer.finishWriting {
            completion?()
        }
        assetWriter = nil
        videoAssetWriterInput = nil
        audioAssetWriterInput = nil
        assetWriterInputPixelBufferAdaptor = nil
        videoWritingStartTime = nil
    }
    
    private func cleanUpTempFiles() {
        let fileManager = FileManager.default
        for segment in segments {
            try? fileManager.removeItem(at: segment)
        }
        segments.removeAll()
        recordedTime.removeAll()
    }
    
    private func getCamera(with position: AVCaptureDevice.Position) -> AVCaptureDevice {
        return AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: position).devices.first!
    }

    private func generateThumbnail(from url: URL, completion: ((URL?) -> Void)?) {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 1, preferredTimescale: 600)
        
        DispatchQueue.global().async {
            do {
                let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                let uiImage = UIImage(cgImage: cgImage)
                if let data = uiImage.jpegData(compressionQuality: 0.8) {
                    let fileManager = FileManager.default
                    let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let thumbnailURL = documentsDirectory.appendingPathComponent(UUID().uuidString + ".jpg")
                    try data.write(to: thumbnailURL)
                    completion?(thumbnailURL)
                } else {
                    self.delegate?.recorderDidFail(with: .couldNotGeneratePreviewImage)
                    completion?(nil)
                }
            } catch {
                self.delegate?.recorderDidFail(with: .couldNotGeneratePreviewImage)
                completion?(nil)
            }
        }
    }
    
    private func stitchSegments(completion: ((URL?) -> Void)?) {
        guard !segments.isEmpty else {
            completion?(nil)
            return
        }
        
        let composition = AVMutableComposition()
        let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        var audioTrack: AVMutableCompositionTrack?
        if isMicrophoneOn, captureAudioDataOutput != nil {
            audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        }
        
        var insertTime = CMTime.zero
        for segment in segments {
            let asset = AVAsset(url: segment)
            if let videoAssetTrack = asset.tracks(withMediaType: .video).first {
                try? videoTrack?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: asset.duration), of: videoAssetTrack, at: insertTime)
            }
            if isMicrophoneOn, let audioAssetTrack = asset.tracks(withMediaType: .audio).first {
                try? audioTrack?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: asset.duration), of: audioAssetTrack, at: insertTime)
            }
            insertTime = CMTimeAdd(insertTime, asset.duration)
            UISaveVideoAtPathToSavedPhotosAlbum(segment.path, nil, nil, nil)
        }
       
        return
        
        let outputURL = createOutputURL()
        
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            delegate?.recorderDidFail(with: .exportSessionCreationFailed)
            completion?(nil)
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.exportAsynchronously {
            if exportSession.status == .completed {
                completion?(outputURL)
            } else {
                self.delegate?.recorderDidFail(with: .exportFailed(exportSession.error))
                completion?(nil)
            }
        }
    }
    
    private func createOutputURL() -> URL {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
    }
}

enum RecorderError: Error {
    case sessionSetupFailed(Error)
    case audioInputAdditionFailed
    case outputAdditionFailed
    case couldNotCreateAssetWriter(Error)
    case couldNotAddAssetWriterInput
    case couldNotGeneratePreviewImage
    case segmentInsertionFailed
    case exportSessionCreationFailed
    case exportFailed(Error?)
    case stitchingFailed

    var localizedDescription: String {
        switch self {
        case .sessionSetupFailed(let error):
            return "Session setup failed: \(error.localizedDescription)"
        case .audioInputAdditionFailed:
            return "Failed to add audio input to session"
        case .outputAdditionFailed:
            return "Failed to add output to session"
        case .couldNotCreateAssetWriter(let error):
            return "Could not create asset writer: \(error.localizedDescription)"
        case .couldNotAddAssetWriterInput:
            return "Could not add asset writer input"
        case .couldNotGeneratePreviewImage:
            return "Could not generate preview image"
        case .segmentInsertionFailed:
            return "Failed to insert segment"
        case .exportSessionCreationFailed:
            return "Failed to create export session"
        case .exportFailed(let error):
            return "Export failed: \(error?.localizedDescription ?? "Unknown error")"
        case .stitchingFailed:
            return "Failed to stitch segments"
        }
    }
}

protocol AnyOptional {
    var isNil: Bool { get }
    var isNotNil: Bool { get }
}

extension Optional: AnyOptional {
    public var isNil: Bool { self == nil }
    public var isNotNil: Bool { self != nil }
}
