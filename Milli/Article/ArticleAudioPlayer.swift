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
    
    // TODO(cvwang): allow the seek time to be configurable
    private let SEEK_SECONDS: Int64 = 30
    private let tagID = "[AUDIO_PLAYER]"
    
    private enum State {
        case NO_URL, AUDIO_LOADED
    }
    private enum PlayState {
        case PLAY, PAUSE, STOP
    }
    
    private var state: State
    private var playState: PlayState
    private var article: Article
    private var player: AVPlayer = AVPlayer()
    private var updateProgressCallback: CallbackHandler
    
    init?(article:Article, callback:@escaping CallbackHandler) {
        print_debug(tagID, message: "Initializing")
        self.article = article
        self.state = .NO_URL
        self.playState = .STOP
        self.updateProgressCallback = callback
//        print_debug(tagID, message: "Loading Player...")
//        loadPlayArticleAudioPlayer()
    }
    
    private func loadPlayArticleAudioPlayer() {
        print_debug(tagID, message: "[GET_ARTICLE_AUDIO]")
        if let articleAudioURL = article.audioURL as String? {
            let url = URL(string: articleAudioURL)!
            
            print(url)
            // Load the AudioPlayer
            self.player = AVPlayer.init(url: url)
            self.player.volume = 1.0
            self.state = .AUDIO_LOADED
            
            // Play the audio
            self.player.play()
            self.playState = .PLAY
            
            print_debug(tagID, message: "Loading Player...")
            setProgressCallback()
        } else {
            print_debug(tagID, message: "[GET_ARTICLE_AUDIO] Audio URL not loaded yet")
            AWSClient.getArticleAudioMeta(article: article)
        }
    }
    
    func play() {
        if state != .AUDIO_LOADED {
            print_debug(tagID, message: "[PLAY] Audio not loaded")
            loadPlayArticleAudioPlayer()
            return
        }
        print_debug(tagID, message: "[PLAY] Playing \(String(describing: article.audioURL))")
        player.play()
        playState = .PLAY
    }
    
    func pause() {
        print_debug(tagID, message: "[PLAY] Pausing \(String(describing: article.audioURL))")
        player.pause()
        playState = .PAUSE
    }
    
    func playPause() {
        if playState == .STOP || playState == .PAUSE {
            self.play()
        } else if playState == .PLAY {
            self.pause()
        }
    }
    
    func currentTime() -> Double {
        return CMTimeGetSeconds(player.currentTime())
    }
    
    func totalTime() -> Double {
//        return (player.currentItem?.duration.seconds)!
        let currentItem = player.currentItem!
        var duration = 0.0
        for tr in currentItem.loadedTimeRanges {
            duration += CMTimeGetSeconds(tr.timeRangeValue.duration)
        }
        if duration == 0.0 {
            print_debug(tagID, message: "0 duration")
            return 0 // error
        }
        return duration
    }
    
    func progress() -> Double {
        let currentTime = self.currentTime()
        let totalTime = self.totalTime()
        if totalTime == 0.0 {
            return 0.0
        }
        return currentTime / totalTime
    }
    
    func secondsLeft() -> Int64 {
        return Int64(totalTime() - currentTime())
    }
    
    private func seek(to: Int64) {
        let seekTime = CMTimeMake(to, 1)
        player.seek(to: seekTime)
    }
    
    func rewind() {
        seek(to: (Int64)(currentTime()) - SEEK_SECONDS)
    }
    
    func forward() {
        seek(to: (Int64)(currentTime()) + SEEK_SECONDS)
    }
    
    func isPlaying() -> Bool {
        return playState == .PLAY
    }
    
    func setProgressCallback() {
        print_debug(tagID, message: "setProgressCallback called")
        player.addPeriodicTimeObserver(forInterval: CMTimeMake(1,2), queue: nil, using: updateProgressCallback)
    }
    
    func setRate(rate:Float) {
        player.rate = rate
    }
}
