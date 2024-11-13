//
//  ViewRecord + tap.swift
//  rankingFilter
//
//  Created by TungAnh on 8/11/24.
//

import Foundation
import UIKit

extension ViewRecord {
    @IBAction func clickFlash(_ sender: Any) {
        isFlashOn.toggle()
        toggleBrightness()
    }

    @IBAction func clickTimer(_ sender: Any) {}

    @IBAction func clickMusic(_ sender: Any) {}

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
