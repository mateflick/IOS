//
//  CircleImageView.swift
//  MateflickPhotobank
//
//  Created by Panda on 6/22/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit

class CircleImageView: UIImageView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.size.width/2
        self.clipsToBounds = true
    }    
}
