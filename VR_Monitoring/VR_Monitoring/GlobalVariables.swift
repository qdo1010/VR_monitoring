//
//  GlobalVariables.swift
//  MakeupMaster
//
//  Created by HongQuan Do on 1/18/16.
//  Copyright © 2016 HongQuan Do. All rights reserved.
//
import UIKit

class GlobalVariables {
    
    // These are the properties you can store in your singleton
    var URL: String = "bob"
    var ID: String = "lib"
    var totalScore: String = ""
    var globalImage:UIImage? = nil
    var removedImage:UIImage? = nil
    var addonImage:UIImage? = nil
    var score = ""
    // Here is how you would get to it without there being a global collision of variables.
    // , or in other words, it is a globally accessable parameter that is specific to the
    // class.
    class var sharedManager: GlobalVariables {
        struct Static {
            static let instance = GlobalVariables()
        }
        return Static.instance
    }
}