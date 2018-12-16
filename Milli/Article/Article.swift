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

@objc(Article)
class Article: NSObject, NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: PropertyKey.titleKey)
        aCoder.encode(content, forKey: PropertyKey.contentKey)
        aCoder.encode(date, forKey: PropertyKey.dateKey)
        aCoder.encode(url, forKey: PropertyKey.urlKey)
        aCoder.encode(articleId, forKey: PropertyKey.articleIdKey)
        aCoder.encode(audioURL, forKey: PropertyKey.audioURLKey)
        aCoder.encode(sourceLogo, forKey: PropertyKey.sourceLogoKey)
    }
    
    var title: String
    var source: String
    var date: Date?
    var url: String
    var articleId: String
    var audioURL: String?
    var sourceLogo: UIImage
    var content: String?
    
    // MARK: Properties
    struct PropertyKey {
        static let titleKey = "title"
        static let dateKey = "date"
        static let urlKey = "url"
        static let articleIdKey = "articleId"
        static let audioURLKey = "audioURL"
        static let sourceLogoKey = "sourceLogo"
        static let contentKey = "content"
    }
    
    // MARK: Archiving Paths
//    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let DocumentsDirectory = FileManager().containerURL(forSecurityApplicationGroupIdentifier: "group.com.Milli1.Milli1")!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("articles")
    
    init?(title:String, date:Date?, content:String?, url:String, articleId:String, sourceLogo:UIImage) {
        self.title = title
        self.source = URL(string: url)!.host!
        self.date = date
        self.url = url
        self.articleId = articleId
        self.sourceLogo = sourceLogo
        self.content = content
        
        super.init()
        if title.isEmpty { // No empty articles
            //Indicates a point at which initilization failure canbe triggered
            return nil
        }
    }
    
    init(url: String, response: [String: Any]) {
        self.title = response["title"] as! String
        self.articleId = response["articleId"] as! String
        self.date = convertDate(fromISO: response["publishDate"] as? String)
        self.url = url
        self.source = URL(string: url)!.host!
        self.sourceLogo = Article.getLogo(for: self.source)
        self.content = response["content"] as? String
        super.init()
    }
    
    convenience init?(title:String, isoDate:String?, content:String?, url:String, articleId:String, sourceLogo:UIImage) {
        var date: Date? = nil
        if let dateStr = isoDate {
            date = convertDate(fromISO: dateStr)
        }
        self.init(title: title, date: date, content: content, url: url, articleId: articleId, sourceLogo: sourceLogo)
    }
    
    convenience init?(title:String, date:Date?, content:String?, url:String, articleId:String, audioURL:String?, sourceLogo:UIImage) {
        self.init(title: title, date: date, content: content, url: url, articleId: articleId, sourceLogo: sourceLogo)
        self.audioURL = audioURL
    }
    
    // Mark: NSCoding
    //    func encodeWithCoder(aCoder: NSCoder) {
    //        aCoder.encode(title, forKey: PropertyKey.titleKey)
    //        aCoder.encode(source, forKey: PropertyKey.sourceKey)
    //        aCoder.encode(info, forKey: PropertyKey.infoKey)
    //    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let _title = aDecoder.decodeObject(forKey: PropertyKey.titleKey) as! String
        let _date = aDecoder.decodeObject(forKey: PropertyKey.dateKey) as? Date
        let _content = aDecoder.decodeObject(forKey: PropertyKey.contentKey) as? String
        let _url = aDecoder.decodeObject(forKey: PropertyKey.urlKey) as! String
        let _articleId = aDecoder.decodeObject(forKey: PropertyKey.articleIdKey) as! String
        let _audioURL = aDecoder.decodeObject(forKey: PropertyKey.audioURLKey) as? String
        let _sourceLogo = aDecoder.decodeObject(forKey: PropertyKey.sourceLogoKey) as! UIImage
        
        // TODO(cvwang): Create safe way to decode these objects without crashing app
        
        self.init(title: _title, date: _date, content: _content, url: _url, articleId: _articleId, audioURL: _audioURL, sourceLogo: _sourceLogo)
    }
    
    static func getLogo(for source:String) -> UIImage {
        let logoURL = NSURL(string: "https://logo.clearbit.com/" + source)
        let data = NSData(contentsOf: logoURL! as URL)
        return UIImage(data: data! as Data)!
    }
    
}
