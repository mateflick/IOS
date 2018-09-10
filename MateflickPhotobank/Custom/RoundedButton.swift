//
//  RoundedButton.swift
//  MateflickPhotobank
//
//  Created by Panda on 6/15/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
    }
}
