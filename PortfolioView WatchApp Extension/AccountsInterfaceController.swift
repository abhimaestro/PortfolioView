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
        
        asOfDate.setText("as of: \(Date().toDateTimeString())")
        
        updateTable()
    }

    override func willActivate() {
        super.willActivate()
    }

    override func didDeactivate() {
        super.didDeactivate()
    }

    func updateTable() {
        accountsTable.setNumberOfRows(accounts.count, withRowType: "AccountRow")
        
        for index in 0..<accountsTable.numberOfRows {
            if let controller = accountsTable.rowController(at: index) as? AccountRowController {
                let account = accounts[index]
                controller.setAaccount(color: Color.getValueColor(value: account.changeDollar), account: account)
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
        
        let changeText = String("\(account.changeDollar.toCurrency()) (\(account.changePercent.toPercent())))")?.toAttributed(color: Color.getValueColor(value: account.changeDollar))
            
        changeLabel.setAttributedText(changeText)
    }
}
