//
//  Step3ViewController.swift
//  bugit
//
//  Created by Ernest on 11/30/16.
//  Copyright © 2016 BugIt App. All rights reserved.
//

import UIKit

class Step3ViewController: ViewController {

    @IBOutlet weak var closeIntroButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Remove navigation back button title
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        // Make UINavigationBar transparent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        // Swipe gestures
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipePrevious))
        swipeLeft.direction = .right
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(closeIntro))
        swipeRight.direction = .left
        self.view.addGestureRecognizer(swipeRight)
        
        // Custom UI
        //self.closeIntroButton.layer.cornerRadius = 6
        self.closeIntroButton.tintColor = UIColor.blue
        self.closeIntroButton.backgroundColor = UIColor.white
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Actions
    
    @IBAction func closeIntro(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    @IBAction func handleSwipePrevious(sender: UITapGestureRecognizer? = nil) {
        self.performSegue(withIdentifier: "Step2Segue", sender: self)
    }

}
