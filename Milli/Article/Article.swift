//
//  Article.swift
//  Milli
//
//  Created by Charles Wang on 12/10/17.
//  Copyright © 2017 Milli. All rights reserved.
//
import Foundation
import UIKit

class Article: Codable, Equatable {
    // Basic Variables
    let articleId: String
    let articleUrl: URL
    let title: String
    let source: String
    let sourceLogo: ImageWrapper

    // Processed Variables
    var publishDate: Date?
    var audioUrl: URL?
    var content: String?
    var topImage: ImageWrapper

    init(response: [String: String]) {
        articleId = response["articleId"]!
        articleUrl = Article.getUrl(from: response["articleUrl"])!
        title = response["title"]!
        source = articleUrl.host!
        sourceLogo = ImageWrapper(url: URL(string: "https://logo.clearbit.com/" + source))
        
        publishDate = convertDate(fromISO: response["publishDate"])
        audioUrl = Article.getUrl(from: response["audioUrl"])
        content = response["content"]
        topImage = ImageWrapper(url: Article.getUrl(from: response["topImage"]))
    }
    
    static let LogoPath = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("logos")
    
    static private func getUrl(from responseUrl:String?) -> URL? {
        if let url = responseUrl {
            return URL(string: url)
        }
        return nil;
    }
    
    static func == (lhs: Article, rhs: Article) -> Bool {
        return lhs.articleId == rhs.articleId
    }
}

struct ImageWrapper: Codable {
    let url: URL?
    private(set) var path: URL?
    var image: UIImage? {
        get {
            if let path = path, let data = try? Data(contentsOf: path) {
                return UIImage(data: data)
            }
            return nil
        }
    }
    
    init(url: URL?) {
        self.url = url
        self.path = nil
        if let url = url {
            let path = documentURL.appendingPathComponent(String(url.hashValue))
            print(path)
            if !FileManager.default.fileExists(atPath: path.absoluteString) {
                let data = try? Data(contentsOf: url)
                do {
                    try data!.write(to: path)
                    self.path = path
                } catch {
                    print("storing image failed: \(error)")
                }
            }
        }
    }
}

extension Date {
    var string: String {
        get {
            let formatter = DateFormatter()
            // initially set the format based on your datepicker date
            formatter.dateFormat = "dd-MMM-yyyy"
            return formatter.string(from: self)
        }
    }
}

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


