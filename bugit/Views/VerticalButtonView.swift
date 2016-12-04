//
//  VerticalButtonView.swift
//  bugit
//
//  Created by Bill Luoma on 12/2/16.
//  Copyright © 2016 BugIt App. All rights reserved.
//

import UIKit


protocol VerticalButtonViewDelegate {
    
    func onVButtonPressed(buttonView: VerticalButtonView, button: UIButton)
}


class VerticalButtonView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet var buttonContainerView: UIView!
    
    var buttonArray: [UIButton] = []
    var buttonState: [Int] = []
    var buttonDelegate: VerticalButtonViewDelegate? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    
    func initSubviews() {
        
        let nib = UINib(nibName: "VerticalButtonView", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
        dlog("center: \(self.center)")
        
        let buttonStack = buttonContainerView.subviews
        
        var i = 0
        
        for button in buttonStack {
            
            if let b = button as? UIButton {
                
                buttonArray.append(b)
                buttonState.append(0)
                dlog("added button i: \(i)")
                
            }
            i = i + 1
        }
        
    }
    
    @IBAction func onButtonPressed(_ sender: UIButton) {
        
        dlog("button tag: \(sender.tag)")
        
        buttonDelegate?.onVButtonPressed(buttonView: self, button: sender)
        
    }
    

    

}
