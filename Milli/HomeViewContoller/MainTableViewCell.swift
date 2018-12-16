//
//  MainTableViewCell.swift
//  Milli
//
//  Created by Charles Wang on 12/2/17.
//  Copyright © 2017 Milli. All rights reserved.
//

import Foundation
import UIKit

class MainTableViewCell: UITableViewCell {
    
    @IBOutlet weak var articleTitle: UILabel!
    @IBOutlet weak var articleSource: UILabel!
    @IBOutlet weak var articleInfo: UILabel!
    @IBOutlet weak var articleImage: UIImageView!
    @IBOutlet weak var articleText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
