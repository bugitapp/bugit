//
//  ExportViewController.swift
//  bugit
//
//  Created by Ernest on 11/12/16.
//  Copyright © 2016 BugIt App. All rights reserved.
//

import UIKit

class ExportViewController: UIViewController {
    
    @IBOutlet weak var flatCanvasImageView: UIImageView!
    var screenshotAsset: ScreenshotAsset?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dlog("screenshotAsset: \(screenshotAsset)")

        // Do any additional setup after loading the view.
        
        // Need to do this otherwise it unwraps Nil on previous prepare for segue
        flatCanvasImageView.image = screenshotAsset?.screenshotImage
        
        let titleLabel = UILabel()
        let titleText = NSAttributedString(string: "Export", attributes: [
            NSFontAttributeName : UIFont(name: "SFUIText-Light", size: 21)!,
            NSForegroundColorAttributeName : UIColor.darkText
            ])
        titleLabel.attributedText = titleText
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
