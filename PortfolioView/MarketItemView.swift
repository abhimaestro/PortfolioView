//
//  MarketItemView.swift
//  PortfolioView
//
//  Created by Abhishek Sharma on 12/30/16.
//  Copyright © 2016 Abhishek Sharma. All rights reserved.
//

import UIKit
import PortfolioViewShared

class MarketItemView: UIView {

    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var marketValueLabel: UILabel!
    @IBOutlet weak var changeValueDollarLabel: UILabel!
    @IBOutlet weak var changeValuePercentLabel: UILabel!

    class func load(marketItem: MarketItem) -> MarketItemView {
        
        var xibView = Bundle.main.loadNibNamed("MarketItemView", owner: self, options: nil)
        let marketItemView = xibView?[0] as! MarketItemView
        
        marketItemView.setData(marketItem)
        return marketItemView
    }
    
    private func setData(_ marketItem: MarketItem) {
        let color = Color.getValueColor(value: marketItem.changeDollar)
        
        symbolLabel.text = marketItem.symbol
        nameLabel.text = marketItem.name
        marketValueLabel.text = marketItem.marketValue.toCurrency()
        
        self.backgroundColor = color.withAlphaComponent(0.4)
        
        changeValueDollarLabel.attributedText = marketItem.changeDollar.toCurrency(noOfDecimals: 2).toAttributed(color: color)
        changeValuePercentLabel.attributedText = marketItem.changePercent.toPercent(noOfDecimals: 2).toAttributed(color: color)
    }

}
