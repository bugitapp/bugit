//
//  PriorityTypeModel.swift
//  bugit
//
//  Created by Bipin Pattan on 12/3/16.
//  Copyright © 2016 BugIt App. All rights reserved.
//

import UIKit

class PriorityTypeModel: NSObject {
    var id: Int?
    var name: String?
    var iconUrl: String?
    var typeDescription: String?
    
    init(dict: Dictionary<String, Any>) {
        if let idValue = dict["id"] as! String? {
            id = Int(idValue)
        }
        if let nameValue = dict["name"] as! String? {
            name = nameValue
        }
        if let urlValue = dict["iconUrl"] as! String? {
            iconUrl = urlValue
        }
        if let descValue = dict["description"] as! String? {
            typeDescription = descValue
        }
    }
    
    override var description: String {
        return "PriorityTypeModel: id: \(id) name: \(name) iconUrl: \(iconUrl) typeDesc: \(typeDescription)"
    }
}
