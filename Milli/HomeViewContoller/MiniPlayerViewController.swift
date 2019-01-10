//
//  MiniPlayerViewController.swift
//  Milli
//
//  Created by Charles Wang on 1/5/19.
//  Copyright © 2019 Milli. All rights reserved.
//

import UIKit

protocol MiniPlayerDelegate: class {
//    func expandSong(article: Article)
    func expandArticle()
}

class MiniPlayerViewController: UIViewController {
    
    private let tagID = "[HOME_VIEW_CONTROLLER]"
    
    // MARK: - Properties
    weak var delegate: MiniPlayerDelegate?
    
    // MARK: - IBOutlets
//    @IBOutlet var mediaBarView: UIView!
    @IBOutlet var mediaBarImage: UIImageView!
    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var mediaBarProgressView: UIProgressView!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - IBActions
extension MiniPlayerViewController {
    
    @IBAction func tapGesture(_ sender: Any) {
        print_debug(tagID, message: "tapGesture")
//        guard let song = currentSong else {
//            return
//        }
        
//        delegate?.expandSong(article: song)
        delegate?.expandArticle()
    }
}
