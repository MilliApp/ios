//
//  Archiver.swift
//  Milli
//
//  Created by Alex Mang on 12/23/18.
//  Copyright © 2018 Milli. All rights reserved.
//

import Foundation


let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
let ArchiveURL = FileManager().containerURL(forSecurityApplicationGroupIdentifier: "group.com.Milli1.Milli1")!.appendingPathComponent("articles")


func archive(articles: [Article]) {
    do {
        let jsonData = try JSONEncoder().encode(articles)
        try jsonData.write(to: ArchiveURL)
    } catch {
        print("archiving failed!")
    }
}

func unarchiveArticles() -> [Article]? {
    do {
        let data = try Data(contentsOf: ArchiveURL)
        let articles = try? JSONDecoder().decode([Article].self, from: data)
        return articles
    } catch {
        print("loading failed")
    }
    return nil
}

func putArticleInModel(article: Article) {
    var articleArray = unarchiveArticles() ?? [Article]()
    if let idx = articleArray.firstIndex(of: article) {
        articleArray[idx] = article
    } else {
        articleArray.insert(article, at: 0)
    }
    ArticleManager.articles = articleArray
    archive(articles: articleArray)
}
