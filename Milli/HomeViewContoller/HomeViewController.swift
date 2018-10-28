//
//  HomeViewController.swift
//  Milli
//
//  Created by Charles Wang on 12/2/17.
//  Copyright © 2017 Milli. All rights reserved.
//

import UIKit
import AVFoundation
import DeckTransition

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // IBOutlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var mediaBarView: UIView!
    @IBOutlet var mediaBarImage: UIImageView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var mediaBarProgressView: UIProgressView!
    
    // Setting initial variables
    let tagID = "[HOME_VIEW_CONTROLLER]"
    var userDefaults = UserDefaults(suiteName: "group.com.Milli1.Milli1")
    
    var pullUpViewController = ArticleViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print_debug(tagID, message: "viewDidLoad")
        
        // Set tableview delegate and datasource
        tableView.delegate = self
        tableView.dataSource = self
        
        // Load sample articles
        loadSampleArticles()
        
        // Cell formatting
        Globals.mainTableView = self.tableView
        self.tableView.cellLayoutMarginsFollowReadableWidth = false
        self.tableView.allowsMultipleSelectionDuringEditing = false;
        
        addPullUpView()
        
        // Assign function to media bar single tap
//        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(mediaBarSingleTapped(recognizer:)))
//        mediaBarView.addGestureRecognizer(singleTapGesture)
        
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(panGesture))
        view.addGestureRecognizer(gesture)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.applicationDidBecomeActive(_:)),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        addPullUpView()
    }
    
    @objc func panGesture(recognizer: UIPanGestureRecognizer) {
        let pullUpView = pullUpViewController.view!
        let translation = recognizer.translation(in: pullUpView)
        let y = pullUpView.frame.minY
        var pullUpTopY = y + translation.y
        let snapY = tableView.frame.maxY
//        pullUpTopY = (pullUpTopY < snapY) ? self.view.frame.minY : pullUpTopY
        pullUpView.frame = CGRect(x: 0, y: pullUpTopY, width: pullUpView.frame.width, height: pullUpView.frame.height)
        recognizer.setTranslation(CGPoint(x: 0, y: 0), in: pullUpView)
    }
    
    func addPullUpView() {
        // 1- Init pullUpViewController
//        let pullUpViewController = ArticleViewController()
        pullUpViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ArticleViewController") as! ArticleViewController
        pullUpViewController.articleURL = getCurrentArticle().url
        
        // 2- Add pullUpViewController as a child view
        self.addChildViewController(pullUpViewController)
//        self.view.addSubview(pullUpViewController.view)
        self.view.insertSubview(pullUpViewController.view, belowSubview: mediaBarView)
        pullUpViewController.didMove(toParentViewController: self)
        
        // 3- Adjust bottomSheet frame and initial position.
        let height = view.frame.height
        let width = view.frame.width
        pullUpViewController.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
        
        // Set relative z-index of pullUpView and mediaBar
//        pullUpViewController.view.layer.zPosition = 1
//        pullUpViewController.inputView?.layer.zPosition = 1
//        mediaBarView.layer.zPosition = 2
//        mediaBarView.inputView?.layer.zPosition = 2
        
//        self.view.bringSubview(toFront: mediaBarView)
        
        pullUpViewController.view.layer.cornerRadius = 5
        pullUpViewController.view.layer.masksToBounds = true
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
        print_debug(tagID, message: "loadSampleArticles")
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
        print_debug(tagID, message: "convertURLstoArticles")
        let articleBuffer = getShareBuffer()
        for article in articleBuffer.reversed() {
            AWSClient.addArticle(data: article, tableView: self.tableView)
        }
        setShareBuffer(with: [NSDictionary]())
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
        cell.articleInfo.text = "0% read"
        
        // Store image in article object archive
        cell.articleImage.image = article.sourceLogo
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Globals.articles.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            Globals.articles.remove(at: indexPath.row)
            saveArticles(articleArray: Globals.articles.reversed())
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.reloadData()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // Return string conveying current time out of total time
    // i.e. mm:ss/mm:ss
    private func getTimeString(current:Double, total:Double) -> String {
        let total_str = convertSecondsToTimeFormat(time: (Int64)(total))
        let current_str = convertSecondsToTimeFormat(time: (Int64)(current))
        let res = "(" + current_str + "/" + total_str + ")"
        return res
    }
    
    func updateProgress(time: CMTime) -> Void {
        print_debug(tagID, message: "NEW Update Progress Called")
        let currentArticleAudioPlayer = getCurrentArticleAudioPlayer()
        // This is to prevent reading the player current and total time while paused as it causes a crash
        // TODO(cvwang): Look into why there is a crash without this check
        if !currentArticleAudioPlayer.isPlaying() {
            print_debug(tagID, message: "Article is not playing")
            return
        }
        // Set progress bar
        mediaBarProgressView.setProgress((Float)(currentArticleAudioPlayer.progress()), animated: true)
        // Set time label on media panel
        timeLabel.text = "-" + String(convertSecondsToTimeFormat(time: currentArticleAudioPlayer.secondsLeft()))
        // Set progress string in article row
        let indexPath = IndexPath(row: Globals.currentArticleIdx, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! MainTableViewCell
        let currentTime = currentArticleAudioPlayer.currentTime()
        let totalTime = currentArticleAudioPlayer.totalTime()
        cell.articleInfo.text = "\(min(max(Int(floor(currentArticleAudioPlayer.progress()*100)), 0), 100))% read \(getTimeString(current: currentTime, total: totalTime))"
    }
    
    private func getCurrentArticleAudioPlayer() -> ArticleAudioPlayer {
        let article = getCurrentArticle()
        let articleID = article.articleId
        // Initialize current ArticleAudioPlayer if it doesn't exist
        if Globals.articleIdAudioPlayers[articleID] == nil {
            // Attach periodic time observer
            Globals.articleIdAudioPlayers[articleID] = ArticleAudioPlayer(article: article, callback: updateProgress)
        }
        return Globals.articleIdAudioPlayers[articleID]!
    }
    
    private func getCurrentArticle() -> Article {
        return Globals.articles[Globals.currentArticleIdx]
    }
    
    private func playSelectedArticleAudio(orPause: Bool = false) {
        let currentArticleAudioPlayer = getCurrentArticleAudioPlayer()
        
        // PlayPause vs. just Play
        if orPause {
            currentArticleAudioPlayer.playPause()
        } else {
            currentArticleAudioPlayer.play()
        }
        
        // Assign Play/Pause image based off audio player status
        if currentArticleAudioPlayer.isPlaying() {
            playPauseButton.setImage(#imageLiteral(resourceName: "Pause Filled-50"), for: .normal)
        } else {
            playPauseButton.setImage(#imageLiteral(resourceName: "Play Filled-50"), for: .normal)
        }
        
        // Set media bar article logo image
        mediaBarImage.image = getCurrentArticle().sourceLogo
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print_debug(tagID, message: "didSelectRowAt \(indexPath.row)")
        let currentArticleAudioPlayer = getCurrentArticleAudioPlayer()
        
        // If new article is selected, pause old article if it is playing
        if Globals.currentArticleIdx != indexPath.row && currentArticleAudioPlayer.isPlaying() {
            print_debug(tagID, message: "Pause previous article")
            currentArticleAudioPlayer.pause()
        }
        
        // Play newly selected article
        print_debug(tagID, message: "Play current article")
        Globals.currentArticleIdx = indexPath.row
        playSelectedArticleAudio()
    }
    
    @IBAction func playPressed(_ sender: Any) {
        print_debug(tagID, message: "Play pressed")
        playSelectedArticleAudio(orPause: true)
    }
    
    @IBAction func rewindPressed(_ sender: Any) {
        print_debug(tagID, message: "Rewind pressed")
        getCurrentArticleAudioPlayer().rewind()
    }
    
    @IBAction func forwardPressed(_ sender: Any) {
        print_debug(tagID, message: "Forward pressed")
        getCurrentArticleAudioPlayer().forward()
    }
    
    @objc func mediaBarSingleTapped(recognizer: UIGestureRecognizer) {
        print_debug(tagID, message: "Media Bar Single Tapped")
//        performSegue(withIdentifier: "pullUpSegue", sender: nil)
        
        addPullUpView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PullUpViewController {
            // Pass on current playing article URL
            vc.articleURL = getCurrentArticle().url
        }
    }
}
