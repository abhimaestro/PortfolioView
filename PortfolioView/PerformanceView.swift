//
//  PerformanceView.swift
//  PortfolioView
//
//  Created by Abhishek Sharma on 1/3/17.
//  Copyright © 2017 Abhishek Sharma. All rights reserved.
//

import UIKit
import PortfolioViewShared

class PerformanceView: UIView, TKChartDelegate {

    @IBOutlet weak var performanceChartLegendContainer: UIView!
    @IBOutlet weak var performanceChartContainer: UIView!
    @IBOutlet weak var portfolioTotalReturnLabel: UILabel!
    @IBOutlet weak var indexNameLabel: UILabel!
    @IBOutlet weak var indexTotalReturnLabel: UILabel!
    @IBOutlet weak var dateRangeLabel: UILabel!
    
    var performanceChart = TKChart()
    
    class func load(portfolioData: PortfolioData, indexType: IndexType, container: UIView) -> PerformanceView {
        
        var xibView = Bundle.main.loadNibNamed("PerformanceView", owner: self, options: nil)
        let performanceView = xibView?[0] as! PerformanceView
        
        performanceView.frame = CGRect(0, 0, container.frame.width, container.frame.height)
        performanceView.initializePerformanceChart(portfolioData: portfolioData, indexType: indexType)
        
        container.addSubview(performanceView)
        return performanceView
    }
    
    func initializePerformanceChart(portfolioData: PortfolioData, indexType: IndexType) {
        
        self.performanceChart = getPerformanceChart(inView: performanceChartContainer, portfolioData: portfolioData, indexType: indexType)
    }
    
    func getPerformanceData(portfolioData: PortfolioData, indexType: IndexType) -> (portfolioData: PortfolioData, portfolioReturns: [TKChartDataPoint], indexReturns: [TKChartDataPoint], indexName: String, minReturnValue: Double, maxReturnValue: Double) {
        
        var portfolioReturns = [TKChartDataPoint]()
        var indexReturns = [TKChartDataPoint]()
        var maxReturnValue: Double = 0.0, minReturnValue: Double = Double(Int.max)
        var indexName = ""
       
        for portfolioDataItem in (portfolioData.portfolioDataItems) {
            portfolioReturns.append(TKChartDataPoint(x: portfolioDataItem.returnDate, y: portfolioDataItem.portfolioReturnPercent))
            
            
            switch indexType {
            case .Index2:
                indexReturns.append(TKChartDataPoint(x: portfolioDataItem.returnDate, y: portfolioDataItem.index2ReturnPercent))
                indexName = portfolioData.index2Name
            case .Index3:
                indexReturns.append(TKChartDataPoint(x: portfolioDataItem.returnDate, y: portfolioDataItem.index3ReturnPercent))
                indexName = portfolioData.index3Name
            default:
                indexReturns.append(TKChartDataPoint(x: portfolioDataItem.returnDate, y: portfolioDataItem.index1ReturnPercent))
                indexName = portfolioData.index1Name
            }
            
            minReturnValue = min(minReturnValue, portfolioDataItem.portfolioReturnPercent, portfolioDataItem.index1ReturnPercent)
            maxReturnValue = max(maxReturnValue, portfolioDataItem.portfolioReturnPercent, portfolioDataItem.index1ReturnPercent)
        }
        
        return (portfolioData: portfolioData, portfolioReturns, indexReturns, indexName: indexName, minReturnValue, maxReturnValue)
    }
    
    func getPerformanceChart(inView: UIView, portfolioData: PortfolioData, indexType: IndexType) -> TKChart {
        
        let performanceChart = TKChart(frame: inView.bounds)
        
        performanceChart.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.flexibleWidth.rawValue | UIViewAutoresizing.flexibleHeight.rawValue)
        inView.addSubview(performanceChart)
        
        
        let performanceData = getPerformanceData(portfolioData: portfolioData, indexType: indexType)
        
        portfolioTotalReturnLabel.text = performanceData.portfolioData.totalPortfolioReturnPercent.toPercent(noOfDecimals: 1)
        portfolioTotalReturnLabel.textColor = Color.getValueColor(value: performanceData.portfolioData.totalPortfolioReturnPercent)
        
        indexTotalReturnLabel.text = performanceData.portfolioData.totalIndex1ReturnPercent.toPercent(noOfDecimals: 1)
        indexTotalReturnLabel.textColor = Color.getValueColor(value: performanceData.portfolioData.totalIndex1ReturnPercent)
        
        updateDateRangeLevel(portfolioData: performanceData.portfolioData)
        
