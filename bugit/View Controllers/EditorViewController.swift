//
//  EditorViewController.swift
//  bugit
//
//  Created by Ernest on 11/12/16.
//  Copyright © 2016 BugIt App. All rights reserved.
//

import UIKit

class EditorViewController: UIViewController {

    @IBOutlet weak var canvasImageView: UIImageView!
    
    var tapBegan = CGPoint(x:0, y:0)
    var tapEnded = CGPoint(x:0, y:0)
    
    @IBOutlet weak var trayView: UIView!
    @IBOutlet weak var trayArrowImageView: UIButton!
    @IBOutlet weak var trayToolsView: UIView!
    
    var trayOriginalCenter: CGPoint!
    var trayDownOffset: CGFloat!
    var trayUp: CGPoint!
    var trayDown: CGPoint!
    
    /*
    override func viewWillAppear(_ animated: Bool) {
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // TODO: Add image from Gallery
        canvasImageView.image = UIImage.init(named: "sample")
        
        // Gesture overload if we use swipes
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Collage"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(goToGallery))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Export"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(goToExport))
        
        /*
        // Gesture: Go to Gallery
        let leftEdgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(goToGallery))
        leftEdgePan.edges = .left
        view.addGestureRecognizer(leftEdgePan)
        
        // Gesture: Go to Export
        let rightEdgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(goToExport))
        rightEdgePan.edges = .right
        view.addGestureRecognizer(rightEdgePan)
        */
        
        // TODO: Slide up to bring up Settings?
        // TODO: Control Arrow settings & color
        
        // Gesture: Go back / Track
        let topEdgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(trashCanvas))
        topEdgePan.edges = .top
        view.addGestureRecognizer(topEdgePan)
        
        // Gesture: Tap to track where arrow should go
        let drawPan = UIPanGestureRecognizer(target: self, action: #selector(onTap))
        view.addGestureRecognizer(drawPan)
        
        setupToolbox()
    }
    
    func setupToolbox() {
        trayDownOffset = 170
        trayUp = trayView.center
        trayDown = CGPoint(x: trayView.center.x ,y: trayView.center.y + trayDownOffset)
        
        trayView.layer.shadowOffset = CGSize(-15, 20);
        trayView.layer.shadowRadius = 5;
        trayView.layer.shadowOpacity = 0.5;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func trashCanvas(_ sender: UIScreenEdgePanGestureRecognizer) {
        if sender.state == .recognized {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func goToGallery() {
        self.performSegue(withIdentifier: "GallerySegue", sender: self)
    }
    
    @IBAction func goToExport() {
        self.performSegue(withIdentifier: "ExportSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ExportSegue" {
            // Get a reference to the detail view controller
            let destinationViewController = segue.destination as! ExportViewController
            
            // Pass the flat canvas to export
            destinationViewController.flatCanvasImage = takeSnapshotOfView(view: canvasImageView)
        }
    }
    
    // MARK: - Gestures
    
    // Using Simultaneous Gesture Recognizers
    // Ref: https://courses.codepath.com/courses/ios_for_designers/pages/using_gesture_recognizers#heading-using-simultaneous-gesture-recognizers
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // Tray slide up and down with down bounce
    // Ref: https://guides.codepath.com/ios/Using-Gesture-Recognizers
    @IBAction func onTrayPanGesture(_ sender: UIPanGestureRecognizer) {
        //let location = sender.location(in: view)
        let velocity = sender.velocity(in: view)
        let translation = sender.translation(in: view)
        
        if sender.state == .began {
            trayOriginalCenter = trayView.center
            trayArrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat(180 * M_PI / 180))
        } else if sender.state == .changed {
            trayView.center = CGPoint(x: trayOriginalCenter.x, y: trayOriginalCenter.y + translation.y)
        } else if sender.state == .ended {
            trayArrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat(0 * M_PI / 180))
            if velocity.y > 0 {
                UIView.animate(withDuration:0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options:[] ,
                               animations: { () -> Void in
                                self.trayView.center = self.trayDown
                }, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.trayView.center = self.trayUp
                }
            }
        }
    }
    
    // MARK: - Toolbox
    
    @IBAction func changeColor(_ sender: UIButton) {
        print("changeColor.sender.tag = \(sender.tag)")
        
        if sender.tag == 801 {
            trayView.backgroundColor = UIColor.init(netHex: 0xC0C0C0) // grey
        } else if sender.tag == 802 {
            trayView.backgroundColor = UIColor.init(netHex: 0x82CAFA) // light blue
        } else if sender.tag == 803 {
            trayView.backgroundColor = UIColor.init(netHex: 0x59E817) // light green
        } else if sender.tag == 804 {
            trayView.backgroundColor = UIColor.init(netHex: 0xFF0000) // red
        } else if sender.tag == 805 {
            trayView.backgroundColor = UIColor.init(netHex: 0xFFFF00) // yellow
        } else if sender.tag == 806 {
            trayView.backgroundColor = UIColor.init(netHex: 0x000000) // black
        } else {
            // erase
        }
    }
    
    @IBAction func changeTool(_ sender: UIButton) {
        print("changeTool.sender.tag = \(sender.tag)")
        
        if sender.tag == 701 {
            // Arrow
        } else if sender.tag == 702 {
            // text
        } else if sender.tag == 703 {
            // circle
        } else if sender.tag == 704 {
            // square
        }
    }
    
    
    // MARK: - Draw
    
    func drawArrow(from: CGPoint, to: CGPoint) {
        // TODO: Should be set from Settings?
        let tailWidth = 10 as CGFloat
        let headWidth = 25 as CGFloat
        let headLength = 40 as CGFloat
        
        // CGPoint(x:10, y:10)
        // CGPoint(x:200, y:10)
        let arrow = UIBezierPath.arrow(from: from, to: to, tailWidth: tailWidth, headWidth: headWidth, headLength: headLength)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = arrow.cgPath
        //shapeLayer.fillColor = UIColor.red.cgColor
        shapeLayer.fillColor = trayView.backgroundColor?.cgColor // this is set by each pencil tap
        
        canvasImageView.layer.addSublayer(shapeLayer)
    }
    
    func takeSnapshotOfView(view:UIView) -> UIImage? {
        UIGraphicsBeginImageContext(CGSize(width: view.frame.size.width, height: view.frame.size.height))
        view.drawHierarchy(in: CGRect(x: 0.0, y: 0.0, width: view.frame.size.width, height: view.frame.size.height), afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    @IBAction func onTap(_ sender: UIPanGestureRecognizer) {
        print("tapped")
        print("sender.state = \(sender.state)")
        
        let point = sender.location(in: canvasImageView) as CGPoint
        //print("point = \(point)")
        
        if sender.state == UIGestureRecognizerState.began {
            print("tapped.began")
            
            tapBegan = point as CGPoint
            print("tapBegan = \(tapBegan)")
        } else if sender.state == UIGestureRecognizerState.ended {
            print("tapped.ended")
            
            tapEnded = point as CGPoint
            print("tapEnded = \(tapEnded)")
            print("tapBegan = \(tapBegan)")
            
            // Draw Arrow
            drawArrow(from: tapBegan, to: tapEnded)
            
            // TODO: How to move the arrow around once it's been drawn?
        }
    }

}
