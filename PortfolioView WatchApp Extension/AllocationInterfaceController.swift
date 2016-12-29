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

    
    @IBOutlet weak var chartImageView: WKInterfaceImage!
    @IBOutlet var allocationsTable: WKInterfaceTable!
    @IBOutlet var asOfDate: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        asOfDate.setText("as of date: \(Date.getYesterday().toShortDateString())")

        allocationsTable.setNumberOfRows(allocations.count, withRowType: "AllocationRow")
        
        for index in 0..<allocationsTable.numberOfRows {
            if let controller = allocationsTable.rowController(at: index) as? AllocationRowController {
                controller.setAllocation(color: Helper.colorsCustom[index], allocation: allocations[index])
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
        image.labelText = "   total\nportfolio"
        image.labelColor = UIColor.darkGray
        image.values = allocations.map({$0.percent as NSNumber})
        image.colors =  Helper.colorsCustom
        
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
        percentLabel.setText(allocation.percent.toPercent())
       separator.setColor(color)
        dollarLabel.setText(allocation.dollar.toCurrency())
    }
}
