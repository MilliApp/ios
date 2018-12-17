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
import MediaPlayer

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // IBOutlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var mediaBarView: UIView!
    @IBOutlet var mediaBarImage: UIImageView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var mediaBarProgressView: UIProgressView!
    @IBOutlet var expandCollapseButton: UIButton!
    
    // Setting initial variables
    private let tagID = "[HOME_VIEW_CONTROLLER]"
    private var userDefaults = UserDefaults(suiteName: "group.com.Milli1.Milli1")
    private var remoteTransportControlsSetUp = false
    
    var pullUpViewController = ArticleViewController()
    var pullUpViewHidden = true
    var pullUpViewCollapseY = CGFloat()
    var pullUpViewExpandY = CGFloat()
    var pullUpViewHeight = CGFloat()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print_debug(tagID, message: "viewDidLoad")
        
        // Set tableview delegate and datasource
        tableView.delegate = self
        tableView.dataSource = self
        
//        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        edgesForExtendedLayout = []
        self.navigationController?.navigationBar.layer.zPosition = -1
        
        // Initialize variables
        pullUpViewCollapseY = self.mediaBarView.frame.origin.y
        pullUpViewExpandY = self.navigationController!.navigationBar.frame.height / -2
        // TODO(chwang): this height calculation doesn't make sense. I think
        // the article view controller should just be turned into a view with a
        // tha navigation bar is throwing this off webview
        pullUpViewHeight = pullUpViewCollapseY - pullUpViewExpandY + self.navigationController!.navigationBar.frame.height - pullUpViewExpandY
        
        // Load sample articles
        loadSampleArticles()
        
        // Cell formatting
        Globals.mainTableView = self.tableView
        self.tableView.cellLayoutMarginsFollowReadableWidth = false
        self.tableView.allowsMultipleSelectionDuringEditing = false
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(panGesture))
        mediaBarView.addGestureRecognizer(gesture)

        if articleExists() {
            addPullUpView()
        }
        
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
        print_debug(tagID, message: "panGesture")
        
        let pullUpView = pullUpViewController.view!
        let translation = recognizer.translation(in: pullUpView)
        let y = pullUpView.frame.minY
        let pullUpTopY = y + translation.y
        let snapY = tableView.frame.maxY
