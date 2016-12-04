//
//  TextViewCell.swift
//  bugit
//
//  Created by Bipin Pattan on 12/4/16.
//  Copyright © 2016 BugIt App. All rights reserved.
//

import UIKit

class TextViewCell: UITableViewCell {
    @IBOutlet weak var infoTextView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
