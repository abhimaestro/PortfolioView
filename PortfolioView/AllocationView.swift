//
//  AllocationView.swift
//  PortfolioView
//
//  Created by Abhishek Sharma on 1/3/17.
//  Copyright © 2017 Abhishek Sharma. All rights reserved.
//

import UIKit
import PortfolioViewShared

class AllocationView: UIView, TKChartDelegate {

    @IBOutlet weak var allocationChartDonutContainer: UIView!
    @IBOutlet weak var allocationChartLegendContainer: UIView!
    @IBOutlet weak var allocationClassNameLabel: UILabel!
    @IBOutlet weak var allocationClassValueLabel: UILabel!
    @IBOutlet weak var allocationClassDollarValueLabel: UILabel!
    @IBOutlet weak var allocationAsOfDate: UILabel!
    
    let allocationChart = TKChart()
    
    class func load(allocationData: AllocationData, container: UIView) -> AllocationView {
        
        var xibView = Bundle.main.loadNibNamed("AllocationView", owner: self, options: nil)
        let allocationView = xibView?[0] as! AllocationView
       
        allocationView.frame = CGRect(0, 0, container.frame.width, container.frame.height)
        allocationView.initializeAllocationChart(allocationData)
        allocationView.initializeAllocationChartLegend(allocationData)
        
        container.addSubview(allocationView)
        container.sendSubview(toBack: allocationView)
        return allocationView
    }
    
    func initializeAllocationChart(_ allocationData: AllocationData) {
        
        allocationAsOfDate.text = String("as of: \(allocationData.asOfDate.toShortDateString())")
        
        let bounds = allocationChartDonutContainer.bounds
        
        allocationChart.frame = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height).insetBy(dx: 0, dy: 0)
        allocationChart.autoresizingMask = UIViewAutoresizing(rawValue:~UIViewAutoresizing().rawValue)
        
        allocationChart.legend.isHidden = true
        
        allocationChart.legend.style.insets = UIEdgeInsets.zero
        allocationChart.legend.style.offset = UIOffset.zero
        allocationChartDonutContainer.addSubview(allocationChart)
        
        let array:[TKChartDataPoint] = allocationData.allocations.map({TKChartDataPoint(x: $0.percent, y: $0.dollar, name: $0.name)})
        let allocationSeries = TKChartDonutSeries(items:array)
        
        allocationSeries.style.paletteMode = .useItemIndex
        allocationSeries.style.palette = TKChartPalette()
        
        for color in Color.palette {
            let paletteItem = TKChartPaletteItem(fill: TKSolidFill(color: color))
            allocationSeries.style.palette!.addItem(paletteItem)
        }
        
        allocationSeries.selection = TKChartSeriesSelection.dataPoint
        allocationSeries.innerRadius = 0.7
        allocationSeries.expandRadius = 1.1
        allocationSeries.rotationEnabled = false
        allocationSeries.labelDisplayMode = .outside
        
        allocationChart.addSeries(allocationSeries)
        setAllocationCenterLabel(point: array[0])
        
        allocationChart.delegate = self
        
        //remove trial label
        allocationChart.subviews[allocationChart.subviews.count - 1].removeFromSuperview()
    }
    
    func initializeAllocationChartLegend(_ allocationData: AllocationData) {
        
        let containerWidth = allocationChartLegendContainer.frame.width
        let offset: CGFloat = 5
        let height: CGFloat = 15
        var y = allocationChartLegendContainer.getYPositionToCenterContentInContainer(height: height, offset: offset, noOfItems: allocationData.allocations.count + 1, noOfCols: 1)
        let column1X = offset
        let width: CGFloat = containerWidth - 3*offset
        
        for i in 0..<allocationData.allocations.count {
            let allocation = allocationData.allocations[i]
            
            let legendItem = (name: allocation.name, value: allocation.percent.toPercent(), swatchColor: Color.palette[i])
            let allocationLegendItemView = LegendItemView.load(legendItem: legendItem)
            
            allocationLegendItemView.frame = CGRect(x: column1X, y: y, width: width, height: height)
            y += height + offset
            
            allocationChartLegendContainer.addSubview(allocationLegendItemView)
        }
    }
    
    func setAllocationCenterLabel(point: TKChartData) {
        self.bringSubview(toFront: allocationClassNameLabel)
        self.bringSubview(toFront: allocationClassValueLabel)
        allocationClassNameLabel.text = point.dataName
        allocationClassValueLabel.text = (point.dataXValue as! Double).toPercent(noOfDecimals: 1)
        allocationClassDollarValueLabel.text = (point.dataYValue as! Double).toCurrency()
    }
    
    func chart(_ chart: TKChart, didSelectPoint point: TKChartData, in series: TKChartSeries, at index: Int) {
        if chart == allocationChart {
            setAllocationCenterLabel(point: point)
        }
    }
   
}
