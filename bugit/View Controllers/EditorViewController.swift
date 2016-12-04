//
//  EditorViewController.swift
//  bugit
//
//  Created by Ernest on 11/12/16.
//  Copyright © 2016 BugIt App. All rights reserved.
//

import UIKit

enum ToolsInTray: Int {
    case Arrow
    case Text
    case Circle
    case Square
    case Freehand
    case Blur
}

class EditorViewController: UIViewController, UIScrollViewDelegate {

    //@IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var canvasImageView: UIImageView!
    
    @IBOutlet weak var trayViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var trayViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var toolButtonView: HorizontalButtonView!
    let colorArray = [ 0x000000, 0xfe0000, 0xff7900, 0xffb900, 0xffde00, 0xfcff00, 0xd2ff00, 0x05c000, 0x00c0a7, 0x0600ff, 0x6700bf, 0x9500c0, 0xbf0199, 0xffffff ]
    
    @IBOutlet weak var selectedColorView: UIView!
    @IBOutlet weak var colorSlider: UISlider!
    @IBOutlet weak var colorbarImageView: UIImageView!
    
    var screenshotAssetModel: ScreenshotAssetModel?
    
    var panBegan = CGPoint(x:0, y:0)
    var panEnded = CGPoint(x:0, y:0)
    
    var selectedColor: UIColor = UIColor.red
    var selectedButtonState: Int = 0
    
    @IBOutlet weak var trayView: UIView!
    @IBOutlet weak var trayArrowButton: UIButton!
    @IBOutlet weak var trayToolsView: UIView!
    @IBOutlet weak var trayArrowImageView: UIImageView!
    let travViewClosedPeekOutDistance: CGFloat = 30
    var trayOriginalCenter: CGPoint!
    var trayDownOffset: CGFloat!
    var trayUp: CGPoint!
    var trayDown: CGPoint!
    var dragArrowLayer = CAShapeLayer()
    var dragDrawLayer = CAShapeLayer()
    
    var selectedTool = ToolsInTray(rawValue: 0) // Arrow tool by default
    
    var path: UIBezierPath = UIBezierPath()
    var shapeLayer: CAShapeLayer!
    
    var isTrayOpen: Bool = true
    var bottomConstraintStartY: CGFloat = 0.0
    var trayTravelDiff: CGFloat = 0.0
    
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
        //canvasImageView.image = UIImage.init(named: "sample")
        
        navigationItem.title = "Annotate Screenshot"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        dlog("screenshot: \(screenshotAssetModel)")
        
//        self.scrollView.minimumZoomScale = 0.5;
//        self.scrollView.maximumZoomScale = 6.0;
//        self.scrollView.contentSize = canvasImageView.frame.size;
//        self.scrollView.delegate = self;
        
        canvasImageView.image = screenshotAssetModel?.screenshotImage
        //canvasImageView.addBlurEffect()
        //canvasImageView.image = canvasImageView.image?.pixellated(scale: 20)
        
        // Gesture overload if we use swipes
        //navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Collage"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(goToGallery))
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
        
        // Gesture: Pan to track where arrow should go
        let drawPan = UIPanGestureRecognizer(target: self, action: #selector(onPan))
        view.addGestureRecognizer(drawPan)
        
        // Gesture: Tap to draw shapes
        let drawTap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        self.view.addGestureRecognizer(drawTap)
        
        // Tool Arrow is default
        if let foundView = view.viewWithTag(701) {
            changeTool(foundView as! UIButton)
        }
        
        toolButtonView.tag = 2
        toolButtonView.buttonDelegate = self
        toolButtonView.selectedColor = UIColor.red

        print("selectedTool = \(selectedTool)")
        
        setupToolbox()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        trayTravelDiff = trayViewHeightConstraint.constant - travViewClosedPeekOutDistance
        dlog("trayTravelDiff: \(trayTravelDiff)")
    }
    
