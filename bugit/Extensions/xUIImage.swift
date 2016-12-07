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
    func pixellated(scale: Int = 7) -> UIImage? {
        
        guard let ciImage = UIKit.CIImage(image: self),
            let filter = CIFilter(name: "CIPixellate") else {
            return nil
        }
        filter.setValue(ciImage, forKey: "inputImage")
        filter.setValue(scale, forKey: "inputScale")
        let vector = CIVector(x: 120.0, y: 120.0)
        filter.setValue(vector, forKey: "inputCenter")
        guard let output = filter.outputImage else {
            return nil
        }
        
        return UIImage(ciImage: output)
    }
    
    // Usage: x.crop(bounds: CGRect(x, y, w, h))
    func crop(bounds: CGRect) -> UIImage? {
        
        dlog("bounds: \(bounds)")
        
        guard let cgImage = self.cgImage else {
            return nil
        }
        
        guard let cgCroppedImage = cgImage.cropping(to: bounds) else {
            return nil
        }
        
        let img = UIImage(cgImage: cgCroppedImage)
        dlog("img: \(img)")
        return img
    }
    
    func simpleScale(newSize: CGSize) -> UIImage? {
        
        var scaledImage: UIImage? = nil
        let hasAlpha = false
        let scale: CGFloat = self.scale 
        
        UIGraphicsBeginImageContextWithOptions(newSize, !hasAlpha, scale)
        self.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        
        scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
        
    }
}
