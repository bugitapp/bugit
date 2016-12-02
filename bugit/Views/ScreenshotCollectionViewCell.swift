//
//  ScreenshotCollectionViewCell.swift
//  fasset
//
//  Created by Bill Luoma on 11/10/16.
//  Copyright © 2016 Bill Luoma. All rights reserved.
//

import UIKit

class ScreenshotCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var largeLoadingSpinner: UIActivityIndicatorView!
    
    
    //override var isSelected: Bool {
    //    didSet {
    //        photoImageView.layer.borderWidth = isSelected ? 10 : 0
    //    }
    //}
    
    // MARK: - View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        photoImageView.layer.borderColor = lightBlueThemeColor.cgColor
        photoImageView.layer.borderWidth = 2
        photoImageView.layer.cornerRadius = 4
        isSelected = false
    }
}
