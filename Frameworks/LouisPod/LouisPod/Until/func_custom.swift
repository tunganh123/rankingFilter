//
//  func_custom.swift
//  LouisPod
//
//  Created by TungAnh on 5/6/24.
//
import Foundation
import UIKit

public func applyGradientToLabel(label: UILabel, colors: [CGColor], check: Bool = false) {
    label.setNeedsLayout()
    label.layoutIfNeeded()

    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = label.bounds
    gradientLayer.colors = colors
    if check == false {
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
    } else {
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
    }

    let textLayer = CATextLayer()
    textLayer.frame = label.bounds
    textLayer.string = label.text
    textLayer.font = label.font
    textLayer.fontSize = label.font.pointSize
    textLayer.alignmentMode = .center
    textLayer.contentsScale = UIScreen.main.scale
    textLayer.isWrapped = true
    textLayer.truncationMode = .end
    textLayer.foregroundColor = UIColor.white.cgColor

    gradientLayer.mask = textLayer

    label.layer.addSublayer(gradientLayer)
}

public func applyGradientToView(view: UIView, colors: [CGColor], check: Bool = false) {
    view.setNeedsLayout()
    view.layoutIfNeeded()

    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = view.bounds
    gradientLayer.colors = colors
    if check == false {
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
    } else {
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
    }

    // Remove any existing gradient layers to avoid layering multiple gradients on top of each other
    if let sublayers = view.layer.sublayers {
        for sublayer in sublayers where sublayer is CAGradientLayer {
            sublayer.removeFromSuperlayer()
        }
    }

    view.layer.insertSublayer(gradientLayer, at: 0)
}

public func setupBarbuttonbg(nameimg: String, wi: Int = 34, he: Int = 34, target: Any?, action: Selector?) -> UIBarButtonItem {
    let button = UIButton()
    button.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
    button.setImage(UIImage(named: nameimg), for: .normal)
    button.imageView?.contentMode = .scaleAspectFill

    if let target = target, let action = action {
        button.addTarget(target, action: action, for: .touchUpInside)
    }

    let buttonBarButtonView = UIView(frame: CGRect(x: 0, y: 0, width: wi, height: he))
    //  buttonBarButtonView.backgroundColor = AppColor.Bar_btn_gray
    buttonBarButtonView.addCornerRadius(radius: 3)
    // Calculate the center position for the button within buttonBarButtonView
    let xOffset = (wi - 25) / 2
    let yOffset = (he - 25) / 2

    // Set the frame for the button
    button.frame.origin = CGPoint(x: xOffset, y: yOffset)

    buttonBarButtonView.addSubview(button)

    let buttonBarButton = UIBarButtonItem(customView: buttonBarButtonView)

    return buttonBarButton
}

public func setupBarbuttonright(nameimg: String, wi: Int = 28, he: Int = 25, target: Any?, action: Selector?) -> UIBarButtonItem {
    let button = UIButton()
    if UIDevice.current.userInterfaceIdiom == .pad {
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
    } else {
        button.frame = CGRect(x: 0, y: 0, width: wi, height: he)
    }
    button.setImage(UIImage(named: nameimg), for: .normal)
    button.imageView?.contentMode = .scaleAspectFit
    if let target = target, let action = action {
        button.addTarget(target, action: action, for: .touchUpInside)
    }
    var buttonBarButtonView = UIView()
    if UIDevice.current.userInterfaceIdiom == .pad {
        buttonBarButtonView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))

    } else {
        buttonBarButtonView = UIView(frame: CGRect(x: 0, y: 0, width: wi, height: he))
    }
    buttonBarButtonView.addSubview(button)
    //  buttonBarButtonView.backgroundColor = .blue
    let buttonBarButton = UIBarButtonItem(customView: buttonBarButtonView)

    return buttonBarButton
}

public func setupBarButtonWithBoldTitle(title: String, target: Any?, action: Selector?) -> UIBarButtonItem {
    // Tạo một label để hiển thị tiêu đề
    let titleLabel = UILabel()
    titleLabel.text = title
    titleLabel.font = UIFont.boldSystemFont(ofSize: 25) // Điều chỉnh kích thước font nếu cần
    titleLabel.textColor = .white
    titleLabel.sizeToFit() // Đảm bảo kích thước của label phù hợp với nội dung

    // Thiết lập căn lề trái cho label
    titleLabel.textAlignment = .left

    // Tạo một UIBarButtonItem với custom view là titleLabel
    let barButtonItem = UIBarButtonItem(customView: titleLabel)

    // Thêm action nếu được cung cấp
    if let target = target, let action = action {
        let tapGesture = UITapGestureRecognizer(target: target, action: action)
        barButtonItem.customView?.addGestureRecognizer(tapGesture)
    }

    return barButtonItem
}