        let series = TKChartAreaSeries(items:performanceData.portfolioReturns)
        series.title = "Your Portfolio"
        
        let series2 = TKChartLineSeries(items:performanceData.indexReturns)
        series2.title = performanceData.indexName
        
        series.style.palette = TKChartPalette()
        let paletteItem1 = TKChartPaletteItem()
        paletteItem1.stroke = TKStroke(color: UIColor(red: 0/255.0, green: 83/255.0, blue: 146/255.0, alpha: 1.00))
        series.style.palette!.addItem(paletteItem1)
        
        series2.style.palette = TKChartPalette()
        let paletteItem2 = TKChartPaletteItem()
        paletteItem2.stroke = TKStroke(color: UIColor(red: 154/255.0, green: 181/255.0, blue: 170/255.0, alpha: 1.00))
        series2.style.palette!.addItem(paletteItem2)
        
        let xAxis = TKChartDateTimeAxis(minimumDate: performanceData.portfolioData.inceptionDate, andMaximumDate: performanceData.portfolioData.endDate)
        //xAxis.majorTickIntervalUnit = TKChartDateTimeAxisIntervalUnit.custom
        xAxis.majorTickInterval = 2
        xAxis.style.labelStyle.font = FontHelper.getDefaultFont(size: 9.0, light: true)
        xAxis.setPlotMode(TKChartAxisPlotMode.onTicks)
        xAxis.style.majorTickStyle.ticksHidden = true
        xAxis.style.lineHidden = true
        xAxis.style.labelStyle.textAlignment = TKChartAxisLabelAlignment(rawValue: TKChartAxisLabelAlignment.top.rawValue)
        xAxis.style.labelStyle.textOffset = UIOffset(horizontal: 0, vertical: -2)
        xAxis.style.labelStyle.firstLabelTextAlignment = .left
        
        performanceChart.xAxis = xAxis
        
        let yAxis = TKChartNumericAxis(minimum: performanceData.minReturnValue, andMaximum: performanceData.maxReturnValue)
        yAxis.style.labelStyle.font = FontHelper.getDefaultFont(size: 8.0, light: true)
        yAxis.style.labelStyle.textAlignment = TKChartAxisLabelAlignment(rawValue: TKChartAxisLabelAlignment.right.rawValue | TKChartAxisLabelAlignment.bottom.rawValue)
        yAxis.style.labelStyle.firstLabelTextAlignment = TKChartAxisLabelAlignment(rawValue: TKChartAxisLabelAlignment.right.rawValue | TKChartAxisLabelAlignment.top.rawValue)
        
        yAxis.style.majorTickStyle.ticksHidden = true
        yAxis.style.lineHidden = true
        yAxis.labelFormat = "%.0f%%"
        yAxis.style.lineStroke = TKStroke(color:UIColor(white:0.85, alpha:1.0), width:2)
        
        performanceChart.yAxis = yAxis
        
        performanceChart.addSeries(series)
        performanceChart.addSeries(series2)
        
        performanceChart.allowTrackball = true
        performanceChart.trackball.snapMode = TKChartTrackballSnapMode.allClosestPoints
        performanceChart.delegate = self
        performanceChart.trackball.tooltip.style.textAlignment = NSTextAlignment.left
        performanceChart.trackball.tooltip.style.font = FontHelper.getDefaultFont(size: 11.0, light: true)
        
        performanceChart.insets = UIEdgeInsets.zero
        performanceChart.gridStyle.horizontalFill = nil
        
        //remove trial label
        performanceChart.subviews[4].removeFromSuperview()
        
        return performanceChart
    }

    func updateDateRangeLevel(portfolioData: PortfolioData) {
        dateRangeLabel.text = "Date range: \(portfolioData.inceptionDate.toShortDateString()) - \(portfolioData.endDate.toShortDateString())"
    }
    
    func chart(_ chart: TKChart, trackballDidTrackSelection selection: [Any]) {
        let str = NSMutableString()
        var i = 0
        let count = selection.count
        
        let allData = selection as! [TKChartSelectionInfo]
        
        str.append("\((allData[0].dataPoint!.dataXValue as! Date).toShortDateString())\n")
        
        if chart == performanceChart {
            for info in allData {
                let data = info.dataPoint as TKChartData!
                
                str.append("\(info.series!.title!): \((data!.dataYValue as! Double).toPercent(noOfDecimals: 1))")
                // str.append("\(data?.dataYValue as! Float)")
                if (i<count-1) {
                    str.append("\n");
                }
                i += 1
            }
        }
        
        chart.trackball.tooltip.text = str as String
    }
}
