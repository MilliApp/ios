//
//  Article.swift
//  Milli
//
//  Created by Charles Wang on 12/10/17.
//  Copyright © 2017 Milli. All rights reserved.
//

import Foundation
import UIKit

func saveArticles(articleArray: [Article]) {
    let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(articleArray, toFile: Article.ArchiveURL.path)
    
    if !isSuccessfulSave {
        print("Failed to save articles...")
    }
}

func loadArticles() -> [Article]? {
    return NSKeyedUnarchiver.unarchiveObject(withFile: Article.ArchiveURL.path) as? [Article]
}

class Article: NSObject, NSCoding {
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: PropertyKey.titleKey)
        aCoder.encode(source, forKey: PropertyKey.sourceKey)
        aCoder.encode(date, forKey: PropertyKey.dateKey)
        aCoder.encode(url, forKey: PropertyKey.urlKey)
        aCoder.encode(articleId, forKey: PropertyKey.articleIdKey)
    }
    
    var title: String
    var source: String
    var date: Date
    var url: String
    var articleId: String
    
    // MARK: Properties
    struct PropertyKey {
        static let titleKey = "title"
        static let sourceKey = "source"
        static let dateKey = "date"
        static let urlKey = "url"
        static let articleIdKey = "articleId"
    }
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("articles")
    
    convenience init?(title:String, source:String, isoDate:String, url:String, articleId:String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        let date = dateFormatter.date(from:String(isoDate.prefix(19)))!
        
        self.init(title: title, source: source, date: date, url: url, articleId: articleId)
    }
    
    init?(title:String, source:String, date:Date, url:String, articleId:String) {
        self.title = title
        self.source = source
        self.date = date
        self.url = url
        self.articleId = articleId
        
        super.init()
        if title.isEmpty { // No empty articles
            return nil
        }
    }
    
    // Mark: NSCoding
    //    func encodeWithCoder(aCoder: NSCoder) {
    //        aCoder.encode(title, forKey: PropertyKey.titleKey)
    //        aCoder.encode(source, forKey: PropertyKey.sourceKey)
    //        aCoder.encode(info, forKey: PropertyKey.infoKey)
    //    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let _title = aDecoder.decodeObject(forKey: PropertyKey.titleKey) as! String
        let _source = aDecoder.decodeObject(forKey: PropertyKey.sourceKey) as! String
        let _date = aDecoder.decodeObject(forKey: PropertyKey.dateKey) as! Date
        let _url = aDecoder.decodeObject(forKey: PropertyKey.urlKey) as! String
        let _articleId = aDecoder.decodeObject(forKey: PropertyKey.articleIdKey) as? String
        
        self.init(title: _title, source: _source, date: _date, url: _url, articleId: _articleId!)
    }
    
}
