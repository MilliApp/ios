//
//  Utility.swift
//  Milli
//
//  Created by Charles Wang on 12/10/17.
//  Copyright © 2017 Milli. All rights reserved.
//

import Foundation

// Function to format debug prints
func print_debug(_ tagID: String, message: String) {
    print(tagID + ": " + message)
}

// Function to convert seconds to a mm:ss time format string
func convertSecondsToTimeFormat(time: Int64) -> String {
    let min = Int(time / 60)
    let sec = Int(time % 60)
    
    var min_str  = String(min)
    if min / 10 < 1 {
        min_str = "0" + String(min)
    }
    
    var sec_str  = String(sec)
    if sec / 10 < 1 {
        sec_str = "0" + String(sec)
    }
    
    let res = min_str + ":" + sec_str
    
    return res
}

// Return string conveying current time out of total time
// i.e. mm:ss/mm:ss
func getTimeString(current:Int64, total:Int64) -> String {
    let total_str = convertSecondsToTimeFormat(time:total)
    let current_str = convertSecondsToTimeFormat(time: current)
    let res = "(" + current_str + "/" + total_str + ")"
    return res
}
