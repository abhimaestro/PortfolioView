//
//  AllocationInterfaceController.swift
//  PortfolioView
//
//  Created by Abhishek Sharma on 12/29/16.
//  Copyright © 2016 Abhishek Sharma. All rights reserved.
//

import WatchKit
import Foundation
import YOChartImageKit
import PortfolioViewShared

class AllocationInterfaceController: WKInterfaceController {

    let chartLabelFont = UIFont.systemFont(ofSize: 7.0, weight: UIFontWeightLight)
    let allocations = PortfolioData.getAllocations()
    let colorsCustom = [
        UIColor(red: 106/255.0, green: 213/255.0, blue: 207/255.0, alpha: 1.0),
        UIColor(red: 148/255.0, green: 120/255.0, blue: 162/255.0, alpha: 1.0),
        UIColor(red: 166/255.0, green: 208/255.0, blue: 100/255.0, alpha: 1.0),
        UIColor(red: 216/255.0, green: 82/255.0, blue: 85/255.0, alpha: 1.0),
        UIColor(red: 89/255.0, green: 156/255.0, blue: 155/255.0, alpha: 1.0)
    ]
    
    @IBOutlet weak var chartImageView: WKInterfaceImage!
    @IBOutlet var allocationsTable: WKInterfaceTable!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        allocationsTable.setNumberOfRows(allocations.count, withRowType: "AllocationRow")
        
        for index in 0..<allocationsTable.numberOfRows {
            if let controller = allocationsTable.rowController(at: index) as? AllocationRowController {
                controller.setAllocation(color: colorsCustom[index], allocation: allocations[index])
            }
        }
    }
    
    override func willActivate() {
        super.willActivate()
        updateChart()
    }

    func updateChart() {
        
        let frame = CGRect(0, 0, contentFrame.width, contentFrame.height / 2)
        let scale = WKInterfaceDevice.current().screenScale
        
        let image = YODonutChartImage()
        image.donutWidth = 12.0
        image.labelFont = chartLabelFont
        image.labelText = "Allocation"
        image.labelColor = UIColor.darkGray
        image.values = allocations.map({$0.percent as NSNumber})
        image.colors = colorsCustom
        
        let chartImage = image.draw(frame, scale: scale)
        
        self.chartImageView.setImage(chartImage)
    }
}

class AllocationRowController: NSObject {
    
    @IBOutlet var separator: WKInterfaceSeparator!
    @IBOutlet var nameLabel: WKInterfaceLabel!
    @IBOutlet var percentLabel: WKInterfaceLabel!
    @IBOutlet var dollarLabel: WKInterfaceLabel!
    
    func setAllocation(color: UIColor, allocation: (name: String, percent: Double, dollar: Double)) {
        
        nameLabel.setText(allocation.name)
        
        let percentStr = String(format: "%.1f%%", allocation.percent)
        percentLabel.setText(percentStr)
        
        separator.setWidth(15.0)
        separator.setColor(color)
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.maximumFractionDigits = 0
        let dollarStr = currencyFormatter.string(from: (allocation.dollar as NSNumber))!
        dollarLabel.setText(dollarStr)
    }

}
