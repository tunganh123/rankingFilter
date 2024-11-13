//
//  BaseView.swift
//  LouisPod
//
//  Created by DucVV on 13/06/2024.
//

import Foundation

open class BaseView: UIView {
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        guard let content = Bundle(for: type(of: self)).loadNibNamed(className, owner: self, options: nil)?.first as? UIView else {
            return
        }
        content.frame = bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(content)
        Common.updateAllScaleConstraints(forView: self)
        setupUI()
    }

    open func setupUI() {}
}
