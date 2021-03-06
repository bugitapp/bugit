//
//  EditorViewController.swift
//  bugit
//
//  Created by Ernest on 11/12/16.
//  Copyright © 2016 BugIt App. All rights reserved.
//

import UIKit
import AVFoundation

enum ToolsInTray: Int {
    case Arrow
    case Text
    case Circle
    case Square
    case Freehand
    case Blur
    case Audio
}

class EditorViewController: UIViewController, UIScrollViewDelegate {

    //@IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var canvasImageView: UIImageView!
    var scaledCanvasImage: UIImage!
    
    @IBOutlet weak var trayViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var trayViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var toolButtonView: HorizontalButtonView!
    let colorArray = [ 0x000000, 0xfe0000, 0xff7900, 0xffb900, 0xffde00, 0xfcff00, 0xd2ff00, 0x05c000, 0x00c0a7, 0x0600ff, 0x6700bf, 0x9500c0, 0xbf0199, 0xffffff ]
    
    @IBOutlet weak var selectedColorView: UIView!
    @IBOutlet weak var colorSlider: UISlider!
    @IBOutlet weak var colorbarImageView: UIImageView!
    
    var textEntryView: UITextView!
    var screenshotAssetModel: ScreenshotAssetModel?
    var audioFilename: URL?
    
    var panBegan = CGPoint(x:0, y:0)
    var panEnded = CGPoint(x:0, y:0)
    
    var selectedColor: UIColor = UIColor.red
    var selectedButtonState: Int = 0
    
    @IBOutlet weak var trayView: UIView!
    @IBOutlet weak var trayArrowButton: UIButton!
    //@IBOutlet weak var trayToolsView: UIView!
    @IBOutlet weak var trayArrowImageView: UIImageView!
    let travViewClosedPeekOutDistance: CGFloat = 30
    //var trayOriginalCenter: CGPoint!
    //var trayDownOffset: CGFloat!
    //var trayUp: CGPoint!
    //var trayDown: CGPoint!
    var dragArrowLayer = CAShapeLayer()
    var dragDrawLayer = CAShapeLayer()
    
    var selectedTool = ToolsInTray(rawValue: 0) // Arrow tool by default
    
    var path: UIBezierPath = UIBezierPath()
    var shapeLayer: CAShapeLayer!
    
