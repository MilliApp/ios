//
//  ImageWrapper.swift
//  Milli
//
//  Created by Alex Mang on 12/23/18.
//  Copyright © 2018 Milli. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class Wrapper: Codable, Hashable, Equatable {
    fileprivate let url: URL
    fileprivate var path: URL {
        return documentURL.appendingPathComponent(String(url.hashValue))
    }
    
    init?(url: URL?) {
        guard let dataSource = url else { return nil }
        self.url = dataSource
        if !FileManager.default.fileExists(atPath: path.path) {
            let data = try? Data(contentsOf: self.url)
            do {
                try data!.write(to: path)
            } catch {
                print("storing image failed: \(error)")
            }
        }
    }
    
    static func == (lhs: Wrapper, rhs: Wrapper) -> Bool {
        return lhs.url == rhs.url
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
}

class ImageWrapper: Wrapper {
    var data: Data?
    var image: UIImage? {
        if let data = self.data {
            return UIImage(data: data)
        } else if let data = try? Data(contentsOf: path) {
            self.data = data
            return UIImage(data: data)
        }
        return nil
    }
}

class AudioWrapper: Wrapper {
    var player: AVAudioPlayer? {
        if let articleAudioPlayer = ArticleManager.audioCache[self] {
            return articleAudioPlayer
        } else if let data = try? Data(contentsOf: path){
            guard let audioPlayer = try? AVAudioPlayer(data: data) else { return nil }
            ArticleManager.audioCache[self] = audioPlayer
            return audioPlayer
        }
        return nil
    }
}
