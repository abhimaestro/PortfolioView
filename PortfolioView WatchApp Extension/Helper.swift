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
    static func getAttributedString(_ str: String, font: UIFont, color: UIColor? = nil) -> NSAttributedString {
        
        var attributes: [String : Any] = [NSFontAttributeName: font]
        
        if let color = color {
            attributes[NSForegroundColorAttributeName] = color
        }
        
        let attrString = NSAttributedString(string: str, attributes: attributes)
        return attrString
    }
}
