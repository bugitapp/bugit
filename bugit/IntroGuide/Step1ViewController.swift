//
//  Step1ViewController.swift
//  bugit
//
//  Created by Ernest on 11/30/16.
//  Copyright © 2016 BugIt App. All rights reserved.
//

import UIKit

class Step1ViewController: ViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Remove navigation back button title
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        // Make UINavigationBar transparent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeNext))
        swipeRight.direction = .left
        self.view.addGestureRecognizer(swipeRight)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    @IBAction func handleSwipeNext(sender: UITapGestureRecognizer? = nil) {
        self.performSegue(withIdentifier: "Step2Segue", sender: self)
    }
    
}
