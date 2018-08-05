//
//  Utils.swift
//  Milli
//
//  Created by Alex Mang on 7/22/18.
//  Copyright © 2018 Milli. All rights reserved.
//

import Foundation

let userDefaults = UserDefaults(suiteName: "group.com.Milli.Milli")
let bufferKey = "articleArray"


func getShareBuffer() -> [NSDictionary] {
    if let buffer = userDefaults?.object(forKey: bufferKey) as? [NSDictionary] {
        return buffer
    } else {
        print("[Utils] share buffer empty")
        return [NSDictionary]()
    }
}

func setShareBuffer(with data: Any) {
    userDefaults?.set(data, forKey: bufferKey)
    userDefaults?.synchronize()
}

import UIKit

extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
