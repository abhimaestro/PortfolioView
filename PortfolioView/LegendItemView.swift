//
//  AllocationLegendItemView.swift
//  PortfolioView
//
//  Created by Abhishek Sharma on 12/31/16.
//  Copyright © 2016 Abhishek Sharma. All rights reserved.
//

import UIKit
import PortfolioViewShared

class LegendItemView: UIView {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var swatchView: UIView!

    class func load(legendItem: (name: String, value: String, swatchColor: UIColor)) -> LegendItemView {
        
        var xibView = Bundle.main.loadNibNamed("LegendItemView", owner: self, options: nil)
        let legendItemView = xibView?[0] as! LegendItemView
        
        legendItemView.setData(legendItem)
        
        return legendItemView
    }
    
    private func setData(_ legendItem: (name: String, value: String, swatchColor: UIColor)) {
        
        nameLabel.attributedText = legendItem.name.toAttributed(color: legendItem.swatchColor, upperCase: true)
        valueLabel.attributedText = legendItem.value.toAttributed(color: legendItem.swatchColor, upperCase: true)
        swatchView.backgroundColor = legendItem.swatchColor
    }
}
