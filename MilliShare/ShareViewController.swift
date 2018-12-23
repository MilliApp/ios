//
//  ShareViewController.swift
//  MilliShare
//
//  Created by Charles Wang on 1/10/18.
//  Copyright © 2018 Milli. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

class ShareViewController: UIViewController {
    @IBOutlet weak var savedDialog: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDialog()
        shareArticle()
        
        _ = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { _ in
            self.complete()
        })
    }
    
    func complete() {
        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
    
    
    func shareArticle() {
        guard let item = self.extensionContext?.inputItems.first as? NSExtensionItem else { return }
        guard let itemProvider = item.attachments?.first else { return }
        
        if itemProvider.hasItemConformingToTypeIdentifier(kUTTypePropertyList as String) {
            itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) { item, _ in
                if let response = item as? NSDictionary, let article = response[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary {
                    self.shareArticle(article: article)
                }
            }
        } else if itemProvider.hasItemConformingToTypeIdentifier("public.url") {
            itemProvider.loadItem(forTypeIdentifier: "public.url") { item, _ in
                if let url = item as? URL {
                    self.shareArticle(article: ["articleUrl": url.absoluteString])
                }
            }
        }
    }
    
    func shareArticle(article: NSDictionary) {
        shareBuffer += [article]
        AWSClient.addArticle(rawArticle: article, completion: nil)
    }
    
    func setUpDialog() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ShareViewController.tapped(recognizer:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(tapGestureRecognizer)
        savedDialog.layer.cornerRadius = 5;
        savedDialog.layer.masksToBounds = true;
        
        // TODO: Animate Dialog Popup
    }
    
    @objc func tapped(recognizer: UITapGestureRecognizer) {
        print("tapped")
        complete()
    }
    
    
}

