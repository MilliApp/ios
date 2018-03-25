//
//  Article.swift
//  Milli
//
//  Created by Charles Wang on 12/10/17.
//  Copyright © 2017 Milli. All rights reserved.
//

import Foundation
import UIKit

class Article: NSObject, NSCoding {
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: PropertyKey.titleKey)
        aCoder.encode(source, forKey: PropertyKey.sourceKey)
        aCoder.encode(info, forKey: PropertyKey.infoKey)
        aCoder.encode(url, forKey: PropertyKey.urlKey)
//        aCoder.encode(content, forKey: PropertyKey.contentKey)
//        aCoder.encode(location, forKey: PropertyKey.locationKey)
    }
    
    var title: String
    var source: String
    var info: String
    var url: String
//    var content: String
//    var location: Int
    
    // MARK: Properties
    struct PropertyKey {
        static let titleKey = "title"
        static let sourceKey = "source"
        static let infoKey = "info"
        static let urlKey = "url"
//        static let contentKey = "content"
//        static let locationKey = "location"
    }
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("articles")
    
    init?(title: String, source: String, info: String, url: String) {
        self.title = title
        self.source = source
        self.info = info
        self.url = url
//        self.content = content
//        self.location = location
        
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
    //        aCoder.encode(content, forKey: PropertyKey.contentKey)
    //        aCoder.encode(location, forKey: PropertyKey.locationKey)
    //    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let _title = aDecoder.decodeObject(forKey: PropertyKey.titleKey) as! String
        let _source = aDecoder.decodeObject(forKey: PropertyKey.sourceKey) as! String
        let _info = aDecoder.decodeObject(forKey: PropertyKey.infoKey) as! String
        let _url = aDecoder.decodeObject(forKey: PropertyKey.urlKey) as! String
//        let _content = aDecoder.decodeObject(forKey: PropertyKey.contentKey) as! String
//        let _location = aDecoder.decodeObject(forKey: PropertyKey.locationKey) as! Int
        
//        self.init(title: _title, source: _source, info: _info, content: _content, location: _location)
        self.init(title: _title, source: _source, info: _info, url: _url)
    }
    
}