    func setupToolbox() {
        colorSlider.thumbTintColor = selectedColor
        
        trayDownOffset = self.view.bounds.size.height-(trayView.frame.origin.y+38)
        trayUp = trayView.center
        trayDown = CGPoint(x: trayView.center.x ,y: trayView.center.y + trayDownOffset)
        
        //trayView.layer.shadowOffset = CGSize(0, 3);
        //trayView.layer.shadowRadius = 3;
        //trayView.layer.shadowOpacity = 0.5;
        
        //trayView.layer.borderWidth = 1
        //trayView.layer.borderColor = UIColor.black.cgColor
        
        // Put Tray into Down position
        /*
        UIView.animate(withDuration:0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options:[] ,
                       animations: { () -> Void in
                        self.trayView.center = self.trayDown
            }, completion: { (finished) -> Void in
                dlog("down")
            })*/
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
        //self.performSegue(withIdentifier: "GallerySegue", sender: self)
        dlog("diabled")
    }
    
    @IBAction func goToExport() {
        let jiraMgr = JiraManager(domainName: nil, username: nil, password: nil)
        if !jiraMgr.userLoggedIn() {
            self.performSegue(withIdentifier: "LoginSegue", sender: self)
        }
        else {
            self.performSegue(withIdentifier: "CreateIssueSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ExportSegue" {
            // Get a reference to the detail view controller
            let destinationViewController = segue.destination as! ExportViewController
            
            // Pass the flat canvas to export
            
            screenshotAssetModel?.editedImage = takeSnapshotOfView(view: canvasImageView)

            destinationViewController.screenshotAssetModel = screenshotAssetModel
        }
    }
    
    // MARK: - Gestures
    
    
    @IBAction func onCanvasViewPinch(_ sender: UIPinchGestureRecognizer) {
        
        dlog("sender.scale: \(sender.scale)")
        
        canvasImageView.transform = canvasImageView.transform.scaledBy(x: sender.scale, y: sender.scale)
        sender.scale = 1
    }
    
    // Using Simultaneous Gesture Recognizers
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @IBAction func onTrayPanGesture(_ sender: UIPanGestureRecognizer) {
        //let location = sender.location(in: view)
        let velocity = sender.velocity(in: view)
        let translation = sender.translation(in: view)
        
        if sender.state == .began {
            //trayOriginalCenter = trayView.center
            bottomConstraintStartY = self.trayViewBottomConstraint.constant
            //trayArrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat(180 * M_PI / 180))
        } else if sender.state == .changed {
            //trayView.center = CGPoint(x: trayOriginalCenter.x, y: trayOriginalCenter.y + translation.y)
            
            let newBottomConstraintY = bottomConstraintStartY - translation.y
            if newBottomConstraintY <= 0 && newBottomConstraintY >= -self.trayTravelDiff  {
                self.trayViewBottomConstraint.constant = newBottomConstraintY
                
                //let rotation = arrowRotationForTrayPan(translation: translation, velocity: velocity)
                //self.trayArrowImageView.transform = CGAffineTransform(rotationAngle: rotation)
                dlog("Gesture change at: \(translation), newConstraintY: \(newBottomConstraintY)")
            }
        } else if sender.state == .ended {
            //trayArrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat(0 * M_PI / 180))
            if velocity.y > 0 {
                self.closeMenu()
                /*
                UIView.animate(withDuration:0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options:[] ,
                               animations: { () -> Void in
                                self.trayView.center = self.trayDown
                }, completion: nil)
                 */
            } else {
                /*
                UIView.animate(withDuration:0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options:[] ,
                               animations: { () -> Void in
                                self.trayView.center = self.trayUp
                }, completion: nil)
                */
                self.openMenu()
            }
        }
    }
    
    @IBAction func onTrayArrowButtonTapped(sender: AnyObject) {
        dlog("")
        if isTrayOpen {
            closeMenu()
        }
        else {
            openMenu()
        }
    }
    
    func closeMenu() {
        if !isTrayOpen {
            return
        }
        let options: UIViewAnimationOptions = .curveEaseOut
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping:0.2, initialSpringVelocity:0.0, options: options,
                       animations: { () -> Void in
                        self.trayViewBottomConstraint.constant = (-self.trayViewHeightConstraint.constant + self.travViewClosedPeekOutDistance)
                        self.trayArrowImageView.transform = CGAffineTransform(rotationAngle: .pi)
                        self.view.layoutIfNeeded()
            },
                       completion: { (done: Bool) -> Void in
                        self.isTrayOpen = false
                        dlog("trayView bottom constraint: \(self.trayViewBottomConstraint.constant)")
        })
    }
    
    func openMenu() {
        if isTrayOpen {
            return
        }
        let options: UIViewAnimationOptions = .curveEaseInOut
        
        UIView.animate(withDuration: 0.3, delay: 0, options: options,
                       animations: { () -> Void in
                        self.trayViewBottomConstraint.constant = 0
                        self.trayArrowImageView.transform = CGAffineTransform(rotationAngle: 0.0)
                        self.view.layoutIfNeeded()
            },
                       completion: { (done: Bool) -> Void in
                        self.isTrayOpen = true
                        dlog("trayView bottom constraint: \(self.trayViewBottomConstraint.constant)")

                        
        })
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
        
        // Clear previous button backgrounds
        /*
        for view in trayToolsView.subviews as [UIView] {
            if let btn = view as? UIButton {
                btn.backgroundColor = UIColor.clear
                btn.tintColor = UIColor.blue
            }
        }
        */
        // Selected object has palette background color
        //sender.backgroundColor = trayView.backgroundColor
        //sender.tintColor = UIColor.white
        
        if sender.tag == 701 {
            // Arrow
            selectedTool = ToolsInTray(rawValue: 0)
        } else if sender.tag == 702 {
            // Text
            selectedTool = ToolsInTray(rawValue: 1)
        } else if sender.tag == 703 {
            // Circle
            selectedTool = ToolsInTray(rawValue: 2)
        } else if sender.tag == 704 {
            // Square
            selectedTool = ToolsInTray(rawValue: 3)
        } else if sender.tag == 705 {
            // Freehand
            selectedTool = ToolsInTray(rawValue: 4)
        } else if sender.tag == 706 {
            // Blur
            selectedTool = ToolsInTray(rawValue: 5)
        }
        print("changeTool.selectedTool = \(selectedTool)")
    }
    
    // MARK: - Draw
    
    func takeSnapshotOfView(view:UIView) -> UIImage? {
        UIGraphicsBeginImageContext(CGSize(width: view.frame.size.width, height: view.frame.size.height))
        view.drawHierarchy(in: CGRect(x: 0.0, y: 0.0, width: view.frame.size.width, height: view.frame.size.height), afterScreenUpdates: true) // <-- TODO? required?
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    @IBAction func didTap(_ sender: UITapGestureRecognizer) {
        print("tapped")
        print("didTap.sender.state = \(sender.state)")
        print("didTap.selectedTool = \(selectedTool)")
        
        let point = sender.location(in: canvasImageView) as CGPoint
        
        // Text
        if selectedTool == ToolsInTray.Text {
            let alert = UIAlertController(title: "Enter Text to Add", message: "", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.text = "Hello World!"
            }
            // Entry for text
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
                print("Text field: \(textField?.text)")
                
                let textView = TextView(origin: point, paletteColor: self.selectedColor)
                //let newImage = textView.textToImage(drawText: (textField?.text!)!, inImage: self.canvasImageView.image!)
                
                let newText = textView.generateText(drawText: (textField?.text!)!, inImage: self.canvasImageView!)
                self.canvasImageView.layer.addSublayer(newText)
            }))
            // Back out
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        // Square
        if selectedTool == ToolsInTray.Square {
            let shapeView = ShapeView(origin: point, paletteColor: self.selectedColor, shapeType: ShapeType.Square)
            self.canvasImageView.addSubview(shapeView)
        }
        
        // Circle
        if selectedTool == ToolsInTray.Circle {
            let shapeView = ShapeView(origin: point, paletteColor: self.selectedColor, shapeType: ShapeType.Circle)
            self.canvasImageView.addSubview(shapeView)
        }
        
        // Blur
        if selectedTool == ToolsInTray.Blur {
            let shapeView = ShapeView(origin: point, paletteColor: self.selectedColor, shapeType: ShapeType.Square)
            shapeView.applyPixelation(canvas: self.canvasImageView)
            self.canvasImageView.addSubview(shapeView)
        }
    }
    
