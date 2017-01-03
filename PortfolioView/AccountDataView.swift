//
//  accountDataView.swift
//  PortfolioView
//
//  Created by Abhishek Sharma on 1/3/17.
//  Copyright © 2017 Abhishek Sharma. All rights reserved.
//

import UIKit
import PortfolioViewShared

class AccountDataView: UIView {
    
    @IBOutlet weak var asOfDate: UILabel!
    
    class func load(accountData: AccountData, container: UIView) -> AccountDataView {
        
        var xibView = Bundle.main.loadNibNamed("AccountDataView", owner: self, options: nil)
        let accountDataView = xibView?[0] as! AccountDataView
        
        accountDataView.setData(accountData, container)
        
        container.addSubview(accountDataView)
        container.sendSubview(toBack: accountDataView)
        return accountDataView
    }
    
    func setData(_ accountData: AccountData, _ container: UIView) {
        
        self.frame = CGRect(0, 0, container.frame.width, container.frame.height)
        
        asOfDate.text = String("as of: \(accountData.asOfDate.toDateTimeString())")
        
        let containerOrigin = self.frame.origin
        let containerWidth = self.frame.width

        let offset: CGFloat = 10
        let height: CGFloat = 62
        var y = self.getYPositionToCenterContentInContainer(height: height, offset: offset, noOfItems: accountData.accounts.count + 1, noOfCols: 2)
        let width: CGFloat = (containerWidth / 2) - 1.5*offset
        
        let column1X = containerOrigin.x + offset
        let column2X = column1X + width + offset
        
        for i in 0..<accountData.accounts.count {
            let account = accountData.accounts[i]
            
            let accountItemView = DashboardAccountItemView.load(accountItem:  account, swatchColor: Color.palette[i])
            
            if i % 2 == 0 {
                accountItemView.frame = CGRect(x: column1X, y: y, width: width, height: height)
            }
            else {
                accountItemView.frame = CGRect(x: column2X, y: y, width: width, height: height)
                y += height + offset
            }
            
            self.addSubview(accountItemView)
        }
    }
}
