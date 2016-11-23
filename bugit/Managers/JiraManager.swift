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
                formData.appendPart(withHeaders: ["X-Atlassian-Token" : "nocheck", "Authorization" : "Basic anVua2JpcGluQHlhaG9vLmNvbTpidWdpdA==", "form-data; name='file'; filename='screenshot.jpg'" : "Content-Disposition", "Accept" : "*/*"], body: imageData!)
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
        let tmpFileName = "\(NSDate.timeIntervalSinceReferenceDate).jpg"
        let tmpFileURL = NSURL(fileURLWithPath:createTempDirectory()!).appendingPathComponent(tmpFileName)
        try? imageData.write(to: tmpFileURL!)

        var errorPtr: NSErrorPointer = nil
        let req = requestSerializer.multipartFormRequest(withMethod: "POST", urlString:"https://bugitapp.atlassian.net/rest/api/2/issue/TPO-2/attachments", parameters: nil, constructingBodyWith: { (formData: AFMultipartFormData) -> Void in
            do {
                try formData.appendPart(withFileURL: tmpFileURL!, name: "file", fileName: "screenshot.jpg", mimeType: "image/jpeg")
            }
            catch {
                print("Something went wrong.")
            }
        }, error: errorPtr)
        if let err = errorPtr?.pointee {
            print(err)
        }
        req.setValue("no-check", forHTTPHeaderField: "X-Atlassian-Token")
        req.setValue("Keep-Alive", forHTTPHeaderField: "Connection")
        req.setValue("100-continue", forHTTPHeaderField: "Expect")
        req.setValue("*/*", forHTTPHeaderField: "Accept")
        req.setValue("form-data; name='file'; filename='screenshot.jpg'", forHTTPHeaderField: "Content-Disposition")
        req.setValue(credentails(withUsername: "junkbipin@yahoo.com", withPassword: "bugit"), forHTTPHeaderField: JiraManager.authHeader)

        let urlReq = req as URLRequest
        print("Request = \(urlReq)")
        let uploadFileTask = uploadTask(with: urlReq as URLRequest, fromFile: tmpFileURL!, progress: nil, completionHandler: { (response, object, error) -> Void in
                
                print(response)
            
                if error != nil {
                    print(error)
                } else {
                    print(object)
                }
                try! FileManager.default.removeItem(at: tmpFileURL!)
            })
            
        // Start the file upload.
        uploadFileTask.resume()
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
    
    func attach(image: UIImage!, issue: IssueModel, success: @escaping () -> (), failure: @escaping (NSError) -> ()) {
        
        let request: URLRequest
        
        do {
            request = try createRequest(image: image)
        } catch {
            print(error)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                // handle error here
                print(error!)
                return
            }
            
            // if response was JSON, then parse it
            
            do {
                let responseDictionary = try JSONSerialization.jsonObject(with: data!)
                print("success == \(responseDictionary)")
                
                // note, if you want to update the UI, make sure to dispatch that to the main queue, e.g.:
                //
                // DispatchQueue.main.async {
                //     // update your UI and model objects here
                // }
            } catch {
                print(error)
                
                let responseString = String(data: data!, encoding: .utf8)
                print("responseString = \(responseString)")
            }
        }
        task.resume()
    }
    
    func createRequest(image: UIImage!) throws -> URLRequest {
        let parameters = [String : String]()  // build your dictionary however appropriate
        
        let boundary = generateBoundaryString()
        
        let url = URL(string: "https://bugitapp.atlassian.net/rest/api/2/issue/TPO-2/attachments")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; name='file'; filename='screenshot.jpg'; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("no-check", forHTTPHeaderField: "X-Atlassian-Token")
        request.setValue(credentails(withUsername: "junkbipin@yahoo.com", withPassword: "bugit"), forHTTPHeaderField: JiraManager.authHeader)
        
        let imageData = UIImageJPEGRepresentation(image, 1.0)!
        let tmpFileName = "\(NSDate.timeIntervalSinceReferenceDate).jpg"
        let tmpFilePath = createTempDirectory()! + "/\(tmpFileName)"
        let tmpFileURL = NSURL(fileURLWithPath:createTempDirectory()!).appendingPathComponent(tmpFileName)
        try? imageData.write(to: tmpFileURL!)

        request.httpBody = try createBody(with: parameters, filePathKey: "file", paths: [tmpFilePath], boundary: boundary)
        
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
    
    func createBody(with parameters: [String: String]?, filePathKey: String, paths: [String], boundary: String) throws -> Data {
        var body = Data()
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.append("\(value)\r\n")
            }
        }
        
        for path in paths {
            let url = URL(fileURLWithPath: path)
            let filename = url.lastPathComponent
            let data = try Data(contentsOf: url)
            let mimetype = mimeType(for: path)
            
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(filePathKey)\"; filename=\"\(filename)\"\r\n")
            body.append("Content-Type: \(mimetype)\r\n\r\n")
            body.append(data)
            body.append("\r\n")
        }
        
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
}