//        pullUpTopY = (pullUpTopY < snapY) ? self.view.frame.minY : pullUpTopY
        pullUpView.frame = CGRect(x: 0, y: pullUpTopY, width: pullUpView.frame.width, height: pullUpView.frame.height)
        print_debug(tagID, message: "\(pullUpTopY)")
        recognizer.setTranslation(CGPoint(x: 0, y: 0), in: pullUpView)
    }
    
    func addPullUpView() {
        // 1- Init pullUpViewController
        pullUpViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ArticleViewController") as! ArticleViewController
        pullUpViewController.articleURL = getCurrentArticle()!.url
        
        // 2- Add pullUpViewController as a child view
        self.addChildViewController(pullUpViewController)
        self.view.insertSubview(pullUpViewController.view, belowSubview: mediaBarView)
        pullUpViewController.didMove(toParentViewController: self)
        
        // 3- Adjust bottomSheet frame and initial position.
        let height = pullUpViewHeight
//        let height = pullUpViewCollapseY - pullUpViewExpandY + pullUpViewController.navigationController!.navigationBar.frame.height
        let width = view.frame.width
        pullUpViewController.view.frame = CGRect(x: 0, y: pullUpViewCollapseY, width: width, height: height)
        
        pullUpViewController.view.layer.cornerRadius = 5
        pullUpViewController.view.layer.masksToBounds = true
    }
    
    func showPullUpView() {
        UIView.animate(withDuration: 0.3, animations: {
            let frame = self.pullUpViewController.view.frame
            self.pullUpViewController.view.frame = CGRect(x: 0, y: self.pullUpViewExpandY, width: frame.width, height: frame.height)
        })
        pullUpViewHidden = false
        expandCollapseButton.setImage(UIImage(named: "expand-arrow-filled-50"), for: .normal)
    }
    
    func hidePullUpView() {
        UIView.animate(withDuration: 0.3, animations: {
            let frame = self.pullUpViewController.view.frame
            self.pullUpViewController.view.frame = CGRect(x: 0, y: self.pullUpViewCollapseY, width: frame.width, height: frame.height)
        })
        pullUpViewHidden = true
        expandCollapseButton.setImage(UIImage(named: "collapse-arrow-filled-50"), for: .normal)
    }
    
    @objc func applicationDidBecomeActive(_ notification: NSNotification) {
        print_debug(tagID, message: "applicationDidBecomeActive")
        loadSampleArticles()
    }
    
    func loadSampleArticles() {
        print_debug(tagID, message: "loadSampleArticles")
        convertURLstoArticles()
        
        // Uncomment if you need to clear the archived object
//        saveArticles(articleArray: [Article]())

        Globals.articles = loadArticles() ?? [Article]() // Set global array - only needs to be set on add or delete
        print(Globals.articles)
        self.tableView.reloadData()
    }
    
    func convertURLstoArticles(){
        let articleBuffer = getShareBuffer()
        for article in articleBuffer.reversed() {
            AWSClient.addArticle(rawArticle: article, tableView: self.tableView)
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
        cell.articleText.text = article.content ?? ""
        cell.articleSource.text = article.source + " | " + dateStr
        cell.articleImage.image = article.sourceLogo
        cell.articleInfo.text = "Downloading"

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
    private func getTimeString(current:Int64, total:Int64) -> String {
        let total_str = convertSecondsToTimeFormat(time:total)
        let current_str = convertSecondsToTimeFormat(time: current)
        let res = "(" + current_str + "/" + total_str + ")"
        return res
    }
    
    func updateProgress(time: CMTime) -> Void {
        if let currentArticleAudioPlayer = getCurrentArticleAudioPlayer() {
            // Set progress bar
            mediaBarProgressView.setProgress((Float)(currentArticleAudioPlayer.progress), animated: true)
            
            // Set time label on media panel
            let timeLeft = Int64(currentArticleAudioPlayer.duration - currentArticleAudioPlayer.currentTime)
            
            timeLabel.text = "-" + String(convertSecondsToTimeFormat(time: timeLeft))
            
            // Set progress string in article row
            let indexPath = IndexPath(row: Globals.currentArticleIdx, section: 0)
            let cell = tableView.cellForRow(at: indexPath) as! MainTableViewCell

            cell.articleInfo.text = "\(timeLeft / 60) of \(Int64(currentArticleAudioPlayer.duration) / 60) min remaining"
        }
    }
    
    private func getCurrentArticleAudioPlayer() -> ArticleAudioPlayer? {
        if let article = getCurrentArticle() {
            let articleID = article.articleId
            // Initialize current ArticleAudioPlayer if it doesn't exist
            if Globals.articleIdAudioPlayers[articleID] == nil {
                // Attach periodic time observer
                Globals.articleIdAudioPlayers[articleID] = ArticleAudioPlayer(article: article, callback: updateProgress)
            }
            return Globals.articleIdAudioPlayers[articleID]!
        }
        return nil
    }
    
    private func articleExists() -> Bool {
        return Globals.articles.count != 0
    }
    
    private func getCurrentArticle() -> Article? {
        if articleExists() {
            return Globals.articles[Globals.currentArticleIdx]
        }
        return nil
    }
    
    private func playSelectedArticleAudio(orPause: Bool = false) {
        if let currentArticleAudioPlayer = getCurrentArticleAudioPlayer() {
            // PlayPause vs. just Play
            if orPause {
                currentArticleAudioPlayer.togglePlayPause()
            } else {
                currentArticleAudioPlayer.play()
            }
            
            // Assign Play/Pause image based off audio player status
            if currentArticleAudioPlayer.isPlaying {
                playPauseButton.setImage(#imageLiteral(resourceName: "Pause Filled-50"), for: .normal)
            } else {
                playPauseButton.setImage(#imageLiteral(resourceName: "Play Filled-50"), for: .normal)
            }
            
            // Set media bar article logo image
            mediaBarImage.image = getCurrentArticle()?.sourceLogo
            updateNowPlayingInfo()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print_debug(tagID, message: "didSelectRowAt \(indexPath.row)")
        if let currentArticleAudioPlayer = getCurrentArticleAudioPlayer() {
            // If new article is selected, pause old article if it is playing
            if Globals.currentArticleIdx != indexPath.row && currentArticleAudioPlayer.isPlaying {
                print_debug(tagID, message: "Pause previous article")
                currentArticleAudioPlayer.togglePlayPause()
            }
            
            // Play newly selected article
            print_debug(tagID, message: "Play current article")
            Globals.currentArticleIdx = indexPath.row
            playSelectedArticleAudio()
            setupRemoteTransportControls()
        }
    }
    
    @IBAction func playPressed(_ sender: Any) {
        print_debug(tagID, message: "Play pressed")
        playSelectedArticleAudio(orPause: true)
    }
    
    @IBAction func rewindPressed(_ sender: Any) {
        print_debug(tagID, message: "Rewind pressed")
        if let articleAudioPlayer = getCurrentArticleAudioPlayer() {
            articleAudioPlayer.seek(to: -30, completion: updateNowPlayingInfo)
        }
    }
    
    @IBAction func forwardPressed(_ sender: Any) {
        print_debug(tagID, message: "Forward pressed")
        if let articleAudioPlayer = getCurrentArticleAudioPlayer() {
            articleAudioPlayer.seek(to: 30, completion: updateNowPlayingInfo)
        }
    }
    
    @IBAction func expandCollapsePressed(_ sender: Any) {
        print_debug(tagID, message: "Expand collapse pressed")
        if (pullUpViewHidden) {
            showPullUpView()
        } else {
            hidePullUpView()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PullUpViewController {
            // Pass on current playing article URL
            vc.articleURL = getCurrentArticle()!.url
        }
    }
    
    private func updateNowPlayingInfo() {
        if let currentArticle = getCurrentArticle() {
            let currentArticleAudioPlayer = getCurrentArticleAudioPlayer()!
            
            MPNowPlayingInfoCenter.default().nowPlayingInfo = [
                MPMediaItemPropertyTitle: currentArticle.title,
                MPMediaItemPropertyArtwork: MPMediaItemArtwork(boundsSize: currentArticle.sourceLogo.size, requestHandler: {  (_) -> UIImage in
                    return currentArticle.sourceLogo
                }),
                MPNowPlayingInfoPropertyElapsedPlaybackTime: currentArticleAudioPlayer.currentTime,
                MPMediaItemPropertyPlaybackDuration: currentArticleAudioPlayer.duration,
                MPNowPlayingInfoPropertyPlaybackRate: currentArticleAudioPlayer.rate
            ]
        }
    }
    
    private func setupRemoteTransportControls() {
        if remoteTransportControlsSetUp {
            return
        }
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [unowned self] event in
            self.playPressed(self)
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            self.playPressed(self)
            return .success
        }
        
        let skipBackwardCommand = commandCenter.skipBackwardCommand
        skipBackwardCommand.isEnabled = true
        skipBackwardCommand.preferredIntervals = [30]
        skipBackwardCommand.addTarget { [unowned self] event in
            self.rewindPressed(self)
            return .success
        }
        
        let skipForwardCommand = commandCenter.skipForwardCommand
        skipForwardCommand.isEnabled = true
        skipForwardCommand.preferredIntervals = [30]
        skipForwardCommand.addTarget { [unowned self] event in
            self.forwardPressed(self)
            return .success
        }
        remoteTransportControlsSetUp = true
    }
    
}
