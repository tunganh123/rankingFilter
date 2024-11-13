//
//  ViewRecord.swift
//  rankingFilter
//
//  Created by TungAnh on 8/11/24.
//

import AVFoundation
import LouisPod
import UIKit
import Vision

class ViewRecord: UIViewController {
    @IBOutlet var btnsSellect: [UIButton]!
    var faceViewref: faceView!
    var restWindow: UIWindow?

    var faceDetectionRequest: VNRequest!
    var button: UIButton!
    var currentFaceView: UIView? // Biến lưu trữ view của khuôn mặt hiện tại
    var frameDetection: CGRect = .zero
    var previousFaceRect: CGRect = .zero
    var previousRoll: CGFloat = 0.0

    @IBOutlet var viewContent: UIView!
    var settingRecord: SettingRecord!

    @IBOutlet var cameraView: UIView!
    var cameraLayer: Recorder!
    // Flag record
    var isStartRecord: Bool = false
    var isPauseRecord: Bool = false {
        didSet {
            settingRecord.btnRecord.setBackgroundImage(UIImage(named: isPauseRecord ? "ic_record_pause" : "ic_record_start"), for: .normal)
        }
    }
    var isStopRecord: Bool = false

    //Flash
    var isFlashOn = false
    var originalBrightness: CGFloat = UIScreen.main.brightness // Lưu độ sáng ban đầu
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }

 
}
