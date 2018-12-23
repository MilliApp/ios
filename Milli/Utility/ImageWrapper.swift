//
//  ImageWrapper.swift
//  Milli
//
//  Created by Alex Mang on 12/23/18.
//  Copyright © 2018 Milli. All rights reserved.
//

import Foundation
import UIKit

struct ImageWrapper: Codable {
    
    let url: URL?
    private(set) var path: URL?
    var image: UIImage? {
        if let path = path, let data = try? Data(contentsOf: path) {
            return UIImage(data: data)
        }
        return nil
    }
    
    init?(url: URL?) {
        self.url = url
        self.path = nil
        if let url = url {
            let path = documentURL.appendingPathComponent(String(url.hashValue))
            print(path)
            if !FileManager.default.fileExists(atPath: path.absoluteString) {
                let data = try? Data(contentsOf: url)
                do {
                    try data!.write(to: path)
                    self.path = path
                } catch {
                    print("storing image failed: \(error)")
                }
            }
        }
        return nil
    }
}
