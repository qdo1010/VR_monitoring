//
//  LoginViewController.swift
//  VR_Monitoring
//
//  Created by Sarada Symonds on 11/7/15.
//  Copyright (c) 2015 NU Enabling Engineering. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    let ref = Firebase(url: "https://amber-inferno-7571.firebaseio.com/")
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBAction func login(sender: UIButton) {
        let userEmail = usernameTextField.text
        let userPassword = passwordTextField.text
        ref.authUser(userEmail, password: userPassword,
            withCompletionBlock: { error, authData in
                if error != nil {
                    // There was an error logging in to this account
                    println("error logging in");
                } else {
                    // We are now logged in
                    println("log in success!")
                    
                    //have to regenerate and set new password everytime
                    self.performSegueWithIdentifier("loginSuccessful", sender: self);
                }
        })

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}