//
//  ShapeView.swift
//  bugit
//
//  Created by Ernest on 11/20/16.
//  Copyright © 2016 BugIt App. All rights reserved.
//

import UIKit

enum ShapeType: Int {
    case Square
    case Circle
    case Triangle
}

class ShapeView: UIView {
    
    let size: CGFloat = 150
    let lineWidth: CGFloat = 6
    var fillColor: UIColor!
    var outlineColor: UIColor!
    var path: UIBezierPath!
    
    init(origin: CGPoint, paletteColor: UIColor, shapeType: ShapeType) {
        super.init(frame: CGRect(0.0, 0.0, size, size))
        
        self.outlineColor = paletteColor
        self.fillColor = UIColor.clear
        self.path = selectShape(shapeType: shapeType)
        
        self.center = origin
        
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
    
    func selectShape(shapeType: ShapeType) -> UIBezierPath {
        let insetRect = self.bounds.insetBy(dx: lineWidth,dy: lineWidth)
        
        if shapeType == ShapeType.Square {
            return UIBezierPath(roundedRect: insetRect, cornerRadius: 10.0)
        } else if shapeType == ShapeType.Circle {
            return UIBezierPath(ovalIn: insetRect)
        } else { // Triangle
            return trianglePathInRect(rect: insetRect)
        }
    }
    
    func didPan(panGR: UIPanGestureRecognizer) {
        
        self.superview!.bringSubview(toFront: self)
        
        var translation = panGR.translation(in: self)
        
        translation = translation.applying(self.transform)
        
        self.center.x += translation.x
        self.center.y += translation.y
        
        panGR.setTranslation(CGPoint.zero, in: self)
    }
    
    func didPinch(pinchGR: UIPinchGestureRecognizer) {
        
        self.superview!.bringSubview(toFront: self)
        
        let scale = pinchGR.scale
        
        self.transform = self.transform.scaledBy(x: scale, y: scale)
        
        pinchGR.scale = 1.0
    }
    
    func didRotate(rotationGR: UIRotationGestureRecognizer) {
        
        self.superview!.bringSubview(toFront: self)
        
        let rotation = rotationGR.rotation
        
        self.transform = self.transform.rotated(by: rotation)
        
        rotationGR.rotation = 0.0
    }
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
        self.fillColor.setFill()
        self.path.fill()
        
        //let color = UIColor.black // Get color from palette
        //color.setFill()
        
        //if arc4random() % 2 == 0 {
        //    path.fill()
        //}
        
        outlineColor.setStroke()
        
        path.lineWidth = self.lineWidth
        
        path.stroke()
    }
    
}
