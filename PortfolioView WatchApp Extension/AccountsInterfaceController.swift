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

class AccountsInterfaceController: WKInterfaceController {

    @IBOutlet var accountsTable: WKInterfaceTable!
    @IBOutlet var asOfDate: WKInterfaceLabel!
    
    let accounts = PortfolioData.getAccounts()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        asOfDate.setText("as of date: \(Date().toDateTimeString())")

        accountsTable.setNumberOfRows(accounts.count, withRowType: "AccountRow")
        
        for index in 0..<accountsTable.numberOfRows {
            if let controller = accountsTable.rowController(at: index) as? AccountRowController {
                controller.setAaccount(color: Helper.colorsCustom[index], account: accounts[index])
            }
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
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
        
        let changeText = Helper.getAttributedString(String("\(account.changeDollar.toCurrency()) (\(account.changePercent.toPercent())))"), color: Helper.getCurrencyColor(value: account.changeDollar))
        changeLabel.setAttributedText(changeText)
    }
}