    @IBAction func onPan(_ sender: UIPanGestureRecognizer) {
        print("panned")
        print("onPan.sender.state = \(sender.state)")
        
        //let translation = sender.translation(in: view)
        let point = sender.location(in: canvasImageView) as CGPoint
        //print("point = \(point)")
        
        if sender.state == UIGestureRecognizerState.began {
            print("onPan.began")
            panBegan = point as CGPoint
            print("panBegan = \(panBegan)")
            
            if selectedTool == ToolsInTray.Freehand {
                drawStartAtPoint(point: point)
            }
            
        } else if sender.state == .changed {
            print("onPan.changed")
            
            if selectedTool == ToolsInTray.Arrow {
                // draw the arrow as the gesture changes so user can see where they will be drawing the arrow
                // http://stackoverflow.com/questions/27117060/how-to-transform-a-line-during-pan-gesture-event
                CATransaction.begin()
                CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
                drawArrow(from: panBegan, to: point, layer: dragArrowLayer)
                CATransaction.commit()
            }
            
            if selectedTool == ToolsInTray.Freehand {
                drawContinueAtPoint(point: point)
            }
            
        } else if sender.state == UIGestureRecognizerState.ended {
            print("onPan.ended")
            
            if selectedTool == ToolsInTray.Arrow {
                panEnded = point as CGPoint
                print("tapEnded = \(panEnded)")
                print("tapBegan = \(panBegan)")
                
                // Draw Arrow
                drawArrow(from: panBegan, to: panEnded, layer: nil)
            }
        }
    }

