//
//  AccountsInterfaceController.swift
//  PortfolioView
//
//  Created by Abhishek Sharma on 12/29/16.
//  Copyright © 2016 Abhishek Sharma. All rights reserved.
//

import WatchKit
import Foundation
import PortfolioViewShared
import YOChartImageKit

class AccountsInterfaceController: WKInterfaceController {

    @IBOutlet var accountsTable: WKInterfaceTable!
    @IBOutlet var asOfDate: WKInterfaceLabel!
    @IBOutlet weak var chartImageView: WKInterfaceImage!

    let chartLabelFont = UIFont.systemFont(ofSize: 10.0, weight: UIFontWeightLight)
    let accountData = PortfolioData.getAccounts()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        asOfDate.setText("as of: \(Date().toDateTimeString())")
        
        updateTable()
        updateChart()
    }

    override func willActivate() {
        super.willActivate()
    }

    override func didDeactivate() {
        super.didDeactivate()
    }

    func updateChart() {
        
        let frame = CGRect(0, 0, contentFrame.width, contentFrame.height / 2)
        let scale = WKInterfaceDevice.current().screenScale
        
        let image = YODonutChartImage()
        image.donutWidth = 12.0
        image.labelFont = chartLabelFont
        image.labelText = "portfolio\naccounts"
        image.labelColor = UIColor.darkGray
        image.values = accountData.accounts.map({$0.marketValue as NSNumber})
        image.colors = Color.palette
        
        let chartImage = image.draw(frame, scale: scale)
        
        self.chartImageView.setImage(chartImage)
    }
    
    func updateTable() {
        accountsTable.setNumberOfRows(accountData.accounts.count, withRowType: "AccountRow")
        
        for index in 0..<accountsTable.numberOfRows {
            if let controller = accountsTable.rowController(at: index) as? AccountRowController {
                let account = accountData.accounts[index]
                controller.setAaccount(color: Color.palette[index], account: account)
            }
        }
    }
}

class AccountRowController: NSObject {
    
    @IBOutlet var separator: WKInterfaceSeparator!
    @IBOutlet var nameLabel: WKInterfaceLabel!
    @IBOutlet var marketValueLabel: WKInterfaceLabel!
    @IBOutlet var changeLabel: WKInterfaceLabel!
    
    func setAaccount(color: UIColor, account: Account) {
        
        nameLabel.setText(account.name)
        marketValueLabel.setText(account.marketValue.toCurrency())
        separator.setColor(color)
        
        let changeText = String("\(account.changeDollar.toCurrency()) (\(account.changePercent.toPercent()))")?.toAttributed(color: Color.getValueColor(value: account.changeDollar))
            
        changeLabel.setAttributedText(changeText)
    }
}
