//
//  AudioPlayer.swift
//  Milli
//
//  Created by Charles Wang on 4/29/18.
//  Copyright © 2018 Milli. All rights reserved.
//

import Foundation
import AVFoundation

class AudioPlayer {
    
    static let tagID = "[AUDIO_PLAYER]"
    
    static var player:AVAudioPlayer = AVAudioPlayer()
    
    static func play(url:URL) {
        print_debug(tagID, message: "Playing \(url)")
        do {
            self.player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.volume = 1.0
            player.play()
        } catch let error as NSError {
            //self.player = nil
            print(error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
        }
    }
}
