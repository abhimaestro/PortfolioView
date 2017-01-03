//
//  Color.swift
//  PortfolioView
//
//  Created by Abhishek Sharma on 12/30/16.
//  Copyright © 2016 Abhishek Sharma. All rights reserved.
//

import Foundation
import UIKit
import WatchKit

public class Color {
    
    public static let redValue = UIColor(red: 255/255.0, green: 55/255.0, blue: 82/255.0, alpha: 1.0)
    public static let greenValue = UIColor(red: 30/255.0, green: 116/255.0, blue: 0/255.0, alpha: 1.0)
    public static let darkBlue = UIColor(red: 42/255.0, green: 78/255.0, blue: 133/255.0, alpha: 1.0)
    
    public static let palette = [
        UIColor(red: 106/255.0, green: 213/255.0, blue: 207/255.0, alpha: 1.0),
        UIColor(red: 148/255.0, green: 120/255.0, blue: 162/255.0, alpha: 1.0),
        UIColor(red: 166/255.0, green: 208/255.0, blue: 100/255.0, alpha: 1.0),
        UIColor(red: 216/255.0, green: 82/255.0, blue: 85/255.0, alpha: 1.0),
        UIColor(red: 89/255.0, green: 156/255.0, blue: 155/255.0, alpha: 1.0),
        UIColor(red: 208/255.0, green: 138/255.0, blue: 60/255.0, alpha: 1.0),
        UIColor(red: 99/255.0, green: 138/255.0, blue: 199/255.0, alpha: 1.0),
        UIColor(red: 192/255.0, green: 100/255.0, blue: 88/255.0, alpha: 1.0)
    ]
    
    public static func getValueColor(value: Double) -> UIColor {
        return value < 0 ? redValue : greenValue
    }
}
