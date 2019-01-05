//
//  MiniPlayerViewController.swift
//  Milli
//
//  Created by Charles Wang on 1/5/19.
//  Copyright © 2019 Milli. All rights reserved.
//

import UIKit

protocol MiniPlayerDelegate: class {
//    func expandSong(song: Song)
}

class MiniPlayerViewController: UIViewController {
    
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
