//
//  ExportViewController.swift
//  bugit
//
//  Created by Ernest on 11/12/16.
//  Copyright © 2016 BugIt App. All rights reserved.
//

import UIKit
import MBProgressHUD

class ExportViewController: UIViewController {
    
    @IBOutlet weak var projectButton: UIButton!
    @IBOutlet weak var issueTypeButton: UIButton!
    @IBOutlet weak var priority: UIButton!
    @IBOutlet weak var labelsTextField: UITextField!
    @IBOutlet weak var environmentTextView: UITextView!
    @IBOutlet weak var summaryTextView: UITextView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var attachmentImageView: UIImageView!
    @IBOutlet weak var flatCanvasImageView: UIImageView!
    var flatCanvasImage: UIImage? = nil
    var screenshotAssetModel: ScreenshotAssetModel?
    let jiraMgr = JiraManager(domainName: nil, username: nil, password: nil)
    @IBOutlet weak var trayView: UIView!
    @IBOutlet weak var trayArrowImageView: UIButton!
    
    var trayOriginalCenter: CGPoint!
    var trayDownOffset: CGFloat!
    var trayUp: CGPoint!
    var trayDown: CGPoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        startNetworkActivity()
    }
    
    func setupUI() {
        let titleLabel = UILabel()
        let titleText = NSAttributedString(string: "Export", attributes: [
            NSFontAttributeName : UIFont(name: "SFUIText-Light", size: 21)!,
            NSForegroundColorAttributeName : UIColor.darkText
            ])
        titleLabel.attributedText = titleText
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
        
        dlog("screenshot: \(screenshotAssetModel)")
        attachmentImageView.image = screenshotAssetModel?.editedImage
    }
    
    func startNetworkActivity() {
        jiraMgr.loadProjects(success: { (projects: [ProjectsModel]) in
                if projects.count != 0 {
                    self.projectButton.setTitle(projects[0].key, for: UIControlState.normal)
                }
            }, failure: { (error: NSError) in
                
        })
        jiraMgr.loadIssueTypes(success: { (issueTypes: [IssueTypeModel]) in
            if issueTypes.count != 0 {
                self.issueTypeButton.setTitle(issueTypes[0].name, for: UIControlState.normal)
                self.issueTypeButton.tag = issueTypes[0].id!
            }
            }, failure: { (error: NSError) in
                
        })
        jiraMgr.loadPriorities(success: { (priorityTypes: [PriorityTypeModel]) in
            if priorityTypes.count != 0 {
                self.priority.setTitle(priorityTypes[0].name, for: UIControlState.normal)
            }
            }, failure: { (error: NSError) in
                
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// MARK: - Outlets
    
    @IBAction func onCreateIssueTapped(_ sender: AnyObject) {
        let issue = IssueModel()
        issue.project = projectButton.currentTitle
        issue.issueTypeId = issueTypeButton.currentTitle
        issue.summary = summaryTextView.text
        issue.issueDescription = descriptionTextView.text
//        issue.environment = environmentTextView.text
        
        jiraMgr.createIssue(issue: issue,
                            success: { (issue: IssueModel) in
                            print("Created Issue: \(issue)")
                            self.jiraMgr.attach(image: self.screenshotAssetModel?.editedImage , issue: issue, success: {
                                MBProgressHUD.hide(for: self.view, animated: true)
                                print("Attached image to \(issue)")
                            }) { (error: Error) in
                                MBProgressHUD.hide(for: self.view, animated: true)
                                print("Erorr attaching image: \(error)")
                            }
                            }) { (error: Error) in
                                print("Erorr creating issue: \(error)")
                            }
        MBProgressHUD.showAdded(to: self.view, animated: true)
    }
}
