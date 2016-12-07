//
//  ShapeView.swift
//  bugit
//
//  Created by Ernest on 11/20/16.
//  Copyright © 2016 BugIt App. All rights reserved.
//

import UIKit
import AVFoundation


class PixelatedImageView: UIView {
    
    var regionSize: CGSize = CGSize(width: 0, height: 0)
    var containerBounds: CGRect = CGRect.zero
    var fillColor: UIColor!
    var outlineColor: UIColor!
    var canvasImage: UIImage!
    
    init(frame: CGRect, image: UIImage, regionSize: CGSize, containerBounds: CGRect) {
        super.init(frame: frame)
        self.canvasImage = image
        self.regionSize = regionSize
        self.containerBounds = containerBounds
        self.outlineColor = UIColor.clear
        self.fillColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        
        initGestureRecognizers()
    }
    
    func scaleImageToImageAspectFit() -> UIImage? {
        
        if let img = canvasImage {
            
            dlog("origImageSize: \(img.size)")
            
            let rect = AVMakeRect(aspectRatio: img.size, insideRect: containerBounds)
            
            dlog("scaledImageRect: \(rect)")
            
            let scaledImage = img.simpleScale(newSize: rect.size)
            
            dlog("scaledImage: \(scaledImage)")
            
            return scaledImage
        }
        
        return nil
    }

    
    func applyPixelation() {
        
        dlog("self.frame: \(self.frame), self.center: \(self.center)")
        
        let scaledRect = AVMakeRect(aspectRatio: canvasImage.size, insideRect: containerBounds)
        var cropRect = self.frame
        cropRect.origin.x -= scaledRect.origin.x
        
        let sectionImage = canvasImage.crop(bounds: cropRect)
        dlog("scaledSectionImage: \(sectionImage)")

        let pixelatedImage = sectionImage?.pixellated()
        let pixelatedImageView = UIImageView(image: pixelatedImage)
        pixelatedImageView.contentMode = .scaleAspectFit
        pixelatedImageView.tag = 99
        
        if let v = self.viewWithTag(99) {
            dlog("last frame: \(v.frame), center: \(v.center)")
            v.removeFromSuperview()
        }
        
        self.addSubview(pixelatedImageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    func didPan(_ sender: UIPanGestureRecognizer) {
        self.superview!.bringSubview(toFront: self)
        
        guard let canvas = self.canvasImage else {
            return
        }
        
        var translation = sender.translation(in: self)
        translation = translation.applying(self.transform)

        let scaledRect = AVMakeRect(aspectRatio: canvas.size, insideRect: containerBounds)
        let x:CGFloat = self.center.x - self.bounds.width/2.0
        
        if x >= scaledRect.origin.x {
            self.applyPixelation()
        }
        else {
            if let v = self.viewWithTag(99) {
                dlog("last frame: \(v.frame), center: \(v.center)")
                v.removeFromSuperview()
            }
        }
        self.center.x += translation.x
        self.center.y += translation.y
        
        
        sender.setTranslation(CGPoint.zero, in: self)
        
        
    }
    
    func didPinch(_ sender: UIPinchGestureRecognizer) {
        self.superview!.bringSubview(toFront: self)
        
        let scale = sender.scale
        self.transform = self.transform.scaledBy(x: scale, y: scale)
        
        sender .scale = 1.0
    }
    
    func didRotate(_ sender: UIRotationGestureRecognizer) {
        self.superview!.bringSubview(toFront: self)
        
        let rotation = sender.rotation
        self.transform = self.transform.rotated(by: rotation)
        sender.rotation = 0.0
    }
    
        
}
