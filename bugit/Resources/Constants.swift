//
//  Constants.swift
//  bugit
//
//  Created by Bill Luoma on 11/15/16.
//  Copyright © 2016 BugIt App. All rights reserved.
//

import UIKit

//MARK: - dlog
func dlog(_ message: String, _ filePath: String = #file, _ functionName: String = #function, _ lineNum: Int = #line)
{
    #if DEBUG
        
        let url  = URL(fileURLWithPath: filePath)
        let path = url.lastPathComponent
        var fileName = "Unknown"
        if let name = path.characters.split(separator: ",").map(String.init).first {
            fileName = name
        }
        let logString = String(format: "%@.%@[%d]: %@", fileName, functionName, lineNum, message)
        NSLog(logString)
        
    #endif
    
}

struct Platform {
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }()
}

/*
 if Platform.isSimulator {
 // Do one thing
 }
 else {
 // Do the other
 }
 */


public let themeColor = UIColor(red: 0.01, green: 0.41, blue: 0.22, alpha: 1.0)

