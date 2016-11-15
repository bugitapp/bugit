//
//  ScreenshotAssetSearchResults.swift
//  flickr
//
//  Created by Bill Luoma on 11/13/16.
//  Copyright © 2016 Bill Luoma. All rights reserved.
//

import UIKit
import Photos

class ScreenshotAssetSearchResults: CustomStringConvertible, CustomDebugStringConvertible {

    var creationDate: Date = Date()
    var titleString: String = ""
    var screenShotAssets: [PHAsset] = []
    var screenshotAssetSectionsArray: [ScreenshotAssetSearchResults] = [] {
        didSet {
            dlog("b4 sort: \(screenshotAssetSectionsArray)")
            screenshotAssetSectionsArray.sort(by: >)
            dlog("after sort: \(screenshotAssetSectionsArray)")
        }
    }
    

    
    var debugDescription: String {
        return "\(titleString): \(screenShotAssets.count)"
    }
    
    var description: String {
        return debugDescription
    }
}

extension ScreenshotAssetSearchResults: Comparable, Hashable {
    
    static func ==(lhs: ScreenshotAssetSearchResults, rhs: ScreenshotAssetSearchResults) -> Bool {
        dlog("lhs.creationDate: \(lhs.creationDate) == rhs.creationDate: \(rhs.creationDate)")
        return lhs.creationDate == rhs.creationDate
    }
    
    static func <(lhs: ScreenshotAssetSearchResults, rhs: ScreenshotAssetSearchResults) -> Bool {
        dlog("lhs.creationDate: \(lhs.creationDate) < rhs.creationDate: \(rhs.creationDate)")
        return lhs.creationDate < rhs.creationDate
    }
    
    var hashValue: Int {
        return creationDate.hashValue
    }

}
