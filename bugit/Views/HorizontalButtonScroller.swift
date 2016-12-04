//
//  HorizontalButtonScroller.swift
//  bugit
//
//  Created by Bill Luoma on 12/2/16.
//  Copyright © 2016 BugIt App. All rights reserved.
//

import UIKit

class HorizontalButtonScroller: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet var buttonScrollView: UIScrollView!
    
    var buttonArray: [UIButton] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }

    
    func initSubviews() {
        
        let nib = UINib(nibName: "HorizontalButtonScroller", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
        dlog("center: \(self.center)")
        
        
    }

    @IBAction func onScrollButtonPressed(_ sender: UIButton) {
        
        dlog("button tag: \(sender.tag)")
        
    }
    
    
}


extension HorizontalButtonScroller: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        dlog("contentSize: \(scrollView.contentSize)")
    }
}
