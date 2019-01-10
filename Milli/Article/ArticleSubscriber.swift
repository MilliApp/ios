//
//  ArticleSubscriber.swift
//  Milli
//
//  Created by Charles Wang on 1/11/19.
//  Copyright © 2019 Milli. All rights reserved.
//

import Foundation

protocol ArticleSubscriber: class {
    var currentArticle: Article? { get set }
}
