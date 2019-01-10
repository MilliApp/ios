//
//  UIVew+Snapshot.swift
//  Milli
//
//  Created by Charles Wang on 1/10/19.
//  Copyright © 2019 Milli. All rights reserved.
//

import UIKit

extension UIView  {
    
    func makeSnapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
