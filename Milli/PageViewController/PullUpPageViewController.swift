//
//  ArticlePageViewController.swift
//  Milli
//
//  Created by Charles Wang on 8/5/18.
//  Copyright © 2018 Milli. All rights reserved.
//

import UIKit
import DeckTransition

class PullUpPageViewController: UIPageViewController, DeckTransitionViewControllerProtocol {

    // Setting initial variables
    let tagID = "[PULL_UP_PAGE_VIEW_CONTROLLER]"
    
    var articleURL = ""
    
    var pageControl = UIPageControl()
    var articleViewController: ArticleViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ArticleViewController") as! ArticleViewController
    var controlViewController: ControlViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ControlViewController") as! ControlViewController
    
    // DeckTransitionViewControllerProtocol
    var scrollViewForDeck: UIScrollView {
        return articleViewController.webView.scrollView
    }
    
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
//        setViewControllers([controlViewController], direction: .forward, animated: true, completion: nil)
        viewState = .ARTICLE
    }
}

extension PullUpPageViewController: UIPageViewControllerDataSource {
    
    private func pageUpdate(newViewState: ViewState, forwardAnimation:Bool) {
        pageControl.currentPage = newViewState.rawValue
        viewState = newViewState
        let directionAnimation = forwardAnimation ? NavigationDirection.forward : NavigationDirection.reverse
        switch viewState {
        case .ARTICLE:
            print_debug(tagID, message: "here1")
            articleViewController.articleURL = articleURL
            setViewControllers([articleViewController], direction: directionAnimation, animated: true, completion: nil)
        case .CONTROL:
            print_debug(tagID, message: "here2")
            setViewControllers([controlViewController], direction: directionAnimation, animated: true, completion: nil)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        print_debug(tagID, message: "viewControllerBefore")
        if let newViewState = ViewState(rawValue: viewState.rawValue - 1) {
            pageUpdate(newViewState: newViewState, forwardAnimation: false)
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        print_debug(tagID, message: "viewControllerAfter")
        if let newViewState = ViewState(rawValue: viewState.rawValue + 1) {
            pageUpdate(newViewState: newViewState, forwardAnimation: true)
        }
        return nil
    }
}
