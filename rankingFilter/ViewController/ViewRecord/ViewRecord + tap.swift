//
//  ViewRecord + tap.swift
//  rankingFilter
//
//  Created by TungAnh on 8/11/24.
//

import Foundation
import LouisPod
import UIKit

extension ViewRecord {
    @IBAction func clickFlash(_ sender: Any) {
        //
        print("tap Flash")
        cameraLayer.mergeVideo()
        //  isStartRecord = true

//        isFlashOn.toggle()
//        toggleBrightness()
    }

    @IBAction func clickTimer(_ sender: Any) {
        print("tap Flash")
    }

    @IBAction func clickMusic(_ sender: Any) {
        print("tap Music")
    }

    @IBAction func btnsClick(_ sender: UIButton) {
        if !faceViewref.checkTimerRun {
            sender.isUserInteractionEnabled = false
            sender.backgroundColor = .clear
            sender.setTitle("", for: .normal)
            sender.setBackgroundImage(faceViewref.imageSellected, for: .normal)
            faceViewref.bindImg()
        }
    }
}
