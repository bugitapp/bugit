//
//  LoginViewController.swift
//  bugit
//
//  Created by Bipin Pattan on 11/29/16.
//  Copyright © 2016 BugIt App. All rights reserved.
//

import UIKit

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
            success: { (projects: [String]) in
                print("Projects: \(projects)")
            },
            failure: { (error: NSError) in
                print("Error : \(error)")
        })
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
