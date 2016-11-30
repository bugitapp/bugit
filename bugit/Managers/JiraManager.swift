//
//  JiraManager.swift
//  bugit
//
//  Created by Bipin Pattan on 11/13/16.
//  Copyright © 2016 BugIt App. All rights reserved.
//

import UIKit
import AFNetworking

extension Data {
    
    /// Append string to NSMutableData
    ///
    /// Rather than littering my code with calls to `dataUsingEncoding` to convert strings to NSData, and then add that data to the NSMutableData, this wraps it in a nice convenient little extension to NSMutableData. This converts using UTF-8.
    ///
    /// - parameter string:       The string to be added to the `NSMutableData`.
    
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

class JiraManager: AFHTTPSessionManager {
    static let projectsPath = "project"
    static let issueMetadataPath = "issue/createmeta"
    static let issueCreatePath = "issue"
    static let authHeader = "Authorization"
    
    static var jiraUrl: URL?
    static var userName: String?
    static var password: String?
    
    init(domainName domain: String!, username name: String!, password pwd: String!) {
        JiraManager.jiraUrl = URL(string: "https://\(domain!)/rest/api/2")
        super.init(baseURL: JiraManager.jiraUrl, sessionConfiguration: nil)
        JiraManager.userName = name
        JiraManager.password = pwd
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
    
    func createIssue(issue: IssueModel, success: @escaping (IssueModel) -> (), failure: @escaping (Error) -> ()) {
        var issueData : Data?
        do {
            issueData = try JSONSerialization.data(withJSONObject: issue.toJSON(), options: [])
            let issueString = String(data: issueData!, encoding: .utf8)
            print("Post Data: \(issueString!)")
        }
        catch {
            print(error.localizedDescription)
        }
        
        let url = URL(string: "\(JiraManager.jiraUrl)/issue")
        var request = URLRequest(url: url!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(credentails(withUsername: JiraManager.userName, withPassword: JiraManager.password), forHTTPHeaderField: JiraManager.authHeader)
        request.httpMethod = "POST"
        request.httpBody = issueData
        
        let issueTask = dataTask(with: request) { (response: URLResponse, obj: Any?, error: Error?) in
            print("Response: \(response)")
            print("Object: \(obj)")
            print("Object: \(error)")
            guard error == nil else {
                // handle error here
                print(error!)
                DispatchQueue.main.async {
                    failure(error!)
                }
                return
            }
            // if response was JSON, then parse it            
            let responseDictionary = obj as! NSDictionary
            print("success == \(responseDictionary)")
            issue.fromJSON(dict: responseDictionary as! Dictionary<String, Any>)
            success(issue)
        }
        issueTask.resume()
    }
    
    func attach(image: UIImage!, issue: IssueModel!, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        
        let request: URLRequest
        
        do {
            request = try createRequest(image: image, issue: issue)
        } catch {
            print(error)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                // handle error here
                print(error!)
                DispatchQueue.main.async {
                    failure(error!)
                }
                return
            }
            
            // if response was JSON, then parse it
            
            do {
                let responseDictionary = try JSONSerialization.jsonObject(with: data!)
                print("success == \(responseDictionary)")
                DispatchQueue.main.async {
                    success()
                }
            } catch {
                print(error)
                let responseString = String(data: data!, encoding: .utf8)
                print("responseString = \(responseString)")
                DispatchQueue.main.async {
                    failure(error)
                }
            }
        }
        task.resume()
    }
    
    func createRequest(image: UIImage!, issue: IssueModel!) throws -> URLRequest {
        let parameters = [String : String]()  // build your dictionary however appropriate
        
        let boundary = generateBoundaryString()
        
        let url = URL(string: "https://bugitapp.atlassian.net/rest/api/2/issue/\(issue.key!)/attachments")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; name='file'; filename='screenshot.jpg'; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("no-check", forHTTPHeaderField: "X-Atlassian-Token")
        request.setValue(credentails(withUsername: JiraManager.userName, withPassword: JiraManager.password), forHTTPHeaderField: JiraManager.authHeader)
        request.httpBody = try createBody(with: parameters, filePathKey: "file", image: image, boundary: boundary)
        
        return request
    }
    
    /// Create body of the multipart/form-data request
    ///
    /// - parameter parameters:   The optional dictionary containing keys and values to be passed to web service
    /// - parameter filePathKey:  The optional field name to be used when uploading files. If you supply paths, you must supply filePathKey, too.
    /// - parameter paths:        The optional array of file paths of the files to be uploaded
    /// - parameter boundary:     The multipart/form-data boundary
    ///
    /// - returns:                The NSData of the body of the request
    
    func createBody(with parameters: [String: String]?, filePathKey: String, image: UIImage, boundary: String) throws -> Data {
        var body = Data()
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.append("\(value)\r\n")
            }
        }
        
        let data = UIImageJPEGRepresentation(image, 1.0)!
        let mimetype = "image/jpg"
        
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(filePathKey)\"; filename=\"screenshot.jpg\"\r\n")
        body.append("Content-Type: \(mimetype)\r\n\r\n")
        body.append(data)
        body.append("\r\n")
        
        body.append("--\(boundary)--\r\n")
        return body
    }
    
    /// Create boundary string for multipart/form-data request
    ///
    /// - returns:            The boundary string that consists of "Boundary-" followed by a UUID string.
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    /// Determine mime type on the basis of extension of a file.
    ///
    /// This requires MobileCoreServices framework.
    ///
    /// - parameter path:         The path of the file for which we are going to determine the mime type.
    ///
    /// - returns:                Returns the mime type if successful. Returns application/octet-stream if unable to determine mime type.
    
    func mimeType(for path: String) -> String {
        let url = NSURL(fileURLWithPath: path)
        let pathExtension = url.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension! as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream";
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
