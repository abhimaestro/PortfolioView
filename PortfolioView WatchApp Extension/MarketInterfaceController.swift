//
//  MarketInterfaceController.swift
//  PortfolioView
//
//  Created by Abhishek Sharma on 12/30/16.
//  Copyright © 2016 Abhishek Sharma. All rights reserved.
//

import WatchKit
import Foundation
import PortfolioViewShared

class MarketInterfaceController: WKInterfaceController {

    @IBOutlet var marketDataTable: WKInterfaceTable!
    @IBOutlet var asOfDate: WKInterfaceLabel!
    
    let marketData = PortfolioData.getMarketData()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        asOfDate.setText("as of: \(Date().toDateTimeString())")
        
        updateTable()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    func updateTable() {
        marketDataTable.setNumberOfRows(marketData.count, withRowType: "MarketRow")
        
        for index in 0..<marketDataTable.numberOfRows {
            if let controller = marketDataTable.rowController(at: index) as? MarketRowController {
                let marketItem = marketData[index]
                controller.setItem(marketItem: marketItem)
            }
        }
    }
}

class MarketRowController: NSObject {
    
    @IBOutlet var rowGroup: WKInterfaceGroup!
    @IBOutlet var symbolLabel: WKInterfaceLabel!
    @IBOutlet var nameLabel: WKInterfaceLabel!
    @IBOutlet var marketValueLabel: WKInterfaceLabel!
    @IBOutlet var changeDollarLabel: WKInterfaceLabel!
    @IBOutlet var changePercentLabel: WKInterfaceLabel!
    
    func setItem(marketItem: MarketItem) {
        
        let color = Color.getValueColor(value: marketItem.changeDollar)
        
        symbolLabel.setText(marketItem.symbol)
        nameLabel.setText(marketItem.name)
        marketValueLabel.setText(marketItem.marketValue.toCurrency())
        
        rowGroup.setBackgroundColor(color.withAlphaComponent(0.4))
        
       
        changeDollarLabel.setAttributedText(marketItem.changeDollar.toCurrency(noOfDecimals: 2).toAttributed(color: color))
        changePercentLabel.setAttributedText(marketItem.changePercent.toPercent(noOfDecimals: 2).toAttributed(color: color))
    }
}
