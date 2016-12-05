//
//  TextView.swift
//  bugit
//
//  Created by Ernest on 11/21/16.
//  Copyright © 2016 BugIt App. All rights reserved.
//

import UIKit

class TextView: UIView {
    
    var cgSize: CGSize = CGSize(width: 100, height: 100)
    var fillColor: UIColor!
    var outlineColor: UIColor!
    var originClick: CGPoint = CGPoint(x: 0, y: 0)
    
    init(origin: CGPoint, paletteColor: UIColor) {
        super.init(frame: CGRect(origin.x, origin.y, cgSize.width, cgSize.height))
        
        self.outlineColor = paletteColor
        self.fillColor = UIColor.clear
        
        originClick = origin
        //self.center = origin
        
        self.backgroundColor = UIColor.clear
        
        initGestureRecognizers()
    }
    
    init(origin: CGPoint, size: CGSize, paletteColor: UIColor) {
        super.init(frame: CGRect(origin.x, origin.y, size.width, size.height))
        
        self.cgSize = size
        self.outlineColor = paletteColor
        self.fillColor = UIColor.clear
        
        originClick = origin
        //self.center = origin
        
        self.backgroundColor = UIColor.clear
        
        initGestureRecognizers()
    }

    
    func initGestureRecognizers() {
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        addGestureRecognizer(panGR)
        
        let pinchGR = UIPinchGestureRecognizer(target: self, action: #selector(didPinch))
        addGestureRecognizer(pinchGR)
        
        let rotationGR = UIRotationGestureRecognizer(target: self, action: #selector(didRotate))
        addGestureRecognizer(rotationGR)
    }
    
    func pointFrom(angle: CGFloat, radius: CGFloat, offset: CGPoint) -> CGPoint {
        return CGPoint(radius * cos(angle) + offset.x, radius * sin(angle) + offset.y)
    }
    
    func trianglePathInRect(rect:CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        
        path.move(to: CGPoint(rect.width / 2.0, rect.origin.y))
        path.addLine(to: CGPoint(rect.width,rect.height))
        path.addLine(to: CGPoint(rect.origin.x,rect.height))
        path.close()
        
        return path
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textToImage(drawText text: String, inImage image: UIImage) -> UIImage {
        let textColor = UIColor.white
        let textFont = UIFont(name: "OpenSans", size: 12)! // TODO: Allow configuration of this in Alert box?
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
            ] as [String : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
        let rect = CGRect(origin: self.center, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        dlog("newImage: \(newImage), for string: \(text)")
        
        return newImage!
    }
    
    func generateText(drawText text: String) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.frame = CGRect(origin: CGPoint(0, 0), size: cgSize)
        
        //UIFont(name: "SFUIText-Light", size: 17)!
        textLayer.font = CTFontCreateWithName("SFUIText-Light" as CFString?, 17, nil) // TODO: Allow user to change
        dlog("font: \(textLayer.font)")
        textLayer.fontSize = 17.0
        textLayer.string = text
        
        textLayer.foregroundColor = self.outlineColor.cgColor
        textLayer.isWrapped = true
        textLayer.alignmentMode = kCAAlignmentLeft
        textLayer.contentsScale = UIScreen.main.scale
        
        dlog("newTextLayer: \(textLayer), for string: \(text)")

        return textLayer
    }
    
    // MARK: Gestures
    
    func didPan(_ sender: UIPanGestureRecognizer) {
        self.superview!.bringSubview(toFront: self)
        
        var translation = sender.translation(in: self)
        translation = translation.applying(self.transform)
        
        self.center.x += translation.x
        self.center.y += translation.y
        
        sender.setTranslation(CGPoint.zero, in: self)
    }
    
    func didPinch(_ sender: UIPinchGestureRecognizer) {
        self.superview!.bringSubview(toFront: self)
        
        let scale = sender.scale
        self.transform = self.transform.scaledBy(x: scale, y: scale)
        sender.scale = 1.0
    }
    
    func didRotate(_ sender: UIRotationGestureRecognizer) {
        self.superview!.bringSubview(toFront: self)
        
        let rotation = sender.rotation
        self.transform = self.transform.rotated(by: rotation)
        sender.rotation = 0.0
    }
}
