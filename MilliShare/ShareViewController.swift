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
    override func viewDidLoad() {
        super.viewDidLoad()
        shareArticle()
    }
    
    func shareArticle() {
        let item = self.extensionContext?.inputItems.first as! NSExtensionItem
        let itemProvider = item.attachments?.first as! NSItemProvider
        let propertyList = String(kUTTypePropertyList)
        
        if itemProvider.hasItemConformingToTypeIdentifier(propertyList) {
            itemProvider.loadItem(forTypeIdentifier: propertyList) {(item, _) -> Void in
                if let processedResults = item as? NSDictionary, let article = processedResults[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary {
                    AWSClient.addArticle(rawArticle: article, tableView: nil)
                    self.extensionContext?.completeRequest(returningItems: nil)
                }
            }
        }
    }
}

