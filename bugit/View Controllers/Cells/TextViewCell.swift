//
//  TextViewCell.swift
//  bugit
//
//  Created by Bipin Pattan on 12/4/16.
//  Copyright © 2016 BugIt App. All rights reserved.
//

import UIKit

protocol TextViewCellDelegate : class {
    func textViewCell(tvc: TextViewCell, textDidChange text: String?)
}

class TextViewCell: UITableViewCell, UITextViewDelegate {
    @IBOutlet weak var infoTextView: UITextView!
    weak var delegate: TextViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        infoTextView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func textViewDidChange(_ textView: UITextView) {
        delegate?.textViewCell(tvc: self, textDidChange: textView.text)
    }
}
