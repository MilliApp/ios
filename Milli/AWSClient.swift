//
//  AWSClient.swift
//  Milli
//
//  Created by Charles Wang on 2/11/18.
//  Copyright © 2018 Milli. All rights reserved.
//

import Foundation
import UIKit

class AWSClient {
    
    static let tagID = "[AWS_CLIENT]"
    
    class func getArticleAudioMeta(article:Article) {
        print_debug(tagID, message: "[GET_ARTICLE_AUDIO_META] Loading Audio URL...")
        
        let articleMetaURL = "https://wphd9pi355.execute-api.us-east-1.amazonaws.com/dev/audio?articleId=" + article.articleId
        var request = URLRequest(url: URL(string: articleMetaURL)!)
        request.httpMethod = "GET"
        
        // Execute HTTP Request
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {data, response, error  in
            // Check for error
            if error != nil {
                print("error=\(String(describing: error))")
                return
            }
            
            let str = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
            print_debug(tagID, message: str as String)
            
            do {
                if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data!, options: []) as? [NSDictionary] {
                    print(convertedJsonIntoDict)
                    //TODO(chwang): ask alex to change this endpoint to return just single JSON object instead of array of one object
                    if let audioURL = convertedJsonIntoDict[0]["url"] as? String {
                        article.audioURL = audioURL
                        print_debug(tagID, message: "[GET_ARTICLE_AUDIO_META] Article AudioURL retrieved: " + article.audioURL!)
                    } else {
                        print_debug(tagID, message: "[GET_ARTICLE_AUDIO_META] Audio URL not ready yet on backend...")
                    }
//                    getArticleAudio(article: article)
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    class func addArticle(data: NSDictionary, tableView:UITableView) {
        guard let url = data["url"] as? String else {
            print("data doesn't contain url", data)
            return
        }
        print_debug(tagID, message: url)
        
        let articleMetaAPI = handleArticleEndpoint(url)
        var request = URLRequest(url: URL(string: articleMetaAPI)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: data)
        
        // Execute HTTP Request
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {data, response, error  in
            
            let str = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
            print_debug(tagID, message: str as String)
            
            // Check for error
            if error != nil {
                print("error=\(String(describing: error))")
                return
            }
            
            // Convert server json response to NSDictionary
            do {
                if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    let articleId = convertedJsonIntoDict["articleId"] as! String
                    let title = convertedJsonIntoDict["title"] as! String
                    let publishDate = convertedJsonIntoDict["publishDate"] as? String
                    
                    // Retrieve source and article logo image
                    let articleUrl = URL(string: url)!
                    let source = articleUrl.host!
                    let logoURL = NSURL(string: "https://logo.clearbit.com/" + source)
                    let data = NSData(contentsOf: logoURL! as URL)
                    let sourceLogo = UIImage(data: data! as Data)

                    let article = Article(title: title, source: source, isoDate: publishDate, url: url, articleId: articleId, sourceLogo: sourceLogo!)!
                    getArticleAudioMeta(article: article)
                    
                    // Loading from stored data
                    var articleArray = [Article]()
                    if let storedArray = loadArticles() {
                        articleArray = storedArray
                    }
                    
                    // Add new article to it
                    articleArray.append(article)
                    Globals.articles.insert(article, at: 0)
                    
                    // Update the stored array
                    saveArticles(articleArray: articleArray)
                    print_debug(tagID, message: "Done saving new article.")
                    
                    DispatchQueue.main.async {
                        print_debug(tagID, message: "Dispatch TableView reload.")
                        tableView.reloadData()
                        
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    class func handleArticleEndpoint(_ url: String) -> String {
        if hasPaywall(url) {
            return "https://wphd9pi355.execute-api.us-east-1.amazonaws.com/dev/audio"
        } else {
            return "https://wphd9pi355.execute-api.us-east-1.amazonaws.com/dev/raw_html"
        }
    }
    
    class func hasPaywall(_ url: String) -> Bool {
        let paywalls = ["wsj", "nytimes", "economist"]
        for paywall in paywalls {
            if url.range(of: paywall + ".com") != nil {
                return true
            }
        }
        return false
    }
    

}
