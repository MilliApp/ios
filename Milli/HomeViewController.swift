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
//        print_debug(tagID, message: "applicationDidBecomeActive")
        loadSampleArticles()
    }
    
    func loadArticles() -> [Article]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Article.ArchiveURL.path) as? [Article]
    }
    
    func saveArticles(articleArray: [Article]) {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(articleArray, toFile: Article.ArchiveURL.path)
        
        if !isSuccessfulSave {
            print("Failed to save articles...")
        }
    }
    
    func loadSampleArticles() {
//        print_debug(tagID, message: "loadSampleArticles")
        convertURLstoArticles()
        
        // Uncomment if you need to clear the archived object
//        saveArticles(articleArray: [Article]())
        
        var articles = [Article]()
        if let storedArray = loadArticles() {
            articles = storedArray.reversed()
        }
        Globals.articles = articles // Set global array - only needs to be set on add or delete
        
        self.tableView.reloadData()
    }
    
    func convertURLstoArticles(){
//        print_debug(tagID, message: "convertURLstoArticles")
        let temp = self.userDefaults?.object(forKey: "urlArray") as? [String]
        print_debug(tagID, message: "urlArray:")
        
        if var urlArray = self.userDefaults?.object(forKey: "urlArray") as? [String] {
            for (i, url) in urlArray.enumerated().reversed() {
                AWSClient.addArticle(url: url, tableView: self.tableView)
                urlArray.remove(at: i)
            }
        } else {
            print_debug(tagID, message: "Wasn't able to retrieve URL Array")
        }
        self.userDefaults?.set([String](), forKey: "urlArray")
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
        
        var dateStr: String = "No date"
        if let date = article.date {
            let formatter = DateFormatter()
            // initially set the format based on your datepicker date
            formatter.dateFormat = "dd-MMM-yyyy"
            dateStr = formatter.string(from: date)
        }
        
        cell.articleSource.text = article.source + " | " + dateStr
        let progress = Float(0.0)
        cell.articleInfo.text = "0% read"
        
        //TODO(cvwang): Store image in archive
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            Globals.articles.remove(at: indexPath.row)
//            let temp_articles = Globals.articles
            saveArticles(articleArray: Globals.articles.reversed())
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.reloadData()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    private func getCurrentArticleAudioPlayer() -> ArticleAudioPlayer {
        let article = Globals.articles[Globals.currentArticleIdx]
        let articleID = article.articleId
        // Initialize current ArticleAudioPlayer if it doesn't exist
        if Globals.articleIdAudioPlayers[articleID] == nil {
            Globals.articleIdAudioPlayers[articleID] = ArticleAudioPlayer(article: article)
            // Attach periodic time observer
//            Globals.articleIdAudioPlayers[articleID].setProgressCallback()
        }
        return Globals.articleIdAudioPlayers[articleID]!
    }
    
    func updateProgress() {
        print_debug(tagID, message: "updateProgress")
    }
    
    private func playSelectedArticleAudio(orPause: Bool = false) {
        let currentArticleAudioPlayer = getCurrentArticleAudioPlayer()
        if orPause {
            currentArticleAudioPlayer.playPause()
        } else {
            currentArticleAudioPlayer.play()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Globals.currentArticleIdx = indexPath.row
        print(Globals.currentArticleIdx)
        playSelectedArticleAudio()
    }
    
    @IBAction func playPressed(_ sender: Any) {
        print_debug(tagID, message: "Play pressed")
        playSelectedArticleAudio(orPause: true)
        if getCurrentArticleAudioPlayer().isPlaying() {
            playPauseButton.setImage(#imageLiteral(resourceName: "Pause Filled-50"), for: .normal)
        } else {
            playPauseButton.setImage(#imageLiteral(resourceName: "Play Filled-50"), for: .normal)
        }
    }
    
    @IBAction func rewindPressed(_ sender: Any) {
        print_debug(tagID, message: "Rewind pressed")
        getCurrentArticleAudioPlayer().rewind()
    }
    
    @IBAction func forwardPressed(_ sender: Any) {
        print_debug(tagID, message: "Forward pressed")
        getCurrentArticleAudioPlayer().forward()
    }
    
}
