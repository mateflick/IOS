//
//  GradientRoundedButton.swift
//  MateflickPhotobank
//
//  Created by Panda on 5/24/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit

@IBDesignable
class GradientRoundedButton: UIButton {
    let gradientLayer = CAGradientLayer()
    
    @IBInspectable
    var topGradientColor: UIColor? {
        didSet {
            setGradient(topGradientColor: topGradientColor, bottomGradientColor: bottomGradientColor)
        }
    }
    
    @IBInspectable
    var bottomGradientColor: UIColor? {
        didSet {
            setGradient(topGradientColor: topGradientColor, bottomGradientColor: bottomGradientColor)
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()

        gradientLayer.frame         = bounds
        gradientLayer.borderColor   = layer.borderColor
        gradientLayer.borderWidth   = layer.borderWidth
        gradientLayer.cornerRadius  = layer.cornerRadius
    }
    
    
    private func setGradient(topGradientColor: UIColor?, bottomGradientColor: UIColor?) {
        if let topGradientColor = topGradientColor, let bottomGradientColor = bottomGradientColor {
            gradientLayer.frame         = bounds
            gradientLayer.colors        = [topGradientColor.cgColor, bottomGradientColor.cgColor]
            gradientLayer.borderColor   = layer.borderColor
            gradientLayer.borderWidth   = layer.borderWidth
            gradientLayer.cornerRadius  = layer.cornerRadius
            layer.insertSublayer(gradientLayer, at: 0)
        } else {
            gradientLayer.removeFromSuperlayer()
        }
    }

}
