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
    public func toCurrency(noOfDecimals: Int = 0) -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.maximumFractionDigits = noOfDecimals
        let currency = currencyFormatter.string(from: (self as NSNumber))!
        
        return currency
    }
    
    public func toPercent(noOfDecimals: Int = 0) -> String {
        let str = String(format: "%.\(noOfDecimals)f%%", self)
        return str
    }
}

public extension Date {
    
    static public var currentYear: Int {
       return Calendar.current.dateComponents([.year], from: Date()).year!
    }
    public func toShortDateString() -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = .short
        return dateformatter.string(from: self)
    }

    public func toDateTimeString(format: String = "MM/dd/yyyy HH:mm a") -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = format
        return dateformatter.string(from: self)
    }
    
    static public func getYesterday() -> Date {
        return Date().addingTimeInterval(-(24*60*60))
    }
}

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

extension String {
    
    public func toAttributed(font: UIFont? = nil, color: UIColor? = nil, upperCase: Bool = false) -> NSAttributedString {
        
        var value = self
        
        var attributes = [String : Any]()
        
        if let font = font {
            attributes[NSFontAttributeName] = font
        }
        
        if let color = color {
            attributes[NSForegroundColorAttributeName] = color
        }
        if upperCase {
            value = self.uppercased()
        }
        
        let attrString = NSAttributedString(string: value, attributes: attributes)
        return attrString
    }
}
