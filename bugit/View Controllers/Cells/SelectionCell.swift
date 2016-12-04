//
//  SelectionCell.swift
//  bugit
//
//  Created by Bipin Pattan on 12/3/16.
//  Copyright © 2016 BugIt App. All rights reserved.
//

import UIKit

class SelectionCell: UITableViewCell {

    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func config(key: String!, value: String!) {
        keyLabel.text = key
        valueLabel.text = value
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
