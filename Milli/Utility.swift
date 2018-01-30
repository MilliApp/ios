//
//  Utility.swift
//  Milli
//
//  Created by Charles Wang on 12/10/17.
//  Copyright © 2017 Milli. All rights reserved.
//

import Foundation
import UIKit

struct Globals {
    static var mainTableView: UITableView = UITableView()
    static var articles: [Article] = [Article]()
}

func print_debug(_ tagID: String, message: String) {
    print(tagID + ": " + message)
}
