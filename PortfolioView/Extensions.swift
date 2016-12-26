//
//  Extensions.swift
//  PortfolioView
//
//  Created by Abhishek Sharma on 12/25/16.
//  Copyright © 2016 Abhishek Sharma. All rights reserved.
//

import Foundation

extension Int {
    func randomIntFrom(start: Int, to end: Int) -> Int {
        var a = start
        var b = end
        // swap to prevent negative integer crashes
        if a > b {
            swap(&a, &b)
        }
        return Int(arc4random_uniform(UInt32(b - a + 1))) + a
    }
}

public extension UIImage {
    static func imageWithColor(color: UIColor, origin: CGPoint = CGPoint.zero, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        
        let rect = CGRect(origin: .init(x: 0, y: size.height - 1), size: size)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor);
        context!.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }
}

extension UISegmentedControl {
    func removeBorders() {
        setBackgroundImage(imageWithColor(color: .white), for: .normal, barMetrics: .default)
        setBackgroundImage(imageWithColor(color: .white), for: .selected, barMetrics: .default)
        setDividerImage(imageWithColor(color: UIColor.clear), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
    }
    
    // create a 1x1 image with this color
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor);
        context!.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }
}

extension CGRect {
    init(_ x:CGFloat, _ y:CGFloat, _ w:CGFloat, _ h:CGFloat) {
        self.init(x:x, y:y, width:w, height:h)
    }
}
