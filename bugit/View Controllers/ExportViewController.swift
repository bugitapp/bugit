//
//  ExportViewController.swift
//  bugit
//
//  Created by Ernest on 11/12/16.
//  Copyright © 2016 BugIt App. All rights reserved.
//

import UIKit

class ExportViewController: UIViewController {
    
    @IBOutlet weak var flatCanvasImageView: UIImageView!
    var flatCanvasImage: UIImage? = nil
    
    @IBOutlet weak var trayView: UIView!
    @IBOutlet weak var trayArrowImageView: UIButton!
    
    var trayOriginalCenter: CGPoint!
    var trayDownOffset: CGFloat!
    var trayUp: CGPoint!
    var trayDown: CGPoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Need to do this otherwise it unwraps Nil on previous prepare for segue
//        flatCanvasImageView.image = flatCanvasImage
        
        let titleLabel = UILabel()
        let titleText = NSAttributedString(string: "Export", attributes: [
            NSFontAttributeName : UIFont(name: "SFUIText-Light", size: 21)!,
            NSForegroundColorAttributeName : UIColor.darkText
            ])
        titleLabel.attributedText = titleText
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
        
        setupToolbox()
    }
    
    func setupToolbox() {
//        trayDownOffset = self.view.bounds.size.height-(trayView.frame.origin.y+38)
//        trayUp = trayView.center
//        trayDown = CGPoint(x: trayView.center.x ,y: trayView.center.y + trayDownOffset)
//        
//        trayView.layer.borderWidth = 1
//        trayView.layer.borderColor = UIColor.black.cgColor
//        
//        // Put Tray into Down position
//        UIView.animate(withDuration:0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options:[] ,
//                       animations: { () -> Void in
//                        self.trayView.center = self.trayDown
//        }, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// MARK: - Outlets
    
    @IBAction func onGetIssueMetadataTapped(_ sender: AnyObject) {
        JiraManager.sharedInstance.projects(success: { (projects: [String]) in
            
        }) { (error: Error) in
            
        }
    }

    @IBAction func onCreateIssueTapped(_ sender: AnyObject) {
        let issue = IssueModel()
        issue.project = "TPO"
        issue.issueTypeId = "Bug"
        issue.summary = "Fox jumps over dog"
        issue.issueDescription = "A quick brown fox jumped over the lazy dog."
        issue.labels = ["canines"]
        JiraManager.sharedInstance.createIssue(issue: issue,
                                               success: { (issue: IssueModel) in
                                                print("Created Issue: \(issue)")
                                                JiraManager.sharedInstance.attach(image: UIImage(named: "sample") , issue: issue, success: {
                                                    print("Attached image to \(issue)")
                                                }) { (error: Error) in
                                                    print("Erorr attaching image: \(error)")
                                                }
        }) { (error: Error) in
            print("Erorr creating issue: \(error)")
        }
    }
    
    @IBAction func onAttachImageTapped(_ sender: AnyObject) {
        let issue = IssueModel()
        issue.key = "TPO-4"
    }
    
    // MARK: - Preview Tray

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
                UIView.animate(withDuration:0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options:[] ,
                               animations: { () -> Void in
                                self.trayView.center = self.trayDown
                }, completion: nil)
            } else {
                UIView.animate(withDuration:0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options:[] ,
                               animations: { () -> Void in
                                self.trayView.center = self.trayUp
                }, completion: nil)
            }
        }
    }

}
