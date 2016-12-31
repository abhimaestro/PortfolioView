//
//  DashboardAccountItemView.swift
//  PortfolioView
//
//  Created by Abhishek Sharma on 12/31/16.
//  Copyright © 2016 Abhishek Sharma. All rights reserved.
//

import UIKit
import PortfolioViewShared

class DashboardAccountItemView: UIView {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var marketValueLabel: UILabel!
    @IBOutlet weak var changeValueLabel: UILabel!
    @IBOutlet weak var swatchView: UIView!
    
    class func load(accountItem: Account, swatchColor: UIColor) -> DashboardAccountItemView {
        
        var xibView = Bundle.main.loadNibNamed("DashboardAccountItemView", owner: self, options: nil)
        let accountItemView = xibView?[0] as! DashboardAccountItemView
        
        accountItemView.setData(accountItem, swatchColor)
        accountItemView.layer.cornerRadius = 5
        
        return accountItemView
    }
    
    private func setData(_ accountItem: Account, _ swatchColor: UIColor) {
       
        nameLabel.text = accountItem.name
        marketValueLabel.text = accountItem.marketValue.toCurrency()
        
        swatchView.backgroundColor = swatchColor
        
        let color = Color.getValueColor(value: accountItem.changeDollar)
        changeValueLabel.attributedText = String("\(accountItem.changeDollar.toCurrency(noOfDecimals: 2)) (\(accountItem.changePercent.toPercent(noOfDecimals: 2)))").toAttributed(color: color)
    }
}
