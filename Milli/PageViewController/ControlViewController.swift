//
//  ControlViewController.swift
//  Milli
//
//  Created by Charles Wang on 8/5/18.
//  Copyright © 2018 Milli. All rights reserved.
//

import UIKit

class ControlViewController: UIViewController {
    
    @IBOutlet var slider: UISlider!
    
    // Setting initial variables
    let tagID = "[CONTROL_VIEW_CONTROLLER]"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print_debug(tagID, message: "viewDidLoad...")
    }
    
    
}
