//
//  HomeViewController.swift
//  Milli
//
//  Created by Charles Wang on 12/2/17.
//  Copyright © 2017 Milli. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    var miniPlayer:MiniPlayerViewController?
    
    // IBOutlets
    @IBOutlet var tableView: UITableView!
    
    // Setting initial variables
    private let tagID = "[HOME_VIEW_CONTROLLER]"
    private var remoteTransportControlsSetUp = false
    
    var pullUpViewController = ArticleViewController()
    var pullUpViewHidden = true
    var pullUpViewCollapseY = CGFloat()
    var pullUpViewExpandY = CGFloat()
    var pullUpViewHeight = CGFloat()
    
    var playbackTimer = Timer()
    private let refreshControl = UIRefreshControl()

    
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
//        pullUpViewCollapseY = self.mediaBarView.frame.origin.y
        pullUpViewExpandY = self.navigationController!.navigationBar.frame.height / -2
        // TODO(chwang): this height calculation doesn't make sense. I think
        // the article view controller should just be turned into a view with a
        // tha navigation bar is throwing this off webview
        pullUpViewHeight = pullUpViewCollapseY - pullUpViewExpandY + self.navigationController!.navigationBar.frame.height - pullUpViewExpandY
        
        // Load sample articles
        loadArticles()
        
        // Cell formatting
        self.tableView.cellLayoutMarginsFollowReadableWidth = false
        self.tableView.allowsMultipleSelectionDuringEditing = false
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableView.automaticDimension
        
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(panGesture))
//        mediaBarView.addGestureRecognizer(gesture)
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshArticles(_:)), for: .valueChanged)


        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.applicationDidBecomeActive(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc private func refreshArticles(_ sender: Any) {
        loadArticles()
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
        pullUpViewController.articleURL = ArticleManager.currentArticle!.articleUrl.absoluteString
        
        // 2- Add pullUpViewController as a child view
        self.addChild(pullUpViewController)
//        self.view.insertSubview(pullUpViewController.view, belowSubview: mediaBarView)
        pullUpViewController.didMove(toParent: self)
        
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
//        expandCollapseButton.setImage(UIImage(named: "expand-arrow-filled-50"), for: .normal)
    }
    
    func hidePullUpView() {
        UIView.animate(withDuration: 0.3, animations: {
            let frame = self.pullUpViewController.view.frame
            self.pullUpViewController.view.frame = CGRect(x: 0, y: self.pullUpViewCollapseY, width: frame.width, height: frame.height)
        })
        pullUpViewHidden = true
//        expandCollapseButton.setImage(UIImage(named: "collapse-arrow-filled-50"), for: .normal)
    }
    
    @objc func applicationDidBecomeActive(_ notification: NSNotification) {
        print_debug(tagID, message: "applicationDidBecomeActive")
        loadArticles()
    }
    
    func loadArticles() {
        for article in shareBuffer.reversed() {
            if let articleDict = article as? [String: String] {
                if articleDict.count > 1 {
                    // Only worthwhile to show articles shared from safari where preproccessing is possible
                    let partialArticle = Article(response: articleDict)
                    putArticleInModel(article: partialArticle)
                }
            }
            AWSClient.addArticle(rawArticle: article) { [weak self] in
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
            }
        }
        shareBuffer = []
        
        ArticleManager.articles = unarchiveArticles() ?? [Article]() // Set global array - only needs to be set on add or delete
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as! MainTableViewCell
        let article = ArticleManager.articles[indexPath.row]
        // TODO: show warning on invalid articles
        // Configure the cell...
        cell.articleTitle.text = article.title
        let dateStr = article.publishDate?.string ?? "No Date"
        cell.articleText.text = article.content ?? " "
        cell.articleSource.text = article.source + " | " + dateStr
        cell.articleImage.image = article.topImage?.image ?? UIImage()
        cell.articleInfo.text = "Downloading"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ArticleManager.articles.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            ArticleManager.articles.remove(at: indexPath.row)
            archive(articles: ArticleManager.articles.reversed())
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.reloadData()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    func updateProgress() {
        print("updaitng progress")
        if let currentArticleAudioPlayer = getCurrentArticleAudioPlayer() {
            // Set progress bar
            
//            mediaBarProgressView.setProgress((Float)(currentArticleAudioPlayer.progress), animated: true)
            
            // Set time label on media panel
            let timeLeft = Int64(currentArticleAudioPlayer.duration - currentArticleAudioPlayer.currentTime)
            
//            timeLabel.text = "-" + String(convertSecondsToTimeFormat(time: timeLeft))
            
            // Set progress string in article row
            let indexPath = IndexPath(row: ArticleManager.currentArticleIdx, section: 0)
            let cell = tableView.cellForRow(at: indexPath) as! MainTableViewCell
            
            cell.articleInfo.text = "\(timeLeft / 60) of \(Int64(currentArticleAudioPlayer.duration) / 60) min remaining"
        }
    }
    
    private func getCurrentArticleAudioPlayer() -> AVAudioPlayer? {
        return ArticleManager.currentArticle?.audioPlayer?.player
    }
    
    private func getCurrentArticle() -> Article? {
        return ArticleManager.currentArticle
    }
    
    private func playSelectedArticleAudio(orPause: Bool = false) {
        if let currentArticleAudioPlayer = getCurrentArticleAudioPlayer() {
            // PlayPause vs. just Play
            if currentArticleAudioPlayer.isPlaying {
                playbackTimer.invalidate()
                currentArticleAudioPlayer.pause()
//                playPauseButton.setImage(#imageLiteral(resourceName: "Play Filled-50"), for: .normal)
                
            } else {
                currentArticleAudioPlayer.play()
                playbackTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    self.updateProgress()
                }
//                playPauseButton.setImage(#imageLiteral(resourceName: "Pause Filled-50"), for: .normal)
            }
            
            // Set media bar article logo image
//            mediaBarImage.image = ArticleManager.currentArticle?.sourceLogo?.image ?? UIImage()
            updateNowPlayingInfo()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print_debug(tagID, message: "didSelectRowAt \(indexPath.row)")
        miniPlayer?.configure(article: getCurrentArticle())
        if let currentArticleAudioPlayer = getCurrentArticleAudioPlayer() {
            // If new article is selected, pause old article if it is playing
            if ArticleManager.currentArticleIdx != indexPath.row && currentArticleAudioPlayer.isPlaying {
                print_debug(tagID, message: "Pause previous article")
                currentArticleAudioPlayer.pause()
                playbackTimer.invalidate()
            }
            
            // Play newly selected article
            print_debug(tagID, message: "Play current article")
            ArticleManager.currentArticleIdx = indexPath.row
            playSelectedArticleAudio()
            setupRemoteTransportControls()
        } else {
            ArticleManager.checkForAudioUrls()
        }
    }
    
    @IBAction func playPressed(_ sender: Any) {
        print_debug(tagID, message: "Play pressed")
        playSelectedArticleAudio(orPause: true)
    }
    
    @IBAction func rewindPressed(_ sender: Any) {
        print_debug(tagID, message: "Rewind pressed")
        if let articleAudioPlayer = getCurrentArticleAudioPlayer() {
            articleAudioPlayer.currentTime -= 30
            updateNowPlayingInfo()
            playbackTimer.fire()
        }
    }
    
    @IBAction func forwardPressed(_ sender: Any) {
        print_debug(tagID, message: "Forward pressed")
        if let articleAudioPlayer = getCurrentArticleAudioPlayer() {
            articleAudioPlayer.currentTime += 30
            updateNowPlayingInfo()
            playbackTimer.fire()
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // TODO(chwang): probably can delete this segue
        if let vc = segue.destination as? PullUpViewController {
            // Pass on current playing article URL
            vc.articleURL = ArticleManager.currentArticle!.articleUrl.absoluteString
        }
        // Mini player segue
        else if let destination = segue.destination as? MiniPlayerViewController {
            miniPlayer = destination
            miniPlayer?.delegate = self
        }
    }
    
    private func updateNowPlayingInfo() {
        if let currentArticle = ArticleManager.currentArticle {
            let currentArticleAudioPlayer = getCurrentArticleAudioPlayer()!
            let image = currentArticle.sourceLogo?.image?.size ?? CGSize(width: 64, height: 64)
            MPNowPlayingInfoCenter.default().nowPlayingInfo = [
                MPMediaItemPropertyTitle: currentArticle.title,
                MPMediaItemPropertyArtwork: MPMediaItemArtwork(boundsSize: image, requestHandler: {  (_) -> UIImage in
                    return currentArticle.sourceLogo?.image ?? UIImage()
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

extension HomeViewController: MiniPlayerDelegate {
    func expandArticle(article: Article) {
        //1.
        guard let maxiCard = storyboard?.instantiateViewController(
            withIdentifier: "MaxiArticleCardViewController")
            as? MaxiArticleCardViewController else {
                assertionFailure("No view controller ID MaxiSongCardViewController in storyboard")
                return
        }
        
        //2.
        maxiCard.backingImage = view.makeSnapshot()
        //3.
//        maxiCard.currentSong = song
        maxiCard.currentArticle = article
        
        maxiCard.sourceView = miniPlayer
        
        //4.
        present(maxiCard, animated: false)
    }
}
