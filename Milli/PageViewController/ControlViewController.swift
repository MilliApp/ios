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
    
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let currentValue = sender.value
        print_debug(tagID, message: "\(currentValue)")
        
        // Snap slider value to fixed positions
        var snappedValue = currentValue
        if (currentValue < 0.625) {
            snappedValue = 0.5
        } else if (currentValue >= 0.625 && currentValue < 0.875) {
            snappedValue = 0.75
        } else if (currentValue >= 0.875 && currentValue < 1.125) {
            snappedValue = 1.0
        } else if (currentValue >= 1.125 && currentValue < 1.375) {
            snappedValue = 1.25
        } else if (currentValue >= 1.375 && currentValue < 1.625) {
            snappedValue = 1.5
        } else if (currentValue >= 1.625 && currentValue < 1.875) {
            snappedValue = 1.75
        } else {
            snappedValue = 2.0
        }
        
        // Create slider snap animation
        slider.setValue(snappedValue, animated: true)
        
        // Set audio rate using snapped value
        let currentArticleAudioPlayer = ArticleAudioPlayerManager.getCurrentArticleAudioPlayer()
        currentArticleAudioPlayer.setRate(rate: snappedValue)
    }
    
}
