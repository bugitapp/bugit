//
//  CreateIssueViewController.swift
//  bugit
//
//  Created by Bipin Pattan on 12/3/16.
//  Copyright © 2016 BugIt App. All rights reserved.
//

import UIKit

class CreateIssueViewController: UITableViewController {

    var project: ProjectsModel?
    var issueType: IssueTypeModel?
    var issuePriority: PriorityTypeModel?
    var screenshotAssetModel: ScreenshotAssetModel?
    let jiraMgr = JiraManager(domainName: nil, username: nil, password: nil)
    var availableProjects: [ProjectsModel]?
    var availableIssueTypes: [IssueTypeModel]?
    var availablePriorityTypes: [PriorityTypeModel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        startNetworkActivity()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func setupUI() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
    }
    
    func startNetworkActivity() {
        jiraMgr.loadProjects(success: { (projects: [ProjectsModel]) in
            self.availableProjects = projects
            self.project = projects[0]
            self.tableView.reloadData()
            }, failure: { (error: NSError) in
                
        })
        jiraMgr.loadIssueTypes(success: { (issueTypes: [IssueTypeModel]) in
            self.availableIssueTypes = issueTypes
            self.issueType = issueTypes[0]
            self.tableView.reloadData()
            }, failure: { (error: NSError) in
                
        })
        jiraMgr.loadPriorities(success: { (priorityTypes: [PriorityTypeModel]) in
            self.availablePriorityTypes = priorityTypes
            self.issuePriority = priorityTypes[0]
            self.tableView.reloadData()
            }, failure: { (error: NSError) in
                
        })
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
                let projValue = project?.key == nil ? "-" : project?.key
                cell.config(key: "Project", value: projValue)
                return cell
            } else if (indexPath.row == 1) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell", for: indexPath) as! SelectionCell
                let typeValue = issueType?.name == nil ? "-" : issueType?.name
                cell.config(key: "Type", value: typeValue)
                return cell
            } else if (indexPath.row == 2) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell", for: indexPath) as! SelectionCell
                let priorityValue = issuePriority?.name == nil ? "-" : issuePriority?.name
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
        }
        return ""
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "MakeSelectionSegue", sender: self)
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
            let destinationViewController = segue.destination as! SelectionViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow
            if selectedIndexPath?.section == 0 {
                if selectedIndexPath?.row == 0 {
                    var options = [String]()
                    for proj in availableProjects! {
                        options.append(proj.name!)
                    }
                    destinationViewController.options = options
                }
            }
        }
    }

}
