//
//  ArticlePlayControlViewController.swift
//  Milli
//
//  Created by Charles Wang on 1/11/19.
//  Copyright © 2019 Milli. All rights reserved.
//

import UIKit

class ArticlePlayControlViewController: UIViewController, ArticleSubscriber {
    
    // MARK: - IBOutlets
    @IBOutlet weak var articleTitle: UILabel!
    @IBOutlet weak var articleArtist: UILabel!
    @IBOutlet weak var articleDuration: UILabel!
    
    // MARK: - Properties
    var currentArticle: Article? {
        didSet {
            configureFields()
        }
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureFields()
    }
}

// MARK: - Internal
extension ArticlePlayControlViewController {

    func configureFields() {
        guard articleTitle != nil else {
            return
        }

        articleTitle.text = currentArticle?.title
        articleArtist.text = currentArticle?.source
//        articleDuration.text = "Duration \(currentArticle?.presentationTime ?? "")"
    }
}

// MARK: - Article Extension
//extension Article {
//
//    var presentationTime: String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "mm:ss"
//        let date = Date(timeIntervalSince1970: duration)
//        return formatter.string(from: date)
//    }
//}
