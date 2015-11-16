//
//  LoginViewController.swift
//  VR_Monitoring
//
//  Created by Sarada Symonds on 11/7/15.
//  Copyright (c) 2015 NU Enabling Engineering. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBAction func login(sender: UIButton) {
        let userEmail = usernameTextField.text
        let userPassword = passwordTextField.text
        
        if !userEmail.isEmpty && !userPassword.isEmpty {
            PFUser.logInWithUsernameInBackground(userEmail, password: userPassword) { (user, error) -> Void in
                if error == nil {
                    println("login successful");
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isUserLoggedIn");
                    NSUserDefaults.standardUserDefaults().synchronize();
                    self.performSegueWithIdentifier("loginSuccessful", sender: self);
                } else {
                    println("error: \(error!.userInfo!)")
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let testObject = PFObject(className: "TestObject")
        testObject.setObject("bar", forKey: "foo")
        testObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            println("Object has been saved.")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}