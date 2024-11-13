//
//  UIView+Extension.swift
//  tip-calculator
//
//  Created by Kelvin Fok on 15/12/22.
//

import Foundation
import UIKit

public extension UIView {
    func addGradientBorder(colors: [UIColor], width: CGFloat, radius: CGFloat, check: Bool = false) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }

        if check == false {
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        } else {
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        }
        gradientLayer.frame = CGRect(origin: .zero, size: self.bounds.size)

        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = width
        let roundedRectPath = UIBezierPath(roundedRect: self.bounds.insetBy(dx: width / 2, dy: width / 2), cornerRadius: radius)
        shapeLayer.path = roundedRectPath.cgPath
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.black.cgColor // This color will be replaced by the gradient
        gradientLayer.mask = shapeLayer

        // Ensure that the gradient layer resizes with the view
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = radius

        self.layer.addSublayer(gradientLayer)
    }

    func removeGradientLayers() {
        if let sublayers = self.layer.sublayers {
            for sublayer in sublayers where sublayer is CAGradientLayer {
                sublayer.removeFromSuperlayer()
            }
        }
    }

    func circle() {
        layoutIfNeeded()
        layer.cornerRadius = min(bounds.width, bounds.height) / 2
        layer.masksToBounds = true
    }

    func animateIn() {
        guard isHidden else { return }
        self.alpha = 0
        self.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
    }

    func animateOut() {
        guard !isHidden else { return }
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { finished in
            self.isHidden = finished
        }
    }

    func anchor(top: NSLayoutYAxisAnchor? = nil,
                leading: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                trailing: NSLayoutXAxisAnchor? = nil,
                paddingTop: CGFloat = 0,
                paddingLeading: CGFloat = 0,
                paddingBottom: CGFloat = 0,
                paddingTrailing: CGFloat = 0,
                width: CGFloat? = nil,
                height: CGFloat? = nil)
    {
        translatesAutoresizingMaskIntoConstraints = false

        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }

        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: paddingLeading).isActive = true
        }

        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }

        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: -paddingTrailing).isActive = true
        }

        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }

        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }

    func center(inView view: UIView, yConstant: CGFloat? = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: yConstant!).isActive = true
    }

    func centerX(inView view: UIView, topAnchor: NSLayoutYAxisAnchor? = nil, paddingTop: CGFloat? = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        if let topAnchor = topAnchor {
            self.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop!).isActive = true
        }
    }

    func centerY(inView view: UIView, leadingAnchor: NSLayoutXAxisAnchor? = nil, paddingLeading: CGFloat? = nil, constant: CGFloat? = 0) {
        translatesAutoresizingMaskIntoConstraints = false

        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant!).isActive = true

        if let leadingAnchor = leadingAnchor, let padding = paddingLeading {
            self.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding).isActive = true
        }
    }

    func setDimensions(width: CGFloat, height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: width).isActive = true
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }

    func addConstraintsToFillView(_ view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        self.anchor(top: view.topAnchor, leading: view.leadingAnchor,
                    bottom: view.bottomAnchor, trailing: view.trailingAnchor)
    }

    func addShadow(color: UIColor = .black, opacity: Float = 0.1, offset: CGSize = CGSize(width: 0.4, height: 0.4), radius: CGFloat = 4) {
        layer.masksToBounds = true
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
    }

    func addCornerRadius(radius: CGFloat) {
        layer.masksToBounds = true
        layer.cornerRadius = radius
    }

    @available(iOS 11.0, *)
    func addRoundedCorners(corners: CACornerMask, radius: CGFloat) {
        layer.masksToBounds = true
        layer.cornerRadius = radius
        layer.maskedCorners = [corners]
    }

    func roundCornerWithShadow(cornerRadius: CGFloat, shadowRadius: CGFloat, offsetX: CGFloat, offsetY: CGFloat, colour: UIColor, opacity: Float, corners: CACornerMask = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]) {
        self.clipsToBounds = false
        let layer = self.layer
        layer.masksToBounds = false
        layer.cornerRadius = cornerRadius
        if #available(iOS 11.0, *) {
            layer.maskedCorners = corners
        } else {
            // Fallback on earlier versions
        }
        layer.shadowOffset = CGSize(width: offsetX, height: offsetY)
        layer.shadowColor = colour.cgColor
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = opacity
        layer.shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: layer.cornerRadius).cgPath
        let bColour = self.backgroundColor
        self.backgroundColor = nil
        layer.backgroundColor = bColour?.cgColor
    }

    func loadViewFromNib(nibName: String) -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }

    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.values = [
            NSValue(cgPoint: CGPoint(x: self.center.x - 5, y: self.center.y)),
            NSValue(cgPoint: CGPoint(x: self.center.x + 5, y: self.center.y))
        ]
        animation.autoreverses = true
        animation.repeatCount = Float.infinity // Lặp vô hạn
        animation.duration = 0.1

        layer.add(animation, forKey: "position")
    }

    func gradient(colors: [UIColor],
                  startPoint: CGPoint,
                  endPoint: CGPoint)
    {
        let gradientLayer = CAGradientLayer().then {
            layoutIfNeeded()
            $0.frame = bounds
            $0.colors = colors.map { $0.cgColor }
            $0.locations = [0.0, 1.0]
            $0.startPoint = startPoint
            $0.endPoint = endPoint
            $0.name = ShapeLayerName.gradient.rawValue
        }

        if let oldLayer = layer.sublayers?.first(where: { $0.name == ShapeLayerName.gradient.rawValue }) {
            layer.replaceSublayer(oldLayer, with: gradientLayer)
        } else {
            layer.insertSublayer(gradientLayer, at: 0)
        }
    }

    func borderGradient(colors: [UIColor],
                        lineWidth: CGFloat,
                        startPoint: CGPoint,
                        endPoint: CGPoint,
                        cornerRadius: CGFloat = 0)
    {
        let shape = CAShapeLayer().then {
            $0.lineWidth = lineWidth
            $0.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
            $0.strokeColor = UIColor.black.cgColor
            $0.fillColor = UIColor.clear.cgColor
        }

        let newLayer = CAGradientLayer().then {
            $0.frame = CGRect(origin: CGPoint.zero, size: frame.size)
            $0.colors = colors.map { $0.cgColor }
            $0.locations = [0.0, 1.0]
            $0.startPoint = startPoint
            $0.endPoint = endPoint
            $0.name = ShapeLayerName.borderGradient.rawValue
            $0.mask = shape
        }

        if let oldLayer = layer.sublayers?.first(where: { $0.name == ShapeLayerName.borderGradient.rawValue }) {
            layer.replaceSublayer(oldLayer, with: newLayer)
        } else {
            layer.insertSublayer(newLayer, at: 0)
        }
    }

    func addInnerShadow(radius: CGFloat) {
        let innerShadow = CALayer()
        innerShadow.frame = bounds

        // Shadow path (1pt ring around bounds)
//        let radius = self.frame.size.height/2
        let path = UIBezierPath(roundedRect: innerShadow.bounds.insetBy(dx: -1, dy: -1), cornerRadius: radius)
        let cutout = UIBezierPath(roundedRect: innerShadow.bounds, cornerRadius: radius).reversing()
        path.append(cutout)

        innerShadow.shadowPath = path.cgPath
        innerShadow.masksToBounds = true
        // Shadow properties
        innerShadow.shadowColor = UIColor.black.cgColor
        innerShadow.shadowOffset = CGSize(width: 0, height: 2)
        innerShadow.shadowOpacity = 1
        innerShadow.shadowRadius = 2
        innerShadow.cornerRadius = radius
        innerShadow.name = ShapeLayerName.innerShadow.rawValue

        if let oldLayer = layer.sublayers?.first(where: { $0.name == ShapeLayerName.innerShadow.rawValue }) {
            layer.replaceSublayer(oldLayer, with: innerShadow)
        } else {
            layer.addSublayer(innerShadow)
        }
    }

    func disableTemporatory(in timeInterval: TimeInterval) {
        isUserInteractionEnabled = false
        after(interval: timeInterval) {
            self.isUserInteractionEnabled = true
        }
    }

    func animate(inStackView: UIStackView, isShow: Bool) {
        UIView.animate(withDuration: 0.35,
                       delay: 0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 1,
                       options: [],
                       animations: {
                           self.isHidden = !isShow
                           self.alpha = isShow ? 1 : 0
                           inStackView.layoutIfNeeded()
                       }, completion: { _ in
                           self.isHidden = !isShow
                       })
    }

    func jumpingAnimation(completion: @escaping (() -> Void)) {
        self.do {
            $0.isHidden = true
            $0.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .leastNormalMagnitude) {
            self.isHidden = false
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 2, options: []) {
                self.transform = .identity
            } completion: { _ in
                completion()
            }
        }
    }

    func jumpingAnimation(endScale: CGFloat, completion: (() -> Void)?) {
//        self.do {
//            $0.isHidden = true
//            $0.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
//        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .leastNormalMagnitude) {
            self.isHidden = false
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 2, options: []) {
                self.transform = CGAffineTransform(scaleX: endScale, y: endScale)
            } completion: { _ in
                completion?()
            }
        }
    }

    func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }

    func loadNib<T: UIView>() -> T {
        let name = String(describing: self)
        let bundle = Bundle(for: T.self)
        guard let xib = bundle.loadNibNamed(name, owner: nil, options: nil)?.first as? T else {
            fatalError("Cannot load nib named `\(name)`")
        }
        return xib
    }

    func shadowView(color: UIColor = .black,
                    alpha: Float = 0.25,
                    x: CGFloat = 0,
                    y: CGFloat = 3,
                    blur: CGFloat = 8)
    {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = CGSize(width: x, height: y)
        layer.shadowOpacity = alpha
        layer.shadowRadius = blur
        layer.masksToBounds = false
    }

    func roundCorners(_ corners: UIRectCorner,
                      radius: CGFloat,
                      borderColor: UIColor = .clear,
                      borderWidth: CGFloat = 2,
                      shadowColor: UIColor = .black)
    {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask

        let newLayer = CAShapeLayer().then {
            $0.name = ShapeLayerName.roundCorner.rawValue
            $0.path = path.cgPath
            $0.lineWidth = borderWidth
            $0.strokeColor = borderColor.cgColor
            $0.fillColor = UIColor.clear.cgColor
            $0.frame = mask.bounds
        }

        if let oldLayer = layer.sublayers?.first(where: { $0.name == ShapeLayerName.roundCorner.rawValue }) {
            layer.replaceSublayer(oldLayer, with: newLayer)
        } else {
            layer.addSublayer(newLayer)
        }
    }
}

