//
//  UITextField+Extensions.swift
//  YaTracker
//
//  Created by ANTON ZVERKOV on 28.07.2025.
//

import UIKit

extension UITextField {
    func setIcon(_ icon: UIImage, spacing: CGFloat? = nil) {
        let iconView = UIImageView(image: icon)
        iconView.frame = CGRect(x: spacing ?? 0, y: 0, width: icon.size.width, height: icon.size.height)
        let frameWidth = iconView.frame.width + (spacing ?? 0) * 2
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: frameWidth, height: iconView.frame.height))
        containerView.addSubview(iconView)
        
        leftView = containerView
        leftViewMode = .always
    }
}
