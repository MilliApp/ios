//
//  ArticleAudioPlayerManager.swift
//  Milli
//
//  Created by Charles Wang on 10/14/18.
//  Copyright © 2018 Milli. All rights reserved.
//

import Foundation

class ArticleAudioPlayerManager {
    
    class func getCurrentArticleAudioPlayer() -> ArticleAudioPlayer {
        let article = getCurrentArticle()
        let articleID = article.articleId
        return Globals.articleIdAudioPlayers[articleID]!
    }
    
    class func getCurrentArticle() -> Article {
        return Globals.articles[Globals.currentArticleIdx]
    }
    
}