    // MARK: Tracking an Arrow

    func drawArrow(from: CGPoint, to: CGPoint, layer: CAShapeLayer?) {
        // TODO: Should be set from Settings?
        let tailWidth = 10 as CGFloat
        let headWidth = 25 as CGFloat
        let headLength = 40 as CGFloat
        
        // CGPoint(x:10, y:10)
        // CGPoint(x:200, y:10)
        let arrow = UIBezierPath.arrow(from: from, to: to, tailWidth: tailWidth, headWidth: headWidth, headLength: headLength)
        
        var shapeLayer: CAShapeLayer
        shapeLayer = layer == nil ? CAShapeLayer() : layer!
        
        shapeLayer.path = arrow.cgPath
        //shapeLayer.fillColor = UIColor.red.cgColor
        shapeLayer.fillColor = selectedColor.cgColor // this is set by each pencil tap
        
        canvasImageView.layer.addSublayer(shapeLayer)
    }
    
    // MARK: Tracing a Line
    
    func drawStartAtPoint(point: CGPoint) {
        path = UIBezierPath()
        path.move(to: point)
        
        shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = selectedColor.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor // Note this has to be clear otherwise fill will form webs in between points
        shapeLayer.lineWidth = 4.0 //  TODO: Control the width of this line
        canvasImageView.layer.addSublayer(shapeLayer)
    }
    
    func drawContinueAtPoint(point: CGPoint) {
        path.addLine(to: point)
        shapeLayer.path = path.cgPath
    }
   
    // MARK: Drawing a path
    
    func drawPoint() {
        self.selectedColor.setStroke()
        self.path.lineWidth = 10.0 // TODO: Allow manipulation
        self.path.lineCapStyle = .round // TODO: Allow change to different styles
        self.path.stroke()
    }
    
    func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        self.selectedColor.setStroke()
        self.path.lineWidth = 10.0 // TODO: Allow manipulation
        self.path.lineCapStyle = .round // TODO: Allow change to different styles
        self.path.stroke()
        
        context?.addPath(self.path as! CGPath)
    }
    
    // MARK: Allows pinching of photo to resize it
    
    //func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    //    return self.canvasImageView
    //}
    
    //func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        // empty
    //}
    
    @IBAction func sliderChanged(sender: AnyObject) {
        let colorValue = colorArray[Int(colorSlider.value)]
        let selectedColor = UIColor(netHex: colorValue)
        selectedColorView.backgroundColor = selectedColor
        colorSlider.thumbTintColor = selectedColor
        self.selectedColor = selectedColor
        
        toolButtonView.selectedColor = selectedColor
        toolButtonView.refreshButtonColors(selectedButtonState: selectedButtonState)
    }

}

extension EditorViewController: HorizontalButtonViewDelegate {
    
    func onHButtonPressed(buttonView: HorizontalButtonView, button: UIButton) {
        dlog("btnView: \(buttonView.tag),  buttontag: \(button.tag)")
        
        selectedTool = ToolsInTray(rawValue: button.tag)
        selectedButtonState = button.tag
    }
}

