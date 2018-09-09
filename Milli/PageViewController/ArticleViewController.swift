//
//  ArticleViewController.swift
//  Milli
//
//  Created by Charles Wang on 7/15/18.
//  Copyright © 2018 Milli. All rights reserved.
//

import UIKit
import WebKit
import DeckTransition

class ArticleViewController: UIViewController {
    
    @IBOutlet var webView: WKWebView!
    
    // Setting initial variables
    let tagID = "[ARTICLE_VIEW_CONTROLLER]"

    var articleURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print_debug(tagID, message: "viewDidLoad...")
        
        let webViewURL = URL(string: self.articleURL)
        let webViewRequest = URLRequest(url: webViewURL!)
        webView.load(webViewRequest)
    }
}
