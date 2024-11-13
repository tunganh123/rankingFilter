//
//  ViewRecord + restWindow.swift
//  rankingFilter
//
//  Created by TungAnh on 11/11/24.
//

import Foundation
import LouisPod
import UIKit

extension ViewRecord {
    func setupButtonInSeparateWindow() {
        let screenBounds = UIScreen.main.bounds
        // Khởi tạo `UIWindow` phụ
        restWindow = UIWindow(frame: CGRect(x: 0, y: screenBounds.height - screenBounds.height / 5, width: screenBounds.width, height: screenBounds.height / 5))
        restWindow?.windowLevel = .statusBar + 1 // Đảm bảo button luôn ở trên cùng
        restWindow?.backgroundColor = .clear

        // Tạo `UIViewController` cho `buttonWindow`
        let restVC = UIViewController()
        settingRecord = SettingRecord(frame: restVC.view.bounds)
        settingRecord.clsTapRecord = { [weak self] in
            guard let self = self else {
                return
            }
            tapRecord()
        }
        settingRecord.clsToggleCamera = { [weak self] in
            guard let self = self else {
                return
            }
//            cameraLayer.configUI(position: cameraLayer.currentCameraPosition == .front ? .back : .front)

            setupFaceDetection()
            startFaceDetection() // Gọi startFaceDetection để bắt đầu nhận diện khuôn mặt
            setupButtonInSeparateWindow()
        }
        restVC.view.addSubview(settingRecord)

        restWindow?.rootViewController = restVC
        restWindow?.isHidden = false // Hiển thị `buttonWindow`
    }

    func toggleBrightness() {
//        if cameraLayer.currentDevice.position == .front {
//            // Camera trước
//            if isFlashOn {
//                // Khôi phục độ sáng ban đầu
//                UIScreen.main.brightness = originalBrightness
//            } else {
//                // Lưu độ sáng ban đầu và tăng độ sáng lên mức tối đa
//                originalBrightness = UIScreen.main.brightness
//                UIScreen.main.brightness = 1.0
//            }
//        } else {
//            // Camera Sau
//            if cameraLayer.currentDevice.hasTorch {
//                do {
//                    try cameraLayer.currentDevice.lockForConfiguration()
//                    cameraLayer.currentDevice.torchMode = isFlashOn ? .off : .on
//                    cameraLayer.currentDevice.unlockForConfiguration()
//                } catch {
//                    print("Không thể điều chỉnh đèn flash: \(error)")
//                }
//            }
//        }
    }

    func tapRecord() {
        if !isStartRecord {
            // Ban đầu
            isStartRecord = true
            settingRecord.btnRecord.setBackgroundImage(UIImage(named: "ic_record_pause"), for: .normal)
            // Bắt đầu record
            cameraLayer.startRecording { result in
                after(interval: 0) {
                    switch result {
                    case .success():
                        print("Play recording")
                    case .failure(let err):
                        print("err", err)
                    }
                }
            }
        } else {
            isPauseRecord.toggle()
            if isPauseRecord {
                // Tạm dừng
                cameraLayer.pauseRecording()
                print("Pause recording")
            } else {
                // Resume
                cameraLayer.startRecording { result in
                    after(interval: 0) {
                        switch result {
                        case .success():
                            print("Resume recording")
                        case .failure(let err):
                            print("err", err)
                        }
                    }
                }
            }
        }
    }
}