    var isTrayOpen: Bool = true
    var bottomConstraintStartY: CGFloat = 0.0
    var trayTravelDiff: CGFloat = 0.0
    static let inset: CGFloat = 2.0
    let textEntryViewInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)

    
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
        
        setupToolbox()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.closeMenu()
        
        trayTravelDiff = trayViewHeightConstraint.constant - travViewClosedPeekOutDistance
        dlog("trayTravelDiff: \(trayTravelDiff)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        dlog("screenshot scale: \(self.screenshotAssetModel?.screenshotImage?.scale)")
        let scaledCanvas = scaleImageToImageAspectFit(imageView: self.canvasImageView)
        
        self.scaledCanvasImage = scaledCanvas
    }

    
    func setupToolbox() {
        print("selectedTool = \(selectedTool)")
        
        toolButtonView.tag = 2
        toolButtonView.buttonDelegate = self
        toolButtonView.selectedColor = selectedColor
        selectedColorView.backgroundColor = selectedColor
        colorSlider.thumbTintColor = selectedColor
        
        let point = CGPoint(x:100, y:100)
        let tvRect = CGRect(origin: point, size: CGSize(width: 128.0, height: 128.0))
        textEntryView = UITextView(frame: tvRect)
        
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTextEntry(sender:)))
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTextEntry(sender:)))
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let toolbar = UIToolbar(frame: CGRect.zero)
        toolbar.items = [cancelItem, spaceItem, doneItem]
        toolbar.sizeToFit()
        textEntryView.inputAccessoryView = toolbar
        textEntryView.backgroundColor = UIColor.clear
        textEntryView.isHidden = true
        textEntryView.textColor = selectedColor
        textEntryView.font = defaultBodyFont
        textEntryView.keyboardType = .default
        textEntryView.autocapitalizationType = .sentences
        textEntryView.autocorrectionType = .no
        textEntryView.spellCheckingType = .no
        textEntryView.textContainerInset = textEntryViewInset
        textEntryView.layer.borderColor = UIColor.black.cgColor
        textEntryView.layer.borderWidth = 2.0
        textEntryView.layer.cornerRadius = 2.0
        
        canvasImageView.addSubview(textEntryView)
        
        trayView.layer.shadowOffset = CGSize(0, 3);
        trayView.layer.shadowRadius = 3;
        trayView.layer.shadowOpacity = 0.5;
        
        trayView.layer.borderWidth = 2
        trayView.layer.borderColor = UIColor.black.cgColor
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
        if segue.identifier == "CreateIssueSegue" {
            // Get a reference to the detail view controller
            let destinationViewController = segue.destination as! CreateIssueViewController
            
            // Pass the flat canvas to export
            
            screenshotAssetModel?.editedImage = takeSnapshotOfView(view: canvasImageView)

            destinationViewController.screenshotAssetModel = self.screenshotAssetModel
            destinationViewController.audioFilename = self.audioFilename
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
        
        UIView.animate(withDuration: 0.3, delay: 0, options: options,
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
    
    
    // MARK: - Draw
    
    func takeSnapshotOfView(view:UIView) -> UIImage? {
        UIGraphicsBeginImageContext(CGSize(width: view.frame.size.width, height: view.frame.size.height))
        view.drawHierarchy(in: CGRect(x: 0.0, y: 0.0, width: view.frame.size.width, height: view.frame.size.height), afterScreenUpdates: true) // <-- TODO? required?
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func scaleImageToImageAspectFit(imageView: UIImageView) -> UIImage? {
        
        if let img = imageView.image {
            dlog("origImageSize: \(img.size)")
            let rect = AVMakeRect(aspectRatio: img.size, insideRect: imageView.bounds)
            dlog("scaledImageRect: \(rect)")
            let scaledImage = img.simpleScale(newSize: rect.size)
            dlog("scaledImage: \(scaledImage)")
            return scaledImage
        }
        
        return nil
    }

    
    @IBAction func didTap(_ sender: UITapGestureRecognizer) {

        print("didTap.sender.state = \(sender.state)")
        print("didTap.selectedTool = \(selectedTool)")
        
        let point = sender.location(in: canvasImageView)
        
        // Text
        if selectedTool == ToolsInTray.Text {
            
            textEntryView.textColor = selectedColor
            textEntryView.frame.origin = point
            textEntryView.isHidden = false
            textEntryView.becomeFirstResponder()
            
        }
        // Square
        else if selectedTool == ToolsInTray.Square {
            let shapeView = ShapeView(origin: point, paletteColor: self.selectedColor, shapeType: ShapeType.Square)
            self.canvasImageView.addSubview(shapeView)
        }
        // Circle
        else if selectedTool == ToolsInTray.Circle {
            let shapeView = ShapeView(origin: point, paletteColor: self.selectedColor, shapeType: ShapeType.Circle)
            self.canvasImageView.addSubview(shapeView)
        }
        // Blur
        else if selectedTool == ToolsInTray.Blur {
            if let origImageSize = self.screenshotAssetModel?.screenshotImage?.size {
                
                let scaledRect = AVMakeRect(aspectRatio: origImageSize, insideRect: self.canvasImageView.bounds)
                let w:CGFloat = 100.0
                let h:CGFloat = 75.0
                let x:CGFloat = point.x - w/2.0
                let y:CGFloat = point.y - h/2.0
                
                if x >= scaledRect.origin.x {
                    
                    let placedRect = CGRect(x: x, y: y, width: w, height: h)
                    let pimageView = PixelatedImageView(frame: placedRect, image: scaledCanvasImage, regionSize: placedRect.size, containerBounds: self.canvasImageView.bounds)
                    
                    pimageView.applyPixelation()
                    self.canvasImageView.addSubview(pimageView)
                }
            }
        }
        // Audio
        else if selectedTool == ToolsInTray.Audio {
            // Show Audio controls on Tap?
        }
    }
    
    func cancelTextEntry(sender: AnyObject) {
        dlog("cancel")
        textEntryView.isHidden = true
        textEntryView.resignFirstResponder()
        textEntryView.text = nil
    }
    
    func doneTextEntry(sender: AnyObject) {
        //food for thot  http://stackoverflow.com/questions/746670/how-to-lose-margin-padding-in-uitextview
        let contentSize = textEntryView.contentSize
        dlog("done, contentSize: \(contentSize)")
        textEntryView.isHidden = true
        textEntryView.resignFirstResponder()
        let text = textEntryView.text
        textEntryView.text = nil

        if let entryText = text {
            var point = textEntryView.frame.origin
            point.x += textEntryView.textContainerInset.left + textEntryView.textContainer.lineFragmentPadding
            point.y += textEntryView.textContainerInset.left
            let textView = TextView(origin: point, size: contentSize, paletteColor: self.selectedColor)
            let newTextLayer = textView.generateText(drawText: entryText)
            textView.layer.addSublayer(newTextLayer)
            self.canvasImageView.addSubview(textView)
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
    
    internal func onHButtonPressed(buttonView: HorizontalButtonView, button: UIButton) {
        dlog("btnView: \(buttonView.tag),  buttontag: \(button.tag)")
        
        selectedTool = ToolsInTray(rawValue: button.tag)
        selectedButtonState = button.tag
    }
    
    internal func onAudioRecorded(audioFilename: URL) {
        dlog("audioFilename: \(audioFilename)")
        
        self.audioFilename = audioFilename
    }
    
}