private enum ShapeLayerName: String {
    case roundCorner
    case gradient
    case borderGradient
    case innerShadow
}

public protocol Then {}
public extension Then where Self: Any {
    /// Makes it available to set properties with closures just after initializing and copying the value types.
    ///
    ///     let frame = CGRect().with {
    ///       $0.origin.x = 10
    ///       $0.size.width = 100
    ///     }
    func with(_ block: (inout Self) throws -> Void) rethrows -> Self {
        var copy = self
        try block(&copy)
        return copy
    }

    /// Makes it available to execute something with closures.
    ///
    ///     UserDefaults.standard.do {
    ///       $0.set("devxoul", forKey: "username")
    ///       $0.set("devxoul@gmail.com", forKey: "email")
    ///       $0.synchronize()
    ///     }
    func `do`(_ block: (Self) throws -> Void) rethrows {
        try block(self)
    }
}

public extension Then where Self: AnyObject {
    /// Makes it available to set properties with closures just after initializing.
    ///
    ///     let label = UILabel().then {
    ///       $0.textAlignment = .center
    ///       $0.textColor = UIColor.black
    ///       $0.text = "Hello, World!"
    ///     }
    func then(_ block: (Self) throws -> Void) rethrows -> Self {
        try block(self)
        return self
    }
}

extension NSObject: Then {}

extension CGPoint: Then {}
extension CGRect: Then {}
extension CGSize: Then {}
extension CGVector: Then {}
extension Array: Then {}
extension Dictionary: Then {}
extension Set: Then {}

#if os(iOS) || os(tvOS)
extension UIEdgeInsets: Then {}
extension UIOffset: Then {}
extension UIRectEdge: Then {}
#endif
