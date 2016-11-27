//
//  IssueModel.swift
//  bugit
//
//  Created by Bipin Pattan on 11/17/16.
//  Copyright © 2016 BugIt App. All rights reserved.
//

import UIKit

class IssueModel: NSObject {
    var key: String?
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
    
    func toJSON() -> Dictionary<String, Any> {
        var json = Dictionary<String, Any>()
        if let project = project {
            json["project"] = ["key" : project]
        }
        if let summary = summary {
            json["summary"] = summary
        }
        if let assignee = assignee {
            json["assignee"] = assignee
        }
        if let reporter = reporter {
            json["reporter"] = reporter
        }
        if let labels = labels {
            json["labels"] = labels
        }
        if let environment = environment {
            json["environment"] = environment
        }
        if let issueDescription = issueDescription {
            json["description"] = issueDescription
        }
        if let issueType = issueTypeId {
            json["issuetype"] = ["name" : issueType]
        }
        var fields = Dictionary<String, Any>()
        fields["fields"] = json
        return fields
    }
}
