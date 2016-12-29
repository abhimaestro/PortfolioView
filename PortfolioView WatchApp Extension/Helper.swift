//
//  FontHelper.swift
//  PortfolioView
//
//  Created by Abhishek Sharma on 12/29/16.
//  Copyright © 2016 Abhishek Sharma. All rights reserved.
//

import Foundation
import WatchKit

class Helper {
    
    static let colorsCustom = [
        UIColor(red: 106/255.0, green: 213/255.0, blue: 207/255.0, alpha: 1.0),
        UIColor(red: 148/255.0, green: 120/255.0, blue: 162/255.0, alpha: 1.0),
        UIColor(red: 166/255.0, green: 208/255.0, blue: 100/255.0, alpha: 1.0),
        UIColor(red: 216/255.0, green: 82/255.0, blue: 85/255.0, alpha: 1.0),
        UIColor(red: 89/255.0, green: 156/255.0, blue: 155/255.0, alpha: 1.0)
    ]
    
    static func getAttributedString(_ str: String, font: UIFont? = nil, color: UIColor? = nil) -> NSAttributedString {
        
        var attributes = [String : Any]()
        
        if let font = font {
            attributes[NSFontAttributeName] = font
        }
        
        if let color = color {
            attributes[NSForegroundColorAttributeName] = color
        }
        
        let attrString = NSAttributedString(string: str, attributes: attributes)
        return attrString
    }
    
    static func getCurrencyColor(value: Double) -> UIColor {
        if value < 0 {
            return UIColor(red: 98/255.0, green: 32/255.0, blue: 32/255.0, alpha: 1.0)
        }
        else {
            return UIColor(red: 30/255.0, green: 116/255.0, blue: 0/255.0, alpha: 1.0)
        }
    }

}
