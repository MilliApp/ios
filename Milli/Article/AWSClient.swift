//
//  AWSClient.swift
//  Milli
//
//  Created by Charles Wang on 2/11/18.
//  Copyright © 2018 Milli. All rights reserved.
//

import Foundation

class AWSClient {
    
    private static let tagID = "[AWS_CLIENT]"
    private static let API_URL = "https://wphd9pi355.execute-api.us-east-1.amazonaws.com/dev/audio"
    
    class func getArticles(articles: [Article], completion: (() -> ())?) {
        let articleIds = articles.filter{ !$0.invalid }.map{ $0.articleId }
        let requestString = "\(API_URL)?articleId=\(articleIds.joined(separator: ","))"
        var request = URLRequest(url: URL(string: requestString)!)
        request.httpMethod = "GET"
        
        dataTask(with: request) { response in
            if let response = try? JSONSerialization.jsonObject(with: response, options: []) as! [[String: String]] {
                let articleSequence = response.compactMap { $0["articleId"] != nil ? ($0["articleId"]!, $0) : nil }
                let articleDictionary = Dictionary(uniqueKeysWithValues: articleSequence)
                
                for article in articles {
                    if let resp = articleDictionary[article.articleId] {
                        article.audioPlayer = AudioWrapper(url: URL(string: resp["audioUrl"]))
                    } else {
                        article.invalid = true
                    }
                }
                completion?()
            }
        }
    }
    
    class func addArticle(rawArticle: NSDictionary, completion: (() -> ())?) {
        print("grabbing article: \(rawArticle["articleUrl"] as! String)")
        
        // TODO: Add validation for all keys in data
        var request = URLRequest(url: URL(string: API_URL)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: rawArticle)
        
        dataTask(with: request) { response in
            if let response = try? JSONSerialization.jsonObject(with: response, options: []) as! [String: String] {
                let article = Article(response: response)
                putArticleInModel(article: article)
                completion?()
            }
            
        }
    }
    
    private class func dataTask(with request: URLRequest, completion: @escaping (Data) -> ()) {
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { data, resp, err in
            if let error = err {
                print("dataTask(request:\(request), completion:\(completion)) had an error: \(error) ")
            } else {
                if let json = data {
                    completion(json)
                }
            }
        }
        task.resume()
    }
}
