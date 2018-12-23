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
    
    typealias CallbackHandler = (_ time: CMTime) -> Void
    private var updateProgressCallback: CallbackHandler

    private let tagID = "[AUDIO_PLAYER]"
    
    private enum State {
        case NO_URL, AUDIO_LOADED
    }
    
    private var state: State
    private var article: Article
    private var player: AVPlayer = AVPlayer()
    
    var currentTime: Double {
        let time = CMTimeGetSeconds(player.currentTime())
        return (!time.isNaN) ? time : 0.0
    }
    
    var duration: Double {
        let duration = player.currentItem?.duration.seconds ?? 0.0
        return (!duration.isNaN) ? duration : 0.0
    }
    
    var progress: Double {
        return (duration != 0) ? currentTime / duration : 0.0
    }
    
    var isPlaying: Bool {
        return player.rate > 0
    }
    
    var rate: Float {
        get {
           return player.rate
        }
        set {
            player.rate = newValue
        }
    }
    
    init?(article:Article, callback:@escaping CallbackHandler) {
        print_debug(tagID, message: "Initializing")
        self.article = article
        self.state = .NO_URL
        self.updateProgressCallback = callback
    }
    
    private func loadPlayArticleAudioPlayer() {
        print_debug(tagID, message: "[GET_ARTICLE_AUDIO]")
        if let url = article.audioUrl {
            print(url)
            // Load the AudioPlayer
            self.player = AVPlayer.init(url: url)
            self.player.volume = 1.0
            self.state = .AUDIO_LOADED
            
            // Play the audio
            player.play()
            
            print_debug(tagID, message: "Loading Player...")
            setProgressCallback()
        } else {
            print_debug(tagID, message: "[GET_ARTICLE_AUDIO] Audio URL not loaded yet")
            AWSClient.getArticle(article: article)
        }
    }
    
    func play() {
        if state != .AUDIO_LOADED {
            print_debug(tagID, message: "[PLAY] Audio not loaded")
            loadPlayArticleAudioPlayer()
            return
        }
        print_debug(tagID, message: "[PLAY] Playing \(String(describing: article.audioUrl))")
        
        player.play()
    }
    
    func togglePlayPause() {
        if isPlaying {
            player.pause()
        } else {
            play()
        }
    }
    
    func seek(to time: Double, completion: @escaping () -> ()) {
        player.seek(to: CMTimeMakeWithSeconds(time + currentTime, preferredTimescale: 1)) { _ in
            completion()
        }
    }
    
    private func setProgressCallback() {
        print_debug(tagID, message: "setProgressCallback called")
        player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1,timescale: 2), queue: nil, using: updateProgressCallback)
    }
    
    func setRate(rate:Float) {
        player.rate = rate
    }
}
