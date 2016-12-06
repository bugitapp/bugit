//
//  CreateIssueViewController.swift
//  bugit
//
//  Created by Bipin Pattan on 12/3/16.
//  Copyright © 2016 BugIt App. All rights reserved.
//

import UIKit
import MBProgressHUD

class CreateIssueViewController: UITableViewController, SelectionViewControllerDelegate {

    var project: String?
    var issueType: String?
    var issuePriority: String?
    var screenshotAssetModel: ScreenshotAssetModel?
    var audioFilename: URL?
    let jiraMgr = JiraManager(domainName: nil, username: nil, password: nil)
    var availableProjects: [ProjectsModel]?
    var availableIssueTypes: [IssueTypeModel]?
    var availablePriorityTypes: [PriorityTypeModel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        startNetworkActivity()
    }

    func setupUI() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(createJiraIssue))
    }
    
    func startNetworkActivity() {
        jiraMgr.loadProjects(success: { (projects: [ProjectsModel]) in
            self.availableProjects = projects
            self.project = projects[0].key
            self.tableView.reloadData()
            }, failure: { (error: NSError) in
                
        })
        jiraMgr.loadIssueTypes(success: { (issueTypes: [IssueTypeModel]) in
            self.availableIssueTypes = issueTypes
            self.issueType = issueTypes[0].name
            self.tableView.reloadData()
            }, failure: { (error: NSError) in
                
        })
        jiraMgr.loadPriorities(success: { (priorityTypes: [PriorityTypeModel]) in
            self.availablePriorityTypes = priorityTypes
            self.issuePriority = priorityTypes[0].name
            self.tableView.reloadData()
            }, failure: { (error: NSError) in
                
        })
    }
    
    func createJiraIssue() {
        print("Create Jira Issue")
        let issueModel = IssueModel()

        let projectCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! SelectionCell
        issueModel.project = projectCell.valueLabel.text
        
        let typeCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! SelectionCell
        issueModel.issueTypeId = typeCell.valueLabel.text
        
        let priorityCell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! SelectionCell
        issueModel.priority = priorityCell.valueLabel.text
        
        let summaryCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! TextViewCell
        issueModel.summary = summaryCell.infoTextView.text

        let descriptionCell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as! TextViewCell
        let environmentCell = tableView.cellForRow(at: IndexPath(row: 0, section: 3)) as! TextViewCell
        issueModel.issueDescription = descriptionCell.infoTextView.text + environmentCell.infoTextView.text
        
        jiraMgr.createIssue(issue: issueModel,
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if (indexPath.row == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell", for: indexPath) as! SelectionCell
                cell.tag = indexPath.row
                let projValue = project == nil ? "-" : project
                cell.config(key: "Project", value: projValue)
                return cell
            } else if (indexPath.row == 1) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell", for: indexPath) as! SelectionCell
                cell.tag = indexPath.row
                let typeValue = issueType == nil ? "-" : issueType
                cell.config(key: "Type", value: typeValue)
                return cell
            } else if (indexPath.row == 2) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell", for: indexPath) as! SelectionCell
                cell.tag = indexPath.row
                let priorityValue = issuePriority == nil ? "-" : issuePriority
                cell.config(key: "Priority", value: priorityValue)
                return cell
            }
        } else if indexPath.section == 1 || indexPath.section == 2 || indexPath.section == 3  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath) as! TextViewCell
            return cell
        } else if indexPath.section == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! ImageViewCell
            cell.annotatedImageView.image = screenshotAssetModel?.editedImage
            return cell
        }
        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Summary"
        } else if section == 2 {
            return "Description"
        } else if section == 3 {
            return "Environment"
        } else if section == 4 {
            return "Attachment"
        }
        return ""
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section < 1 {
            return 60.0
        } else if indexPath.section < 4 {
            return 100.0
        }
        return 420.0
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "MakeSelectionSegue", sender: self)
    }
    
    internal func selectionViewController(vc: SelectionViewController!, didSelectOption option: String!) {
        if vc.context == 0 {
            project = option
            tableView.reloadData()
        } else if vc.context == 1 {
            issueType = option
            tableView.reloadData()
        } else if vc.context == 2 {
            issuePriority = option
            tableView.reloadData()
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MakeSelectionSegue" {
            // Get a reference to the detail view controller
            let selectionViewController = segue.destination as! SelectionViewController
            selectionViewController.context = tableView.indexPathForSelectedRow?.row
            selectionViewController.delegate = self
            let selectedIndexPath = tableView.indexPathForSelectedRow
            if selectedIndexPath?.section == 0 {
                // projects selection
                if selectedIndexPath?.row == 0 {
                    var options = [String]()
                    for proj in availableProjects! {
                        options.append(proj.key!)
                    }
                    selectionViewController.options = options
                    selectionViewController.selectedOption = project
                }
                // issue type selection
                else if selectedIndexPath?.row == 1 {
                    var options = [String]()
                    for issueType in availableIssueTypes! {
                        options.append(issueType.name!)
                    }
                    selectionViewController.options = options
                    selectionViewController.selectedOption = issueType
                }
                // priority selection
                else if selectedIndexPath?.row == 2 {
                    var options = [String]()
                    for priorityType in availablePriorityTypes! {
                        options.append(priorityType.name!)
                    }
                    selectionViewController.options = options
                    selectionViewController.selectedOption = issuePriority
                }
            }
        }
    }

}
