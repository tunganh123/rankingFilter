//
//  ViewRecord + capture.swift
//  rankingFilter
//
//  Created by TungAnh on 8/11/24.
//

import AVFoundation
import Foundation
import LouisPod
import MBProgressHUD
import UIKit
import Vision

extension ViewRecord: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        connection.videoOrientation = .landscapeRight
        connection.isVideoMirrored = true

        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])
        if let faceDetectionRequest = faceDetectionRequest {
            try? imageRequestHandler.perform([faceDetectionRequest])
        }
    }
}

extension ViewRecord: RecorderDelegate {
    func recorderWillStartWriting() {
        print("recorderWillStartWriting")
        after(interval: 0) {
            self.isLoading(true)
        }
    }

    func recorderDidFinishWriting(videoUrl: URL, previewImageUrl: URL) {
        print("recorderDidFinishWriting")
        UISaveVideoAtPathToSavedPhotosAlbum(videoUrl.path, nil, nil, nil)
    }

    func recorderDidUpdate(recordingSeconds: TimeInterval) {
        print("recorderDidUpdate", recordingSeconds)
        if recordingSeconds >= 10 {
            cameraLayer.finishRecording()
        }
    }

    func recorderDidFail(with error: RecorderError) {
        print("recorderDidFail", error)
    }

    func recorderDidGetVideoDimensions(videoDimensions: CMVideoDimensions) {
        print("recorderDidGetVideoDimensions")
    }
}

public extension UIViewController {
    func isLoading(_ isLoading: Bool) {
        if isLoading {
            let hub = MBProgressHUD.showAdded(to: self.view, animated: true)
            //            hub.bezelView.color = .white.withAlphaComponent(0.2)
            //            hub.bezelView.style = .solidColor
            //            hub.backgroundView.backgroundColor = .red
        } else {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
}
