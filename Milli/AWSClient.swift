//
//  AWSClient.swift
//  Milli
//
//  Created by Charles Wang on 2/11/18.
//  Copyright © 2018 Milli. All rights reserved.
//

import Foundation

class AWSClient {
    
    static let tagID = "[AWS_CLIENT]"

    class func getArticleMeta(url: String) -> Article {
        print_debug(tagID, message: url)
        let articleUrl = NSURL(string: url)!;
        let article = Article(title: "Test Yahoo Article. Trump.", source: articleUrl.host!, info: "Feb 11, 2018", url: url)
        return article!
    }
}
