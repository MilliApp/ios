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
    
    class func getArticle(article: Article) {
        get(url: "\(API_URL)?articleId=\(article.articleId)") { data in
            do {
                if let response = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    print(response)
                    if let url = response["audioUrl"] as? String {
                        article.audioUrl = URL(string: url)
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        
    }
    
    class func addArticle(rawArticle: NSDictionary, tableView: UITableView?) {
        print("grabbing article: \(rawArticle["url"] as! String)")
        
        // TODO: Add validation for all keys in data
        let body = try? JSONSerialization.data(withJSONObject: rawArticle)
        post(url: API_URL, body: body!) { data in
            do {
                if let response = try JSONSerialization.jsonObject(with: (data), options: []) as? [String: String] {
                    let article = Article(response: response)
                    
                    var articleArray = unarchiveArticles() ?? [Article]()
                    if articleArray.contains(article) {
                        return
                    }
                    articleArray.append(article)
                    archive(articles: articleArray)
                    if let table = tableView {
                        DispatchQueue.main.async {
                            print_debug(tagID, message: "Dispatch TableView reload.")
                            Globals.articles.insert(article, at: 0)
                            table.reloadData()
                        }
                    }
                }
            }
            catch {
                print("Decoding Failed!: \(error)")
            }
        }
    }
    
    
    class func get(url:String, completion: @escaping (Data) -> Void) {
        let session = URLSession(configuration: .default)
        
        if let URL = URL(string: url) {
            let task = session.dataTask(with: URL) { data, resp, err in
                if let error = err {
                    print("get(url:\(url), completion:\(completion)) had an error: \(error) ")
                } else {
                    if let response = data {
                        completion(response)
                    }
                }
            }
            task.resume()
        }
    }
    
    class func post(url:String, body:Data, completion: @escaping (Data) -> Void) {
        let session = URLSession(configuration: .default)
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        let task = session.dataTask(with: request) { data, resp, err in
            if let error = err {
                print("post had an error: \(error)")
            } else {
                if let response = data {
                    completion(response)
                }
            }
        }
        task.resume()
    }
}
