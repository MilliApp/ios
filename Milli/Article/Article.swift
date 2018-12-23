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
    let articleUrl: URL
    let title: String
    let source: String
    let sourceLogo: ImageWrapper?

    // Processed Variables
    var articleId: String
    var publishDate: Date?
    var audioUrl: URL?
    var content: String?
    var topImage: ImageWrapper?

    init(response: [String: String]) {
        articleId = response["articleId"] ?? ""
        articleUrl = URL(string: response["articleUrl"])!
        title = response["title"]!
        source = articleUrl.host!
        sourceLogo = ImageWrapper(url: URL(string: "https://logo.clearbit.com/" + source))
        
        publishDate = convertDate(fromISO: response["publishDate"])
        audioUrl = URL(string: response["audioUrl"])
        content = response["content"]
        topImage = ImageWrapper(url: URL(string: response["topImage"]))
    }
    
    static func == (lhs: Article, rhs: Article) -> Bool {
        if lhs.articleId != "" && rhs.articleId != "" {
            return lhs.articleId == rhs.articleId
        } else {
            return lhs.articleUrl == rhs.articleUrl
        }
    }
}

extension URL {
    init?(string: String?) {
        if let url = string {
            self = URL(string: url)!
        }
        return nil
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

