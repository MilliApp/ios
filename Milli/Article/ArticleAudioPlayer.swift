//
//  AudioPlayer.swift
//  Milli
//
//  Created by Charles Wang on 4/29/18.
//  Copyright © 2018 Milli. All rights reserved.
//

import Foundation
import AVFoundation

class ArticleAudioPlayer {
    
//    typealias CallbackHandler = (_ time: CMTime) -> Void
//    private var updateProgressCallback: CallbackHandler

    private let tagID = "[AUDIO_PLAYER]"
    
//    private enum State {
//        case NO_URL, AUDIO_LOADED
//    }
//
//    private var state: State
//    private var article: Article
//    private var player: AVPlayer = AVPlayer()
    private var player: AVAudioPlayer
    
    var currentTime: Double {
        get {
            return player.currentTime
        }
        set {
            player.currentTime = newValue
        }
    }
    
    var duration: Double {
        return player.duration
    }
    
    var progress: Double {
        return (duration != 0) ? currentTime / duration : 0.0
    }
    
    var isPlaying: Bool {
        return player.isPlaying
    }
    
    var rate: Float {
        get {
           return player.rate
        }
        set {
            player.rate = newValue
        }
    }
    
    init?(player: AVAudioPlayer) {
        self.player = player
    }
//    init?(article:Article, callback:@escaping CallbackHandler) {
//        print_debug(tagID, message: "Initializing")
//        self.article = article
//        self.state = .NO_URL
//        self.updateProgressCallback = callback
//    }
//
//    private func loadPlayArticleAudioPlayer() {
//        print_debug(tagID, message: "[GET_ARTICLE_AUDIO]")
//        if let url = article.audioUrl {
//            print(url)
//            // Load the AudioPlayer
//            self.player = AVPlayer.init(url: url)
//            self.player.volume = 1.0
//            self.state = .AUDIO_LOADED
//
//            // Play the audio
//            player.play()
//
//            print_debug(tagID, message: "Loading Player...")
//            setProgressCallback()
//        } else {
//            print_debug(tagID, message: "[GET_ARTICLE_AUDIO] Audio URL not loaded yet")
//            AWSClient.getArticle(article: article)
//        }
//    }
    
    func play() {
//        if state != .AUDIO_LOADED {
//            print_debug(tagID, message: "[PLAY] Audio not loaded")
//            loadPlayArticleAudioPlayer()
//            return
//        }
//        print_debug(tagID, message: "[PLAY] Playing \(String(describing: article.audioUrl))")
        print("pressing play")
        player.play()
    }
    
    func togglePlayPause() {
        if isPlaying {
            player.pause()
        } else {
            play()
        }
    }

}
