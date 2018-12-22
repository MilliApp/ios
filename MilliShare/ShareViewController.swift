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
        let item = self.extensionContext?.inputItems.first as! NSExtensionItem
        let itemProvider = item.attachments?.first as! NSItemProvider
        let propertyList = String(kUTTypePropertyList)
        
        if itemProvider.hasItemConformingToTypeIdentifier(propertyList) {
            itemProvider.loadItem(forTypeIdentifier: propertyList) {(item, _) -> Void in
                if let processedResults = item as? NSDictionary, let article = processedResults[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary {
                    var articleBuffer = getShareBuffer()
                    articleBuffer.append(article)
                    setShareBuffer(with: articleBuffer)
                }
            }
        }
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

