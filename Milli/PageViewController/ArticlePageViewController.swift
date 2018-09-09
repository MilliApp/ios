//
//  ArticlePageViewController.swift
//  Milli
//
//  Created by Charles Wang on 8/5/18.
//  Copyright © 2018 Milli. All rights reserved.
//

import UIKit
import DeckTransition

class ArticlePageViewController: UIPageViewController, DeckTransitionViewControllerProtocol {

    // Setting initial variables
    let tagID = "[ARTICLE_PAGE_VIEW_CONTROLLER]"
    
    var articleURL = ""
    
    var articleViewController: ArticleViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ArticleViewController") as! ArticleViewController
    var controlViewController: ControlViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ControlViewController") as! ControlViewController
    
    // Enum state variables to manage presenting view controller and order
    private enum ViewState: Int {
        case ARTICLE, CONTROL
    }
    
    // Keep track of presenting view controller
    private var viewState: ViewState = .ARTICLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print_debug(tagID, message: "viewDidLoad...")
        print_debug(tagID, message: "articleURL: " + articleURL)
        
        dataSource = self as UIPageViewControllerDataSource
        
        modalPresentationCapturesStatusBarAppearance = true
        view.backgroundColor = .white
        // view.backgroundColor = .clear
        
        // Instructions for setViewControllers https://spin.atomicobject.com/2015/12/23/swift-uipageviewcontroller-tutorial/
        articleViewController.articleURL = articleURL
        setViewControllers([articleViewController], direction: .forward, animated: true, completion: nil)
        viewState = .ARTICLE
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
        return articleViewController.webView.scrollView
    }
}

extension ArticlePageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        print_debug(tagID, message: "viewControllerBefore")
        
//        if viewState.rawValue == 0 {
//            return nil
//        }
        
        if let newViewState = ViewState(rawValue: viewState.rawValue - 1) {
            viewState = newViewState
            switch viewState {
            case .ARTICLE:
                articleViewController.articleURL = articleURL
                setViewControllers([articleViewController], direction: .reverse, animated: true, completion: nil)
            case .CONTROL:
                setViewControllers([controlViewController], direction: .reverse, animated: true, completion: nil)
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        print_debug(tagID, message: "viewControllerAfter")
        
        if let newViewState = ViewState(rawValue: viewState.rawValue + 1) {
            viewState = newViewState
            switch viewState {
            case .ARTICLE:
                articleViewController.articleURL = articleURL
                setViewControllers([articleViewController], direction: .forward, animated: true, completion: nil)
                break
            case .CONTROL:
                setViewControllers([controlViewController], direction: .forward, animated: true, completion: nil)
            }
        }
        return nil
    }
}
