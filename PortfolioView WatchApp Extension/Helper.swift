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
    
}

enum WatchSize {
    case large
    case small
}

extension WKInterfaceDevice {

    func getWatchSize() -> WatchSize {

        let bounds = self.screenBounds
        // 38mm: (0.0, 0.0, 136.0, 170.0)
        // 42mm: (0.0, 0.0, 156.0, 195.0)
        
        return bounds.width > 136.0 ? WatchSize.large : WatchSize.small
    }
}
