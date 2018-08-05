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

class ArticleViewController: UIViewController, DeckTransitionViewControllerProtocol {
    
    @IBOutlet var webView: WKWebView!
    
    // Setting initial variables
    let tagID = "[ARTICLE_VIEW_CONTROLLER]"

    var articleURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print_debug(tagID, message: "viewDidLoad...")
        
        modalPresentationCapturesStatusBarAppearance = true
        view.backgroundColor = .white
//        view.backgroundColor = .clear
        
        let webViewURL = URL(string: articleURL)
        let webViewRequest = URLRequest(url: webViewURL!)
        webView.load(webViewRequest)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // This fixes scrolling behaviour for the deck.
    //
    // Conform view controller to DeckTransitionViewControllerProtocol and
    // implement the scrollViewForDeck variable to return the webView
    // UIScrollView instance to be tracked.
    var scrollViewForDeck: UIScrollView {
        return webView.scrollView
    }
}
