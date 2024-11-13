//
//  ViewRecord + funcHeplper.swift
//  rankingFilter
//
//  Created by TungAnh on 8/11/24.
//

import Foundation
import Vision

extension ViewRecord {
    func drawFaceBoundingBox(face: VNFaceObservation) -> CGRect {
        // The coordinates are normalized to the dimensions of the processed image, with the origin at the image's lower-left corner.
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -frameDetection.height)
        let scale = CGAffineTransform.identity.scaledBy(x: frameDetection.width, y: frameDetection.height)
        let faceBounds = face.boundingBox.applying(scale).applying(transform)

        // Interpolating face bounding box for smooth transitions
        let smoothedRect = CGRect(
            x: interpolate(from: previousFaceRect.origin.x, to: faceBounds.origin.x, factor: 0.2),
            y: interpolate(from: previousFaceRect.origin.y, to: faceBounds.origin.y, factor: 0.2),
            width: interpolate(from: previousFaceRect.width, to: faceBounds.width, factor: 0.2),
            height: interpolate(from: previousFaceRect.height, to: faceBounds.height, factor: 0.2)
        )
        return smoothedRect
    }

    func interpolate(from startValue: CGFloat, to endValue: CGFloat, factor: CGFloat) -> CGFloat {
        return startValue + (endValue - startValue) * factor
    }
}
