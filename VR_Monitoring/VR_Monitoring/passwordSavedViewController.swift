//
//  passwordSavedViewController.swift
//  VR_Monitoring
//
//  Created by Sarada Symonds on 12/9/15.
//  Copyright (c) 2015 NU Enabling Engineering. All rights reserved.
//

import UIKit
import Firebase

class passwordSavedViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.dismissViewControllerAnimated(true, completion: nil)
        // Delay execution of my block for 10 seconds.
        func runAfterDelay(delay: NSTimeInterval, block: dispatch_block_t) {
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
            dispatch_after(time, dispatch_get_main_queue(), block)
        }
        runAfterDelay(1) {
            self.performSegueWithIdentifier("toMainScreen", sender: self)
        }

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

