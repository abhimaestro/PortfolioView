//
//  Extensions.swift
//  PortfolioView
//
//  Created by Abhishek Sharma on 12/29/16.
//  Copyright © 2016 Abhishek Sharma. All rights reserved.
//

import Foundation
import UIKit
import WatchKit

public extension CGRect {
    public init(_ x:CGFloat, _ y:CGFloat, _ w:CGFloat, _ h:CGFloat) {
        self.init(x:x, y:y, width:w, height:h)
    }
}

public extension Double {
    public func toCurrency() -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.maximumFractionDigits = 0
        let currency = currencyFormatter.string(from: (self as NSNumber))!
        
        return currency
    }
    
    public func toPercent(noOfDecimals: Int = 0) -> String {
        let str = String(format: "%.\(noOfDecimals)f%%", self)
        return str
    }
}
