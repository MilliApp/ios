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
    
    var userDefaults = UserDefaults(suiteName: "group.com.Milli.Milli")

    override func viewDidLoad() {
        print(tagID + "viewDidLoad...")
    }
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        print(tagID + "isContentValid...")
        return true
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        print(tagID + "didSelectPost...")
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        print(tagID + "ConfigurationItems...")
        getUrlToApp()
        sleep(5)
        return []
    }
    
    func getUrlToApp() {
        let item = self.extensionContext?.inputItems.first as! NSExtensionItem; // NSExtensionItem - first object
        let itemProvider = item.attachments?.first as! NSItemProvider; //NSItemProvider - first object
        let propertyList = String(kUTTypePropertyList)
        if itemProvider.hasItemConformingToTypeIdentifier(propertyList) {
            itemProvider.loadItem(forTypeIdentifier: propertyList, options: nil, completionHandler: { (item, error) -> Void in
                guard let dictionary = item as? NSDictionary else { return }
                OperationQueue.main.addOperation {
                    if let results = dictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary,
                        let urlString = results["URL"] as? String,
                        let url = NSURL(string: urlString) {
                        
                        print(results)
                        print("URL retrieved: \(urlString)")
                        // Get the currently stored array
                        var urlArray = [String]()
                        if let storedArray = self.userDefaults?.object(forKey: "urlArray") as? [String] {
                            
                            for item in urlArray {
                                print(self.tagID + item)
                            }
                            print(self.tagID + "set urlArray to storedArray")
                            urlArray = storedArray
                        }
                        
                        // Add new url to it
                        let urlItemNS = url
                        urlArray.append(urlItemNS.absoluteString!)
                        
                        // Update the stored array
                        self.userDefaults!.set(urlArray, forKey: "urlArray") // Update the object
                        self.userDefaults!.synchronize() // Update the data
                        
                        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                        
                        print(urlArray)
                        print(self.tagID + "Here...")
                    }
                }
            })
        }
    }
}

