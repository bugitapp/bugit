//
//  JiraManager.swift
//  bugit
//
//  Created by Bipin Pattan on 11/13/16.
//  Copyright © 2016 BugIt App. All rights reserved.
//

import UIKit
import AFNetworking

class JiraManager: AFHTTPSessionManager {
    static let projectsPath = "project"
    static let issueMetadataPath = "issue/createmeta"
    static let issueCreatePath = "issue"

    static let authHeader = "Authorization"
    
    static let sharedInstance = JiraManager(baseURL: URL(string: "https://bugitapp.atlassian.net/rest/api/2"), username: "junkbipin@yahoo.com", password: "bugit")
    
    init(baseURL url: URL?, username name: String!, password pwd: String!) {
        super.init(baseURL: url, sessionConfiguration: nil)
        addAuthHeader(withUsername: name, withPassword: pwd)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func projects(success: @escaping ([String]) -> (), failure: @escaping (NSError) -> ()) {
        _ = get(JiraManager.projectsPath, parameters: nil, progress: nil,
                success: { (task: URLSessionDataTask, response: Any?) in
                    print("Task: \(task) Projects: \(response)")
                    success([])
            },
                failure: { (task:URLSessionDataTask?, error: Error) in
                    print("Error: \(error)")
                    failure(error as NSError)
        })
    }

    func projectDetails(withProjectKey projectKey: String!, success: @escaping ([String]) -> (), failure: @escaping (NSError) -> ()) {
        _ = get(JiraManager.projectsPath + "/\(projectKey!)", parameters: nil, progress: nil,
                success: { (task: URLSessionDataTask, response: Any?) in
                    print("Task: \(task) Project Details: \(response)")
                    success([])
            },
                failure: { (task:URLSessionDataTask?, error: Error) in
                    print("Error: \(error)")
                    failure(error as NSError)
        })
    }
    
    func issueMetadata(success: @escaping () -> (), failure: @escaping (NSError) -> ()) {
        _ = get(JiraManager.issueMetadataPath, parameters: nil, progress: nil,
                success: { (task: URLSessionDataTask, response: Any?) in
                    print("Task: \(task) Projects: \(response)")
                    success()
            },
                failure: { (task:URLSessionDataTask?, error: Error) in
                    print("Error: \(error)")
                    failure(error as NSError)
        })
    }
    
    func createIssue(issue: IssueModel, success: @escaping () -> (), failure: @escaping (NSError) -> ()) {
        var issueData : Data?
        do {
            issueData = try JSONSerialization.data(withJSONObject: issue.toJSON(), options: [])
            let issueString = String(data: issueData!, encoding: .utf8)
            print("Post Data: \(issueString!)")
        }
        catch {
            print(error.localizedDescription)
        }
        
        let url = URL(string: "https://bugitapp.atlassian.net/rest/api/2/issue")
        var req = URLRequest(url: url!)
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue(credentails(withUsername: "junkbipin@yahoo.com", withPassword: "bugit"), forHTTPHeaderField: JiraManager.authHeader)
        req.httpMethod = "POST"
        req.httpBody = issueData
        
        let issueTask = dataTask(with: req) { (response: URLResponse, obj: Any?, error: Error?) in
            print("Response: \(response)")
            print("Object: \(obj)")
            print("Object: \(error)")
        }
        issueTask.resume()
    }
    
    func addAuthHeader(withUsername name: String!, withPassword password: String!) {
        requestSerializer.setValue(credentails(withUsername: name, withPassword: password), forHTTPHeaderField: JiraManager.authHeader)
    }
    
    func credentails(withUsername name: String!, withPassword password: String!) -> String {
        return "Basic " + base64Encode(value: name + ":" + password)
    }
    
    func base64Encode(value: String!) -> String {
        return Data(value.utf8).base64EncodedString()
    }
}
