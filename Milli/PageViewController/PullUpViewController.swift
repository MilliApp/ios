//
//  CardViewController.swift
//  Milli
//
//  Created by Charles Wang on 9/30/18.
//  Copyright © 2018 Milli. All rights reserved.
//

import UIKit
import DeckTransition

class PullUpViewController: UIViewController, DeckTransitionViewControllerProtocol {
    
    @IBOutlet var pageControl: UIPageControl!
    
    let tagID = "[PULL_UP_VIEW_CONTROLLER]"
    var articleURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        modalPresentationCapturesStatusBarAppearance = true
        view.backgroundColor = .white
        // view.backgroundColor = .clear  
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // This fixes scrolling behaviour for the deck.
    //
    // Conform view controller to DeckTransitionViewControllerProtocol and
    // implement the scrollViewForDeck variable to return the webView
    // UIScrollView instance to be tracked.    
    var childViewControllerForDeck: UIViewController?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PullUpPageViewController {
            childViewControllerForDeck = vc
            // Pass on current playing article URL
            vc.articleURL = articleURL
            vc.pageControl = pageControl
        }
    }
}
