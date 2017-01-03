//
//  MarketDataView.swift
//  PortfolioView
//
//  Created by Abhishek Sharma on 1/3/17.
//  Copyright © 2017 Abhishek Sharma. All rights reserved.
//

import UIKit
import PortfolioViewShared

class MarketDataView: UIView {

    @IBOutlet weak var asOfDate: UILabel!
    
    class func load(marketData: MarketData, container: UIView) -> MarketDataView {
        
        var xibView = Bundle.main.loadNibNamed("MarketDataView", owner: self, options: nil)
        let marketDataView = xibView?[0] as! MarketDataView
        
        marketDataView.setData(marketData, container)
        
        container.addSubview(marketDataView)
        container.sendSubview(toBack: marketDataView)
        return marketDataView
    }
    
    func setData(_ marketData: MarketData, _ container: UIView) {
        
        self.frame = CGRect(0, 0, container.frame.width, container.frame.height)
        
        asOfDate.text = String("as of: \(marketData.asOfDate.toDateTimeString())")

        let containerOrigin = container.frame.origin
        let containerWidth = container.frame.width
        let offset: CGFloat = 10
        let height: CGFloat = 62
        var y = self.getYPositionToCenterContentInContainer(height: height, offset: offset, noOfItems: marketData.marketItems.count + 1, noOfCols: 2)
        
        let width = CGFloat(containerWidth/2 - 1.5*offset)
        
        let column1X = containerOrigin.x + offset
        let column2X = column1X + width + offset
        
        for i in 0..<marketData.marketItems.count {
            let marketItem = marketData.marketItems[i]
            
            let marketItemView = MarketItemView.load(marketItem: marketItem)
            
            if i % 2 == 0 {
                marketItemView.frame = CGRect(x: column1X, y: y, width: width, height: height)
            }
            else {
                marketItemView.frame = CGRect(x: column2X, y: y, width: width, height: height)
                y += height + offset
            }
            
            self.addSubview(marketItemView)
        }
    }
}
