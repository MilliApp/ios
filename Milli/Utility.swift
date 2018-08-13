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

func convertDate(fromISO date:String?) -> Date? {
    if let dateStr = date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        return dateFormatter.date(from:String(dateStr.prefix(19)))
    }
    return nil
    
}
