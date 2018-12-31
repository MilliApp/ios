//
//  ArticleViewController.swift
//  Milli
//
//  Created by Charles Wang on 7/15/18.
//  Copyright © 2018 Milli. All rights reserved.
//

import UIKit
import WebKit

class ArticleViewController: UIViewController {
    
    @IBOutlet var webView: WKWebView!
    
    // Setting initial variables
    let tagID = "[ARTICLE_VIEW_CONTROLLER]"

    var articleURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print_debug(tagID, message: "viewDidLoad...")
        
        let webViewURL = URL(string: "https://www.google.com")
//        let webViewURL = URL(string: self.articleURL)
        let webViewRequest = URLRequest(url: webViewURL!)
        webView.load(webViewRequest)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        UIView.animate(withDuration: 0.3, animations: {
//            let frame = self.view.frame
//            let yComponent = UIScreen.main.bounds.height - 200
//            self.view.frame = CGRect(x: 0, y: yComponent, width: frame.width, height: frame.height)
//        })
    }
}
