//
//  ValueOverTimeView.swift
//  PortfolioView
//
//  Created by Abhishek Sharma on 1/3/17.
//  Copyright © 2017 Abhishek Sharma. All rights reserved.
//

import UIKit
import PortfolioViewShared

class ValueOverTimeView: UIView, TKChartDelegate {

    @IBOutlet weak var valueOverTimeChartLegendContainer: UIView!
    @IBOutlet weak var valueOverTimeChartContainer: UIView!
    @IBOutlet weak var portfolioTotalReturnDollarValue: UILabel!
    @IBOutlet weak var dateRangeLabel: UILabel!

    var valueOverTimeChart = TKChart()
    let selectedBlueColor = UIColor(red: 42/255.0, green: 78/255.0, blue: 133/255.0, alpha: 1.0)
    
    class func load(portfolioData: PortfolioData, container: UIView) -> ValueOverTimeView {
        
        var xibView = Bundle.main.loadNibNamed("ValueOverTimeView", owner: self, options: nil)
        let valueOverTimeView = xibView?[0] as! ValueOverTimeView
        
        valueOverTimeView.frame = CGRect(0, 0, container.frame.width, container.frame.height)
        valueOverTimeView.initializeValueOverTimeChart(portfolioData: portfolioData)
        
        container.addSubview(valueOverTimeView)
        return valueOverTimeView
    }
    
    
    func initializeValueOverTimeChart(portfolioData: PortfolioData) {
        
        self.valueOverTimeChart =  getValueOverTimeChart(inView: valueOverTimeChartContainer, portfolioData: portfolioData)
    }

    func getValueOverTimeChart(inView: UIView, portfolioData: PortfolioData) -> TKChart {
        let valueOverTimeChart = TKChart(frame: inView.bounds)
        valueOverTimeChart.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.flexibleWidth.rawValue | UIViewAutoresizing.flexibleHeight.rawValue)
        inView.addSubview(valueOverTimeChart)
        
        valueOverTimeChart.gridStyle.horizontalFill = nil
        
        let valueData = getValueData(portfolioData: portfolioData)
        
        portfolioTotalReturnDollarValue.text = valueData.portfolioData.totalPortfolioReturnDollar.toCurrency()
        
        portfolioTotalReturnDollarValue.textColor = Color.getValueColor(value: valueData.portfolioData.totalPortfolioReturnDollar)
        
        //portfolioTotalMarketValueLabel.text = valueData.portfolioData.totalPortfolioMarketValueDollar.toCurrency()
        
        updateDateRangeLevel(portfolioData: valueData.portfolioData)
        
        let series = TKChartAreaSeries(items:valueData.portfolioValues)
        series.title = "Market Value"
        series.selection = TKChartSeriesSelection.series
        
        series.style.palette = TKChartPalette()
        
        let fillBlueColor = UIColor(red: 216/255.0, green: 231/255.0, blue: 255/255.0, alpha: 0.5)
        let paletteItem = TKChartPaletteItem()
        paletteItem.stroke = TKStroke(color: selectedBlueColor)
        paletteItem.fill = TKLinearGradientFill(colors: [selectedBlueColor, fillBlueColor, UIColor.white])
        series.style.palette!.addItem(paletteItem)
        
        
        // >> chart-axis-datetime-swift
        let xAxis = TKChartDateTimeAxis(minimumDate: valueData.portfolioData.inceptionDate, andMaximumDate: valueData.portfolioData.endDate)
        //xAxis.majorTickIntervalUnit = TKChartDateTimeAxisIntervalUnit.custom
        xAxis.majorTickInterval = 2
        xAxis.style.labelStyle.font = FontHelper.getDefaultFont(size: 9.0, light: true)
        xAxis.setPlotMode(TKChartAxisPlotMode.onTicks)
        xAxis.style.majorTickStyle.ticksHidden = true
        xAxis.style.lineHidden = true
        xAxis.style.labelStyle.textAlignment = TKChartAxisLabelAlignment(rawValue: TKChartAxisLabelAlignment.top.rawValue)
        xAxis.style.labelStyle.textOffset = UIOffset(horizontal: 0, vertical: -2)
        xAxis.style.labelStyle.firstLabelTextAlignment = .left //hide to left
        
        valueOverTimeChart.xAxis = xAxis
        
        let yAxis = TKChartNumericAxis(minimum: valueData.minValue, andMaximum: valueData.maxValue)
        yAxis.style.labelStyle.font = FontHelper.getDefaultFont(size: 8.0, light: true)
        yAxis.style.labelStyle.textAlignment = TKChartAxisLabelAlignment(rawValue: TKChartAxisLabelAlignment.right.rawValue | TKChartAxisLabelAlignment.bottom.rawValue)
        yAxis.style.labelStyle.firstLabelTextAlignment = TKChartAxisLabelAlignment(rawValue: TKChartAxisLabelAlignment.right.rawValue | TKChartAxisLabelAlignment.top.rawValue)
        
        yAxis.style.majorTickStyle.ticksHidden = true
        yAxis.style.lineHidden = true
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.maximumFractionDigits = 0
        yAxis.labelFormatter = currencyFormatter
        yAxis.style.lineStroke = TKStroke(color:UIColor(white:0.85, alpha:1.0), width:2)
        
        valueOverTimeChart.yAxis = yAxis
        
        
        valueOverTimeChart.addSeries(series)
        
        valueOverTimeChart.insets = UIEdgeInsets.zero
        
        valueOverTimeChart.allowTrackball = true
        valueOverTimeChart.trackball.snapMode = TKChartTrackballSnapMode.allClosestPoints
        valueOverTimeChart.delegate = self
        valueOverTimeChart.trackball.tooltip.style.textAlignment = NSTextAlignment.left
        valueOverTimeChart.trackball.tooltip.style.font = FontHelper.getDefaultFont(size: 11.0, light: true)
        //valueOverTimeChart.allowAnimations = true
        //remove trial label
        valueOverTimeChart.subviews[4].removeFromSuperview()
        
        return valueOverTimeChart
    }
    
    func getValueData(portfolioData: PortfolioData) -> (portfolioData: PortfolioData, portfolioValues: [TKChartDataPoint], minValue: Double, maxValue: Double) {
        
        var portfolioValues = [TKChartDataPoint]()
        var maxValue: Double = 0.0, minValue: Double = Double(Int.max)
        
        for portfolioDataItem in (portfolioData.portfolioDataItems) {
            portfolioValues.append(TKChartDataPoint(x: portfolioDataItem.returnDate, y: portfolioDataItem.marketValue))
            
            minValue = min(minValue, portfolioDataItem.marketValue)
            maxValue = max(maxValue, portfolioDataItem.marketValue)
        }
        
        return (portfolioData: portfolioData, portfolioValues, minValue, maxValue)
    }
    
    func updateDateRangeLevel(portfolioData: PortfolioData) {
        dateRangeLabel.text = "Date range: \(portfolioData.inceptionDate.toShortDateString()) - \(portfolioData.endDate.toShortDateString())"
    }
    
    func chart(_ chart: TKChart, trackballDidTrackSelection selection: [Any]) {
        let str = NSMutableString()
        
        let allData = selection as! [TKChartSelectionInfo]
        
        str.append("\((allData[0].dataPoint!.dataXValue as! Date).toShortDateString())\n")
        

        let data = allData[0].dataPoint as TKChartData!
        str.append("\(allData[0].series!.title!): \((data!.dataYValue as! Double).toCurrency()) \n")

        
        chart.trackball.tooltip.text = str as String
    }
}
