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
