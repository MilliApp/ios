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

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        print("isContentValid...")
        return true
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        print("didSelectPost...")
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        print("ConfigurationItems...")
        getUrlToApp()
        return []
    }
    
    func getUrlToApp() {
        let item = self.extensionContext!.inputItems[0] as! NSExtensionItem; // NSExtensionItem - first object
        let itemProvider = item.attachments![0] as! NSItemProvider; //NSItemProvider - first object
        if (itemProvider.hasItemConformingToTypeIdentifier(kUTTypeURL as String)) {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                itemProvider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil, completionHandler: {
                    (urlItem, error) in
                    if (error != nil) {
                        // Error
                        print("ERROR")
                    }
                    print("Url: ", urlItem!)
                    
                    // Get the currently stored array
                    var urlArray = [String]()
                    if let storedArray = self.userDefaults?.object(forKey: "urlArray") as? [String] {
                        
                        for item in urlArray {
                            print(item)
                        }
                        print("set urlArray to storedArray")
                        urlArray = storedArray
                    }
                    
                    // Add new url to it
                    let urlItemNS = urlItem! as! NSURL
                    urlArray.append(urlItemNS.absoluteString!)
                    
                    // Update the stored array
                    self.userDefaults!.set(urlArray, forKey: "urlArray") // Update the object
                    self.userDefaults!.synchronize() // Update the data
                    
                    self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                    
                    print(urlArray)
                    print("Here...")
                })
            }
        }
    }

}
