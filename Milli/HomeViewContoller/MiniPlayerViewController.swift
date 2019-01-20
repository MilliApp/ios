//
//  MiniPlayerViewController.swift
//  Milli
//
//  Created by Charles Wang on 1/5/19.
//  Copyright © 2019 Milli. All rights reserved.
//

import UIKit

protocol MiniPlayerDelegate: class {
//    func expandArticle()
    func expandArticle(article: Article)
}

class MiniPlayerViewController: UIViewController {
    
    private let tagID = "[HOME_VIEW_CONTROLLER]"
    
    // MARK: - Properties
    var currentArticle: Article?
    weak var delegate: MiniPlayerDelegate?
    
    // MARK: - IBOutlets
//    @IBOutlet var mediaBarView: UIView!
    @IBOutlet var mediaBarImage: UIImageView!
    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var mediaBarProgressView: UIProgressView!
    @IBOutlet var articleTitle: UILabel!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure(article: nil)
    }
}

// MARK: - Internal
extension MiniPlayerViewController {
    
    func configure(article: Article?) {
        if let article = article {
            articleTitle.text = article.title
            mediaBarImage.image = article.sourceLogo?.image!
        } else {
            articleTitle.text = nil
            mediaBarImage.image = UIImage(named: "icon-app")
        }
        currentArticle = article
    }
}

// MARK: - IBActions
extension MiniPlayerViewController {
    
    @IBAction func tapGesture(_ sender: Any) {
        print_debug(tagID, message: "tapGesture")
        guard let article = currentArticle else {
            return
        }
        
//        delegate?.expandArticle()
        delegate?.expandArticle(article: article)
    }
}

extension MiniPlayerViewController: MaxiArticleSourceProtocol {
    var originatingFrameInWindow: CGRect {
        let windowRect = view.convert(view.frame, to: nil)
        return windowRect
    }
    
//    var originatingCoverImageView: UIImageView {
//        return thumbImage
//    }
}
