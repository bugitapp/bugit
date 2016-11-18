//
//  IssueModel.swift
//  bugit
//
//  Created by Bipin Pattan on 11/17/16.
//  Copyright © 2016 BugIt App. All rights reserved.
//

import UIKit

class IssueModel: NSObject {
    var project: String?
    var issueTypeId: String?
    var summary: String?
    var issueDescription: String?
    var assignee: String?
    var reporter: String?
    var priority: String?
    var labels: [String]?
    var environment: String?
    var components: [String : String]?
    
}
