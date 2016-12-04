//
//  xUIView.swift
//  bugit
//
//  Created by Ernest on 12/3/16.
//  Copyright © 2016 BugIt App. All rights reserved.
//

import UIKit

extension UIView {
    
    func getSnapshotImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        drawHierarchy(in: bounds, afterScreenUpdates: false)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return snapshotImage
    }

}
