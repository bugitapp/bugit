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
        
        sender .scale = 1.0
    }
    
    func didRotate(_ sender: UIRotationGestureRecognizer) {
        self.superview!.bringSubview(toFront: self)
        
        let rotation = sender.rotation
        self.transform = self.transform.rotated(by: rotation)
        sender.rotation = 0.0
    }
    
    override func draw(_ rect: CGRect) {
        self.fillColor.setFill()
        self.path.fill()
        
        outlineColor.setStroke()
        
        path.lineWidth = self.lineWidth
        
        path.stroke()
    }
    
}
