//
//  LoginViewController.swift
//  bugit
//
//  Created by Bipin Pattan on 11/29/16.
//  Copyright © 2016 BugIt App. All rights reserved.
//

import UIKit
import MBProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var domianTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var jiraMgr: JiraManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func onLoginButtonTapped(_ sender: UIButton) {
        jiraMgr =  JiraManager(domainName: domianTextField.text, username: emailTextField.text, password: passwordTextField.text)
        jiraMgr?.projects(
            success: { (projects: [ProjectsModel]) in
                print("Projects: \(projects)")
                MBProgressHUD.hide(for: self.view, animated: true)
                _ = self.navigationController?.popViewController(animated: true)
            },
            failure: { (error: NSError) in
                print("Error : \(error)")
                MBProgressHUD.hide(for: self.view, animated: true)
        })
        MBProgressHUD.showAdded(to: self.view, animated: true)
    }    
}
