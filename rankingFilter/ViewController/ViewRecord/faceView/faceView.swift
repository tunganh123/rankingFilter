//
//  faceView.swift
//  rankingFilter
//
//  Created by TungAnh on 11/11/24.
//

import LouisPod
import UIKit

var images = [UIImage(named: "img"), UIImage(named: "img2"), UIImage(named: "img3"), UIImage(named: "img4"), UIImage(named: "img5"), UIImage(named: "img6"), UIImage(named: "img7"), UIImage(named: "img8"), UIImage(named: "img9"), UIImage(named: "img10"), UIImage(named: "img11"), UIImage(named: "img12"), UIImage(named: "img13"), UIImage(named: "img14"), UIImage(named: "img15")] // Mảng ảnh
class faceView: BaseView {
    var imagesRef = images
    var timerChooseImage: Timer?
    var elapsedTime: Double = 0.0 // Bộ đếm thời gian
    @IBOutlet var img: UIImageView!
    var checkTimerRun: Bool = false
    var imageSellected: UIImage = images[0] ?? UIImage()

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
    }

    func bindImg() {
        elapsedTime = 0.0 // Đặt lại thời gian
        checkTimerRun = true
        timerChooseImage = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateImage), userInfo: nil, repeats: true)
    }

    @objc func updateImage() {
        elapsedTime += 0.1

        // Kiểm tra nếu mảng ảnh không rỗng
        if !imagesRef.isEmpty {
            // Chọn ngẫu nhiên một ảnh và lấy chỉ mục của nó
            if let randomIndex = imagesRef.indices.randomElement() {
                img.image = imagesRef[randomIndex]
                imageSellected = imagesRef[randomIndex] ?? UIImage()
                // Dừng timer và xóa ảnh khỏi mảng sau 3 giây
                if elapsedTime >= 3.0 {
                    imagesRef.remove(at: randomIndex)
                    checkTimerRun = false
                    timerChooseImage?.invalidate()
                    timerChooseImage = nil
                    elapsedTime = 0.0
                }
            }
        } else {
            // Nếu mảng ảnh đã rỗng, dừng timer
            timerChooseImage?.invalidate()
            timerChooseImage = nil
            elapsedTime = 0.0
            checkTimerRun = false
        }
    }
}
