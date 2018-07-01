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
    
    //TODO (cvwang): allow the seek time to be configurable
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
    
    init?(article:Article) {
        self.article = article
        self.state = .NO_URL
        self.playState = .STOP
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
            
//            var downloadTask:URLSessionDownloadTask
//            downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: {urlDownload, response, error  in
//                print_debug(self.tagID, message: "[GET_ARTICLE_AUDIO] Playing audio...")
//                do {
//                    // Load the AudioPlayer
//                    self.player = AVPlayer.init(url: urlDownload)
////                    self.player.prepareToPlay()
//                    self.state = .AUDIO_LOADED
//
//                    // Play the audio
//                    self.player.play()
//                    self.playState = .PLAY
//                } catch let error as NSError {
//                    print(error.localizedDescription)
//                } catch {
//                    print("AudioPlayer init failed")
//                }
//            })
//            downloadTask.resume()
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
        print_debug(tagID, message: "[PLAY] Playing \(article.audioURL)")
        player.play()
        playState = .PLAY
    }
    
    func pause() {
        print_debug(tagID, message: "[PLAY] Pausing \(article.audioURL)")
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
    
    func currentTime() -> Int64 {
        return Int64(CMTimeGetSeconds(player.currentTime()))
    }
    
    private func seek(to: Int64) {
        let seekTime = CMTimeMake(to, 1)
        player.seek(to: seekTime)
    }
    
    func rewind() {
        seek(to: currentTime() - SEEK_SECONDS)
    }
    
    func forward() {
        seek(to: currentTime() + SEEK_SECONDS)
    }
    
    func isPlaying() -> Bool {
        return playState == .PLAY
    }
}
