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

    let chartLabelFont = UIFont.systemFont(ofSize: 10.0, weight: UIFontWeightLight)
    let allocationData = PortfolioData.getAllocations()

    @IBOutlet weak var chartImageView: WKInterfaceImage!
    @IBOutlet var allocationsTable: WKInterfaceTable!
    @IBOutlet var asOfDate: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        asOfDate.setText("as of: \(Date.getYesterday().toShortDateString())")

        updateTable()
        updateChart()
    }
    
    override func willActivate() {
        super.willActivate()
    }

    func updateTable() {
        allocationsTable.setNumberOfRows(allocationData.allocations.count, withRowType: "AllocationRow")
        
        for index in 0..<allocationsTable.numberOfRows {
            if let controller = allocationsTable.rowController(at: index) as? AllocationRowController {
                controller.setAllocation(color: Color.palette[index], allocation: allocationData.allocations[index])
            }
        }
    }
    
    func updateChart() {
        
        let frame = CGRect(0, 0, contentFrame.width, contentFrame.height / 2)
        let scale = WKInterfaceDevice.current().screenScale
        
        let image = YODonutChartImage()
        image.donutWidth = 12.0
        image.labelFont = chartLabelFont
        image.labelText = " portfolio\nallocation"
        image.labelColor = UIColor.darkGray
        image.values = allocationData.allocations.map({$0.percent as NSNumber})
        image.colors = Color.palette
        
        let chartImage = image.draw(frame, scale: scale)
        
        self.chartImageView.setImage(chartImage)
    }
}

class AllocationRowController: NSObject {
    
    @IBOutlet var separator: WKInterfaceSeparator!
    @IBOutlet var nameLabel: WKInterfaceLabel!
    @IBOutlet var percentLabel: WKInterfaceLabel!
    @IBOutlet var dollarLabel: WKInterfaceLabel!
    
    func setAllocation(color: UIColor, allocation: Allocation) {
        
        nameLabel.setText(allocation.name)
        percentLabel.setText(allocation.percent.toPercent())
       separator.setColor(color)
        dollarLabel.setText(allocation.dollar.toCurrency())
    }
}
