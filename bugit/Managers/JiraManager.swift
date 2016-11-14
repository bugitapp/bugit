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
    static let authHeader = "Authorization"
    
    static let sharedInstance = JiraManager(baseURL: URL(string: "https://bugitapp.atlassian.net/rest/api/2"))
    
    func projects(success: @escaping ([String]) -> (), failure: @escaping (NSError) -> ()) {
        requestSerializer.setValue(credentails(withUsername: "junkbipin@yahoo.com", withPassword: "bugit"), forHTTPHeaderField: JiraManager.authHeader)
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

    func credentails(withUsername name: String!, withPassword password: String!) -> String {
        return "Basic " + base64Encode(value: name + ":" + password)
    }
    
    func base64Encode(value: String!) -> String {
        return Data(value.utf8).base64EncodedString()
    }
}
