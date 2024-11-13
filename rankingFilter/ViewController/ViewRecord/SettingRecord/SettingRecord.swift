//
//  SettingRecord.swift
//  rankingFilter
//
//  Created by TungAnh on 11/11/24.
//

import LouisPod
import UIKit

class SettingRecord: BaseView {
    @IBOutlet var btnTimes: [UIButton]!
    @IBOutlet var btnRecord: UIButton!
    var tagTimeSellected: Int = 1
    var clsTapRecord: (() -> Void)?
    var clsToggleCamera: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }

    func configureView() {
        backgroundColor = .clear
        updateBtns()
    }

    @IBAction func clickFlip(_ sender: Any) {
        clsToggleCamera?()
    }

    @IBAction func clickRecord(_ sender: Any) {
        clsTapRecord?()
    }

    @IBAction func timeTap(_ sender: UIButton) {
        tagTimeSellected = sender.tag
        updateBtns()
    }

    func updateBtns() {
        for item in btnTimes {
            item.addCornerRadius(radius: 5)
            if item.tag == tagTimeSellected {
                item.backgroundColor = .gray
            } else {
                item.backgroundColor = .clear
            }
        }
    }
}
