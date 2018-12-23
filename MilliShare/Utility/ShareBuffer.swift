//
//  Utils.swift
//  Milli
//
//  Created by Alex Mang on 7/22/18.
//  Copyright © 2018 Milli. All rights reserved.
//

import Foundation

let userDefaults = UserDefaults(suiteName: "group.com.Milli1.Milli1")
let bufferKey = "articleArray"

var shareBuffer: [NSDictionary] {
    get {
        if let buffer = userDefaults?.object(forKey: bufferKey) as? [NSDictionary] {
            return buffer
        } else {
            print("[Utils] share buffer empty")
            return [NSDictionary]()
        }
    }
    set {
        userDefaults?.set(newValue, forKey: bufferKey)
        userDefaults?.synchronize()
    }
}
