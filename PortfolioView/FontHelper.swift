//
//  FontHelper.swift
//  PortfolioView
//
//  Created by Abhishek Sharma on 12/27/16.
//  Copyright © 2016 Abhishek Sharma. All rights reserved.
//

import Foundation

class FontHelper {

    static func getDefaultFont(size: CGFloat, bold: Bool = false, light: Bool = false) -> UIFont {
        var fontName = "Helvetica Neue"
        if bold {
            fontName = "HelveticaNeue-Bold"
        }
        else if light {
            fontName = "HelveticaNeue-Light"
        }
        
        return UIFont(name:fontName, size:size)!
    }
}
