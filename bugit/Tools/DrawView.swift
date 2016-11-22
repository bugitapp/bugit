//
//  DrawView.swift
//  bugit
//
//  Created by Ernest Semerda on 11/21/16.
//  Copyright © 2016 BugIt App. All rights reserved.
//

import UIKit

class DrawView : UIView {
    
    let size: CGFloat = 150
    
    var drawColor: UIColor = UIColor.black
    var drawWidth: CGFloat = 10.0
    
    private var path: UIBezierPath = UIBezierPath()
    
    init(origin: CGPoint, paletteColor: UIColor) {
        super.init(frame: CGRect(0.0, 0.0, size, size))
        
        drawColor = paletteColor
        self.setupGestureRecognizers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Drawing a path
    
    override func draw(_ rect: CGRect) {
        // 4. Redraw whole rect, ignoring parameter. Please note we always invalidate whole view.
        let context = UIGraphicsGetCurrentContext()
        self.drawColor.setStroke()
        self.path.lineWidth = self.drawWidth
        self.path.lineCapStyle = .round
        self.path.stroke()
    }
    
    // MARK: Gestures
    
    private func setupGestureRecognizers() {
        // 1. Set up a pan gesture recognizer to track where user moves finger
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.addGestureRecognizer(panRecognizer)
    }
    
    @objc private func handlePan(sender: UIPanGestureRecognizer) {
        let point = sender.location(in: self)
        switch sender.state {
        case .began:
            self.startAtPoint(point: point)
        case .changed:
            self.continueAtPoint(point: point)
        case .ended:
            self.endAtPoint(point: point)
        case .failed:
            self.endAtPoint(point: point)
        default:
            assert(false, "State not handled")
        }
    }
    
    // MARK: Tracing a line
    
    private func startAtPoint(point: CGPoint) {
        self.path.move(to: point)
    }
    
    private func continueAtPoint(point: CGPoint) {
        // 2. Accumulate points as they are reported by the gesture recognizer, in a bezier path object
        self.path.addLine(to: point)
        
        // 3. Trigger a redraw every time a point is added (finger moves)
        self.setNeedsDisplay()
    }
    
    private func endAtPoint(point: CGPoint) {
        // Nothing to do when ending/cancelling for now
    }
}
