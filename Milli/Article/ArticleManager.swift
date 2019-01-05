//
//  Globals.swift
//  Milli
//
//  Created by Charles Wang on 3/11/18.
//  Copyright © 2018 Milli. All rights reserved.
//

import Foundation
import AVFoundation


struct ArticleManager {
    static var articles: [Article] = [Article]()
    static var currentArticleIdx = 0
    static var audioCache = [AudioWrapper: AVAudioPlayer]()

    static var currentArticle: Article? {
        return articles.indices.contains(currentArticleIdx) ? articles[currentArticleIdx] : nil
    }
    
    static func checkForAudioUrls() {
        let articleWithNoAudio = ArticleManager.articles.filter { $0.audioPlayer != nil }
        if articleWithNoAudio.count > 0 {
            AWSClient.getArticles(articles: ArticleManager.articles, completion: nil)
        }
    }
    
}
