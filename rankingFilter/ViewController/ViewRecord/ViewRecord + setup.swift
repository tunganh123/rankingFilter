//
//  ViewRecord + setup.swift
//  rankingFilter
//
//  Created by TungAnh on 8/11/24.
//

import AVFoundation
import Foundation
import LouisPod
import Vision

extension ViewRecord {
    func setupUI() {
        viewContent.backgroundColor = .clear
        after(interval: 0.1) { [weak self] in
            guard let self = self else {
                return
            }
            setupRecord()

            setupFaceDetection()
            startFaceDetection() // Gọi startFaceDetection để bắt đầu nhận diện khuôn mặt
            setupButtonInSeparateWindow()
        }
    }

    func setupRecord() {
        cameraLayer = CameraView(frame: cameraView.bounds)
        cameraView.addSubview(cameraLayer)
    }

    // Thiết lập yêu cầu nhận diện khuôn mặt
    func setupFaceDetection() {
        frameDetection = cameraLayer.videoPreviewLayer.frame
        let faceDetectionRequest = VNDetectFaceRectanglesRequest(completionHandler: { [weak self] request, error in
            if let error = error {
                print("Error detecting faces: \(error.localizedDescription)")
                return
            }

            if let results = request.results as? [VNFaceObservation] {
                // Kiểm tra và xử lý kết quả nhận diện khuôn mặt
                self?.handleFaceDetection(results)
            }
        })
        self.faceDetectionRequest = faceDetectionRequest
    }

    // Bắt đầu nhận diện khuôn mặt
    func startFaceDetection() {
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .userInitiated))

        cameraLayer.captureSession.addOutput(videoDataOutput)
    }

    // Xử lý kết quả nhận diện khuôn mặt
    func handleFaceDetection(_ faceObservations: [VNFaceObservation]) {
        guard let face = faceObservations.first else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }
                currentFaceView = nil
                faceViewref?.removeFromSuperview()
            }
            return
        }

        let smoothedRect = drawFaceBoundingBox(face: face)
        previousFaceRect = smoothedRect

        let currentRoll = CGFloat(face.roll?.floatValue ?? 0.0)
        let interpolatedRoll = interpolate(from: previousRoll, to: currentRoll, factor: 0.4)
        previousRoll = interpolatedRoll
        // Cập nhật vị trí của nút dựa trên vị trí của khuôn mặt
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.drawFaceBoundingBox(roll: -interpolatedRoll, boundingBox: smoothedRect)
        }
    }

    func drawFaceBoundingBox(roll: CGFloat, boundingBox: CGRect) {
        let scale: CGFloat = 0.9
        let adjustedOrigin = CGPoint(
            x: boundingBox.minX + boundingBox.width * (1 - scale) / 2,
            y: boundingBox.minY + boundingBox.height * (1 - scale) / 2
        )
        let adjustedSize = CGSize(width: boundingBox.width * scale, height: boundingBox.height * scale)

        if currentFaceView == nil {
            // Tạo `currentFaceView` nếu chưa có
            faceViewref = faceView(frame: CGRect(origin: adjustedOrigin, size: adjustedSize))
            faceViewref.backgroundColor = .clear
            faceViewref.bindImg()
            view.addSubview(faceViewref)
            currentFaceView = faceViewref
        } else {
            // Cập nhật `frame` nếu `currentFaceView` đã tồn tại
            currentFaceView?.frame = CGRect(origin: adjustedOrigin, size: adjustedSize)
        }

        // Tạo `transform` với hiệu ứng phối cảnh và góc quay
        var transform = CATransform3DIdentity
        transform.m34 = -1.0 / 500.0 // Tạo hiệu ứng phối cảnh
        transform = CATransform3DRotate(transform, roll, 0, 0, 1) // Z-axis (nghiêng, đảo ngược roll)
        transform = CATransform3DTranslate(transform, 0, -boundingBox.height, 0)
        currentFaceView?.layer.transform = transform
    }
}
