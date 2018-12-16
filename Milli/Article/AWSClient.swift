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
    static let API_URL = "https://wphd9pi355.execute-api.us-east-1.amazonaws.com/dev/audio"
    
    class func getArticleAudioMeta(article:Article) {
        print_debug(tagID, message: "[GET_ARTICLE_AUDIO_META] Loading Audio URL...")
        
        let articleMetaURL = "\(API_URL)?articleId=\(article.articleId)"
        var request = URLRequest(url: URL(string: articleMetaURL)!)
        request.httpMethod = "GET"
        
        // Execute HTTP Request
        let task = URLSession.shared.dataTask(with: request) {data, response, error  in
            // Check for error
            if error != nil {
                print("error=\(String(describing: error))")
                return
            }
            
            let str = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
            print_debug(tagID, message: str as String)
            
            do {
                if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data!, options: []) as? [NSDictionary] {
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
        }
        task.resume()
    }
    
    class func addArticle(rawArticle: NSDictionary, tableView:UITableView?) {
        // TODO: Add validation for all keys in data
        
        var request = URLRequest(url: URL(string: API_URL)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: rawArticle)
        
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            do {
                if let response = try JSONSerialization.jsonObject(with: data!) as? [String: Any] {
                    
                    let article = Article(url: rawArticle["url"] as! String, response: response)

                    getArticleAudioMeta(article: article)
                    // Loading from stored data
                    var articleArray = loadArticles() ?? [Article]()
                    articleArray.append(article)
                    saveArticles(articleArray: articleArray)
                    
                    if let table = tableView {
                        Globals.articles.insert(article, at: 0)
                        DispatchQueue.main.async {
                            print_debug(tagID, message: "Dispatch TableView reload.")
                            table.reloadData()
                        }
                    }

                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
}
