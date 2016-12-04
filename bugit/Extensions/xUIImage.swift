//
//  xUIImage.swift
//  bugit
//
//  Created by Ernest on 12/3/16.
//  Copyright © 2016 BugIt App. All rights reserved.
//

import UIKit

extension UIImage {
    
    // Usage: canvasImageView.image = canvasImageView.image?.pixellated(scale: 20)
    func pixellated(scale: Int = 8) -> UIImage? {
        guard let
            ciImage = UIKit.CIImage(image: self),
            let filter = CIFilter(name: "CIPixellate") else { return nil }
        filter.setValue(ciImage, forKey: "inputImage")
        filter.setValue(scale, forKey: "inputScale")
        guard let output = filter.outputImage else { return nil }
        return UIImage(ciImage: output)
    }
    
}
