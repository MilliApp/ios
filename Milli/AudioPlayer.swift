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
    
    let tagID = "[AUDIO_PLAYER]"
    
    enum State {
        case NO_URL, AUDIO_LOADED
    }
    enum PlayState {
        case PLAY, PAUSE, STOP
    }
    
    var state: State
    var playState: PlayState
    var article: Article
    var player: AVAudioPlayer = AVAudioPlayer()
    
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
            
            var downloadTask:URLSessionDownloadTask
            downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: {urlDownload, response, error  in
                print_debug(self.tagID, message: "[GET_ARTICLE_AUDIO] Playing audio...")
//                self.play(url: urlDownload!)
                do {
                    // Load the AudioPlayer
                    self.player = try AVAudioPlayer(contentsOf: urlDownload!)
                    self.player.volume = 1.0
                    self.player.prepareToPlay()
                    self.state = .AUDIO_LOADED
                    
                    // Play the audio
                    self.player.play()
                    self.playState = .PLAY
                } catch let error as NSError {
                    //self.player = nil
                    print(error.localizedDescription)
                } catch {
                    print("AVAudioPlayer init failed")
                }
            })
            downloadTask.resume()
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
    
    func playPause() {
        if playState == .STOP || playState == .PAUSE {
            self.play()
        } else if playState == .PLAY {
            print_debug(tagID, message: "[PLAY] Pausing \(article.audioURL)")
            player.pause()
            playState = .PAUSE
        }
    }
}
