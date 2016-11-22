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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Need to do this otherwise it unwraps Nil on previous prepare for segue
        flatCanvasImageView.image = flatCanvasImage
        
        let titleLabel = UILabel()
        let titleText = NSAttributedString(string: "Export", attributes: [
            NSFontAttributeName : UIFont(name: "SFUIText-Light", size: 21)!,
            NSForegroundColorAttributeName : UIColor.darkText
            ])
        titleLabel.attributedText = titleText
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
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
                                               success: {
                                                print("Got issue metadata")
        }) { (error: NSError) in
            print("Erorr creating issue: \(error)")
        }
    }
    
    @IBAction func onAttachImageTapped(_ sender: AnyObject) {
        let issue = IssueModel()
        
        JiraManager.sharedInstance.attach2(image: UIImage(named: "sample"), issue: issue, success: {
            print("Attached image")
        }) { (error: NSError) in
            print("Erorr attaching image: \(error)")
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
