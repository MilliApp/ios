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

class Wrapper: Codable {
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

//class AudioWrapper: Wrapper {
//    var player: ArticleAudioPlayer? {
//        if let articleAudioPlayer = Globals.articleIdAudioPlayers[url.absoluteString] {
//            return articleAudioPlayer
//        } else if let data = try? Data(contentsOf: path){
//            guard let audioPlayer = try? AVAudioPlayer(data: data) else { return nil }
//            let articleAudioPlayer = 
//            Globals.articleIdAudioPlayers[url.absoluteString] = audioPlayer
//            return audioPlayer
//        }
//        return nil
//    }
//}
