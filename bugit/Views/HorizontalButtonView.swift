//
//  HorizontalButtonView.swift
//  bugit
//
//  Created by Bill Luoma on 12/2/16.
//  Copyright © 2016 BugIt App. All rights reserved.
//

import UIKit


protocol HorizontalButtonViewDelegate {
    
    func onHButtonPressed(buttonView: HorizontalButtonView, button: UIButton)
}

class HorizontalButtonView: UIView {
 
    @IBOutlet var contentView: UIView!
    @IBOutlet var buttonContainerView: UIView!
    
    var buttonArray: [UIButton] = []
    var buttonState: [Int] = []
    var buttonColorMap: [Int: [UIColor]] = [:]
    var buttonDelegate: HorizontalButtonViewDelegate? = nil
    
    var selectedColor: UIColor = UIColor.red
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    func initSubviews() {
        let nib = UINib(nibName: "HorizontalButtonView", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
        dlog("center: \(self.center)")
        
        let buttonStack = buttonContainerView.subviews
        for (i, button) in buttonStack.enumerated() {
            if let b = button as? UIButton {
                b.titleLabel?.text = ""
                buttonArray.append(b)
                buttonState.append(0)
                dlog("added button i: \(i)")
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for (i, b) in buttonArray.enumerated() {
            b.backgroundColor = UIColor.white
            
            if i == 0 {
                buttonState.append(1)
                let img = UIImage(named: "arrow")
                b.setImage(img, for: .normal)
                b.backgroundColor = UIColor.white
                b.backgroundColor = UIColor.groupTableViewBackground
                b.tintColor = selectedColor
            }
            else if i == 1 {
                let img = UIImage(named: "text")
                b.setImage(img, for: .normal)
                buttonState.append(0)
                b.backgroundColor = UIColor.white
            }
            else if i == 2 {
                let img = UIImage(named: "circle")
                b.setImage(img, for: .normal)
                buttonState.append(0)
                b.backgroundColor = UIColor.white
            }
            else if i == 3 {
                let img = UIImage(named: "square")
                b.setImage(img, for: .normal)
                buttonState.append(0)
                b.backgroundColor = UIColor.white
            }
            else if i == 4 {
                let img = UIImage(named: "freehand")
                b.setImage(img, for: .normal)
                buttonState.append(0)
                b.backgroundColor = UIColor.white
            }
            else if i == 5 {
                let img = UIImage(named: "blur")
                b.setImage(img, for: .normal)
                buttonState.append(0)
                b.backgroundColor = UIColor.white
            }
        }
    }
    
    @IBAction func onButtonPressed(_ sender: UIButton) {
        dlog("button tag: \(sender.tag)")
        let currentState = buttonState[sender.tag]
        dlog("currentState: \(currentState)")
        
        if currentState == 0 {
            for (i, b) in buttonArray.enumerated() {
                if b === sender {
                    buttonState[i] = 1
                    b.backgroundColor = UIColor.groupTableViewBackground
                    b.tintColor = selectedColor
                }
                else {
                    buttonState[i] = 0
                    b.backgroundColor = UIColor.white
                    b.tintColor = brightBlueThemeColor
                }
            }
            buttonDelegate?.onHButtonPressed(buttonView: self, button: sender)
        }
    }
    
    func refreshButtonColors(selectedButtonState: Int) {
        for (i, b) in buttonArray.enumerated() {
            if b.tag == selectedButtonState {
                buttonState[i] = 1
                b.backgroundColor = UIColor.groupTableViewBackground
                b.tintColor = selectedColor
            }
            else {
                buttonState[i] = 0
                b.backgroundColor = UIColor.white
                b.tintColor = brightBlueThemeColor
            }
        }
    }

    func setButtonColors(forOnState: UIColor, forOffState: UIColor) {
        
    }
    
}
