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
    
    class func getArticle(article: Article) {
        var request = URLRequest(url: URL(string: "\(API_URL)?articleId=\(article.articleId)")!)
        request.httpMethod = "GET"
        
        dataTask(with: request) { response in
            article.audioUrl = URL(string: response["audioUrl"])
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
            let article = Article(response: response)
            putArticleInModel(article: article)
            completion?()
        }
    }
    
    private class func dataTask(with request: URLRequest, completion: @escaping ([String: String]) -> ()) {
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { data, resp, err in
            if let error = err {
                print("dataTask(request:\(request), completion:\(completion)) had an error: \(error) ")
            } else {
                do {
                    if let json = data, let response = try JSONSerialization.jsonObject(with: json, options: []) as? [String: String] {
                        completion(response)
                    }
                } catch {
                    print(error.localizedDescription)
                }
                
            }
        }
        task.resume()
    }
}
