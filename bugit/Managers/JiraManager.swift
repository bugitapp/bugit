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
        requestSerializer.setValue("no-check", forHTTPHeaderField: "X-Atlassian-Token")
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
    
    func attach2(image: UIImage!, issue: IssueModel, success: @escaping () -> (), failure: @escaping (NSError) -> ()) {
        
        let imageData = UIImagePNGRepresentation(image)
        _ = post("https://bugitapp.atlassian.net/rest/api/2/issue/TPO-2/attachments", parameters: nil,
            constructingBodyWith: { (formData: AFMultipartFormData) in
//                formData.appendPart(withFileData: imageData!, name: "screenshot", fileName: "screenshot.png", mimeType: "image/png")
//                formData.appendPart(withHeaders: nil, body: imageData!)
                formData.appendPart(withForm: imageData!, name: "screenShot.png")
            }, progress: { (progress: Progress) in
                print(progress)
            }, success: { (task: URLSessionDataTask, response: Any?) in
                print(("Task: \(task)"))
                print(("Response: \(response.debugDescription)"))
            }, failure: { (task: URLSessionDataTask?, error: Error) in
                print(("Task: \(task)"))
                print(("Error: \(error)"))
                
        })
    }
    
    func createTempDirectory() -> String? {
        let tempDirectoryTemplate = NSTemporaryDirectory() + "images"
        
        let fileManager = FileManager.default
        
        try! fileManager.createDirectory(atPath: tempDirectoryTemplate, withIntermediateDirectories: true, attributes: nil)
        return tempDirectoryTemplate
    }
    
    func uploadScreenshot(image: UIImage!, issue: IssueModel, success: @escaping () -> (), failure: @escaping (NSError) -> ()) {
        let imageData = UIImageJPEGRepresentation(image, 1.0)!
        let tmpFileName = "\(NSDate.timeIntervalSinceReferenceDate)"
        let tmpFileURL = NSURL(fileURLWithPath:createTempDirectory()!).appendingPathComponent(tmpFileName)
        try? imageData.write(to: tmpFileURL!)
        let req = requestSerializer.multipartFormRequest(withMethod: "POST", urlString:"https://bugitapp.atlassian.net/rest/api/2/issue/TPO-2/attachments", parameters: nil, constructingBodyWith: { (formData) -> Void in
            try! formData.appendPart(withFileURL: tmpFileURL!, name: "screen_shot", fileName: "screenshot.jpg", mimeType: "image/jpeg")
        }, error: nil)
        req.setValue("no-check", forHTTPHeaderField: "X-Atlassian-Token")
        req.setValue(credentails(withUsername: "junkbipin@yahoo.com", withPassword: "bugit"), forHTTPHeaderField: JiraManager.authHeader)

        let uploadTask = self.uploadTask(with: req as URLRequest, fromFile: tmpFileURL!, progress: nil, completionHandler: { (response, object, error) -> Void in
                
                print(response)
            
                if error != nil {
                    print(error)
                } else {
                    print(object)
                }
                try! FileManager.default.removeItem(at: tmpFileURL!)
            })
            
        // Start the file upload.
        uploadTask.resume()
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
