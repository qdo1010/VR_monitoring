//
//  ProgressViewController.swift
//  VR_Monitoring
//
//  Created by Sarada Symonds on 3/16/16.
//  Copyright (c) 2016 NU Enabling Engineering. All rights reserved.
//

import UIKit

class ProgressViewController: UIViewController {
    @IBOutlet weak var scoreLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let firstViewController:UIViewController = self
        // The following statement is what you need
        let customTabBarItem:UITabBarItem = UITabBarItem(title: nil, image: UIImage(named: "Bar Chart Filled-35.png")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), selectedImage: UIImage(named: "Bar Chart Filled-35.png"))
        firstViewController.tabBarItem = customTabBarItem
        customTabBarItem.imageInsets.top = 10
        customTabBarItem.imageInsets.bottom = -6
        scoreLabel.text = GlobalVariables.sharedManager.score
        
        // Do any additional setup after loading the view.
    }
}
