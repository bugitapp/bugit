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

                /*
                if i == 0 {
                    buttonColorMap[i] = [UIColor.gray, UIColor.black]
                }
                else if i == 1 {
                    buttonColorMap[i] = [UIColor(netHex:0x800000), UIColor(netHex:0xFF0000)]
                }
                else if i == 2 {
                    buttonColorMap[i] = [UIColor(netHex:0x008000), UIColor(netHex:0x00FF00)]
                }
                else if i == 3 {
                    buttonColorMap[i] = [UIColor(netHex:0x000080), UIColor(netHex:0x0000FF)]
                }
                else if i == 4 {
                    buttonColorMap[i] = [UIColor.lightGray, UIColor.white]
                }
                */
                dlog("added button i: \(i)")
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for (i, b) in buttonArray.enumerated() {
            b.backgroundColor = UIColor.clear
            
            if i == 0 {
                buttonState.append(1)
                let img = UIImage(named: "ic_panorama_fish_eye_48pt")
                b.setImage(img, for: .normal)
            }
            else if i == 1 {
                let img = UIImage(named: "ic_crop_din_white_48pt")
                b.setImage(img, for: .normal)
                buttonState.append(0)
            }
            else if i == 2 {
                let img = UIImage(named: "ic_blur_on_white_48pt")
                b.setImage(img, for: .normal)
                buttonState.append(0)
            }
            else if i == 3 {
                let img = UIImage(named: "ic_blur_on_white_48pt")
                b.setImage(img, for: .normal)
                buttonState.append(0)
            }
            else if i == 4 {
                let img = UIImage(named: "ic_blur_on_white_48pt")
                b.setImage(img, for: .normal)
                buttonState.append(0)
            }
            else if i == 5 {
                let img = UIImage(named: "ic_blur_on_white_48pt")
                b.setImage(img, for: .normal)
                buttonState.append(0)
            }

            
        }
        
        
    }
    
    @IBAction func onButtonPressed(_ sender: UIButton) {
        
        dlog("button tag: \(sender.tag)")
        
        
        let currentState = buttonState[sender.tag]
        
        if currentState == 0 {
            
            for (i, b) in buttonArray.enumerated() {
                
                if let colors = buttonColorMap[i] {
                    if b === sender {
                        b.backgroundColor = colors[1]
                        buttonState[i] = 1
                    }
                    else {
                        b.backgroundColor = colors[0]
                        buttonState[i] = 0
                    }
                }
            }
            
            buttonDelegate?.onHButtonPressed(buttonView: self, button: sender)
        }
        
    }
    

    func setButtonColors(forOnState: UIColor, forOffState: UIColor) {
        
    }
    
    
}
