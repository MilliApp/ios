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
                    let audioURL = convertedJsonIntoDict[0]["url"] as! String
                    article.audioURL = audioURL
                    print_debug(tagID, message: "Article AudioURL: " + article.audioURL)
                    getArticleAudio(article: article)
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    class func getArticleAudio(article:Article) {
        print_debug(tagID, message: "[GET_ARTICLE_AUDIO]")
        let articleAudioURL = article.audioURL
        let url = URL(string: articleAudioURL)!
        
        print(url)
        
        var downloadTask:URLSessionDownloadTask
        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: {urlDownload, response, error  in
            print_debug(tagID, message: "Playing audio...")
            AudioPlayer.play(url: urlDownload!)
        })
        downloadTask.resume()
    }

    class func addArticle(url:String, tableView:UITableView) {
        print_debug(tagID, message: url)

        let json = ["url":url]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)

        let articleMetaAPI = "https://wphd9pi355.execute-api.us-east-1.amazonaws.com/dev/audio"
        var request = URLRequest(url: URL(string: articleMetaAPI)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
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
                    let domain = convertedJsonIntoDict["domain"] as! String
                    let title = convertedJsonIntoDict["title"] as! String
                    let publishDate = convertedJsonIntoDict["publishDate"] as! String
                    
                    let articleUrl = URL(string: url)!
                    let article = Article(title: title, source: articleUrl.host!, isoDate: publishDate, url: url, articleId: articleId)
                    
                    // Loading from stored data
                    var articleArray = [Article]()
                    if let storedArray = loadArticles() {
                        articleArray = storedArray
                    }
                    
                    // Add new article to it
                    articleArray.append(article!)
                    
                    // append articles only if not starting up
//                    if !firstLoad {
                        Globals.articles.insert(article!, at: 0)
//                    }
                    
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
}
