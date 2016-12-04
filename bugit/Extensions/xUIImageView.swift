//
//  xUIImageView.swift
//  bugit
//
//  Created by Ernest on 12/1/16.
//  Copyright © 2016 BugIt App. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    
    // Usage: x.addBlurEffect()
    func addBlurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.addSubview(blurEffectView)
    }
    
}
