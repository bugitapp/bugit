//
//  ProjectsModel.swift
//  bugit
//
//  Created by Bipin Pattan on 11/30/16.
//  Copyright © 2016 BugIt App. All rights reserved.
//

import UIKit

class ProjectsModel: NSObject {
    var avatarImageLarge: URL?
    var avatarImageSmall: URL?
    var id: Int?
    var key: String?
    var name: String?
    
    init(dict: Dictionary<String, Any>) {
        if let idValue = dict["id"] as! String? {
            id = Int(idValue)
        }
        if let keyValue = dict["key"] as! String? {
            key = keyValue
        }
        if let nameValue = dict["name"] as! String? {
            name = nameValue
        }
    }
    
    override var description: String {
        return "ProjectsModel: \(key) id: \(id) name: \(name)"
    }    
}
