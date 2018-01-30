//
//  HomeViewController.swift
//  Milli
//
//  Created by Charles Wang on 12/2/17.
//  Copyright © 2017 Milli. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var mediaBarImage: UIImageView!
    @IBOutlet var mediaBarProgressView: UIProgressView!
    @IBOutlet var timeLabel: UILabel!
    
    @IBOutlet var playPauseButton: UIButton!
    
    // Setting initial variables
    let tagID = "[HOME_VIEW_CONTROLLER]"
    var userDefaults = UserDefaults(suiteName: "group.com.Milli.Milli")
//    var pollyArray = [TextToSpeechPolly]()
    var articleImages = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print_debug(tagID, message: "viewDidLoad")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        loadSampleArticles()
        
        Globals.mainTableView = self.tableView
        self.tableView.cellLayoutMarginsFollowReadableWidth = false
        self.tableView.allowsMultipleSelectionDuringEditing = false;
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.applicationDidBecomeActive(_:)),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
    }
    
    @objc func applicationDidBecomeActive(_ notification: NSNotification) {
        print_debug(tagID, message: "applicationDidBecomeActive")
        loadSampleArticles()
    }
    
    func parseArticle(url:String, firstLoad:Bool) -> Void {
        print_debug(tagID, message: "parseArticle")
        print_debug(tagID, message: url)
    }
    
    func convertURLstoArticles(firstLoad: Bool){
        print_debug(tagID, message: "convertURLstoArticles")
        
//        if var urlArray = self.userDefaults?.objectForKey("urlArray") as? [String] {
//            //            print("URL Array from App: ", urlArray)
//            for (i,url) in urlArray.enumerate().reverse() {
//                parseArticle(url,firstLoad: firstLoad)
//                urlArray.removeAtIndex(i)
//            }
//        } else {
//            "Wasn't able to retrieve URL Array"
//        }
//        // Update urlArray
//        self.userDefaults!.setObject([String](), forKey: "urlArray") // Update the object
        
        let temp = self.userDefaults?.object(forKey: "urlArray") as? [String]
        print_debug(tagID, message: "urlArray:")
        print(temp!.count as Int)
        
        if var urlArray = self.userDefaults?.object(forKey: "urlArray") as? [String] {
            for (i, url) in urlArray.enumerated().reversed() {
                parseArticle(url: url, firstLoad: firstLoad)
                urlArray.remove(at: i)
            }
        } else {
            print_debug(tagID, message: "Wasn't able to retrieve URL Array")
        }
        self.userDefaults?.set([String](), forKey: "urlArray")
    }
    
    func loadSampleArticles() {
        print_debug(tagID, message: "loadSampleArticles")
        convertURLstoArticles(firstLoad: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as! MainTableViewCell
        let article = Globals.articles[indexPath.row]
        
        // Configure the cell...
        cell.articleTitle.text = article.title
        cell.articleSource.text = article.source + " | " + article.info
        let progress = Float(0.0)
        cell.articleInfo.text = "0% read"
        
        let url = NSURL(string: "https://logo.clearbit.com/" + article.source)
        let data = NSData(contentsOf: url! as URL)
        let image = UIImage(data: data! as Data)
        cell.articleImage.image = image
        articleImages.append(image!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Globals.articles.count
    }
    
}
