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

class ShareViewController: SLComposeServiceViewController {
    
    let tagID = "[SHARE_VIEW_CONTROLLER]"
    
    override func didSelectPost() {
        print(tagID, "didSelectPost...")
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    override func configurationItems() -> [Any]! {
        shareArticle()
        sleep(3)
        return []
    }
    
    func shareArticle() {
        let item = self.extensionContext?.inputItems.first as! NSExtensionItem
        let itemProvider = item.attachments?.first as! NSItemProvider
        let propertyList = String(kUTTypePropertyList)
        
        if !itemProvider.hasItemConformingToTypeIdentifier(propertyList) {
            return
        }
        
        itemProvider.loadItem(forTypeIdentifier: propertyList, completionHandler: {(item, error) -> Void in
            
            guard let processedResults = item as? NSDictionary else { return }
            OperationQueue.main.addOperation {
                if let article = processedResults[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary {
                    var articleBuffer = getShareBuffer()
                    articleBuffer.append(article)
                    setShareBuffer(with: articleBuffer)
                    
                    self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                }
            }
        })
    }
}

