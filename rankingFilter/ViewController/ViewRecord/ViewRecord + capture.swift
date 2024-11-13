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
