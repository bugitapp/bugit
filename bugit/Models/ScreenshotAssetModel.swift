//
//  ScreenshotAssetModel.swift
//  fasset
//
//  Created by Bill Luoma on 11/14/16.
//  Copyright © 2016 Bill Luoma. All rights reserved.
//

import UIKit
import Photos

class ScreenshotAssetModel: CustomStringConvertible, CustomDebugStringConvertible {
    
    var screenshotImage: UIImage?
    var screenshotAsset: PHAsset?
    var editedImage: UIImage?
    
    
    var description: String {
        return debugDescription
    }
    
    var debugDescription: String {
        return "screenShot date: \(screenshotAsset?.creationDate), size: \(screenshotImage?.size)"
    }

    
}
