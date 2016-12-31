//
//  DashboardViewController.swift
//  PortfolioView
//
//  Created by Abhishek Sharma on 12/15/16.
//  Copyright © 2016 Abhishek Sharma. All rights reserved.
//

import UIKit
import Foundation
import PortfolioViewShared

class DashboardViewController: UIViewController, TKChartDelegate, UIPopoverPresentationControllerDelegate {

    
    @IBOutlet weak var performanceChartContainer: UIView!
    @IBOutlet weak var valueOverTimeChartContainer: UIView!
    @IBOutlet weak var portraitLayoutContainer: UIView!
    @IBOutlet weak var landscapeLayoutContainer: UIView!
    @IBOutlet weak var topContainer: UIView!
    @IBOutlet weak var bottomContainer: UIView!
    @IBOutlet weak var marketDataContainer: UIView!
    @IBOutlet weak var accountContainer: UIView!
    @IBOutlet weak var allocationChartContainer: UIView!
    @IBOutlet weak var allocationChartDonutContainer: UIView!
    @IBOutlet weak var goalChartContainer: UIView!
    @IBOutlet weak var bottomContainerPageControl: UIPageControl!
    @IBOutlet weak var chartTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var performanceChartLegendContainer: UIView!
    @IBOutlet weak var valueOverTimeChartLegendContainer: UIView!
    @IBOutlet weak var portfolioTotalReturnLabel: UILabel!
    @IBOutlet weak var indexNameLabel: UILabel!
    @IBOutlet weak var indexTotalReturnLabel: UILabel!
    @IBOutlet weak var portfolioTotalReturnDollarValue: UILabel!
    @IBOutlet weak var portfolioTotalMarketValueLabel: UILabel!
    @IBOutlet weak var trailingPeriod1MButton: UIButton!
    @IBOutlet weak var trailingPeriod3MButton: UIButton!
    @IBOutlet weak var trailingPeriod1YrButton: UIButton!
    @IBOutlet weak var trailingPeriod3YrButton: UIButton!
    @IBOutlet weak var trailingPeriod5YrButton: UIButton!
    @IBOutlet weak var trailingPeriodAllButton: UIButton!
    @IBOutlet weak var dateRangeLabel: UILabel!
    @IBOutlet weak var allocationClassNameLabel: UILabel!
    @IBOutlet weak var allocationClassValueLabel: UILabel!
    @IBOutlet weak var allocationClassDollarValueLabel: UILabel!
    @IBOutlet weak var goalAsOfDate: UILabel!
    @IBOutlet weak var allocationAsOfDate: UILabel!
    @IBOutlet weak var accountAsOfDate: UILabel!
    @IBOutlet weak var marketAsOfDate: UILabel!

    let selectedBlueColor = UIColor(red: 42/255.0, green: 78/255.0, blue: 133/255.0, alpha: 1.0)
    let trailingPeriodButtonSelectedFont = FontHelper.getDefaultFont(size: 13.0, bold: true)
    
    let radialGauge = TKRadialGauge()
    let allocationChart = TKChart()
    var valueOverTimeChart = TKChart()
    var performanceChart = TKChart()
    
    private enum TopContainerViewName: Int {
        case Performance = 0
        case ValueOverTime = 1
    }
    
    private enum BottomContainerViewName: Int {
        case MarketData = 0
        case Account = 1
        case Goal = 2
        case Allocation = 3
    }

    private var _currentTrailingPeriod: TrailingPeriod = .All
    private var _currentIndexType: IndexType = .Index1

    private var _topContainerViewName = TopContainerViewName.Performance {
        didSet {
            chartTypeSegmentedControl.selectedSegmentIndex = _topContainerViewName.rawValue
        }
    }
    
    private var _bottomContainerViewName = BottomContainerViewName.MarketData {
        didSet {
            bottomContainerPageControl.currentPage = _bottomContainerViewName.rawValue
        }
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()

        initializePerformanceChart()

        initializeValueOverTimeChart()

       
        initializeGoalChart()

        initializeAllocationChart()

        addGestures()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        self.landscapeLayoutContainer.isHidden = true
        self.portraitLayoutContainer.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
        
        coordinator.animate(alongsideTransition: nil, completion: {
            _ in
            
            if UIDevice.current.orientation.isLandscape {
                
                self.landscapeLayoutContainer.isHidden = false

                for i in 0..<self.landscapeLayoutContainer.subviews.count {
                    self.landscapeLayoutContainer.subviews[i].removeFromSuperview()
                }
               
                if (self._topContainerViewName == .Performance) {
                    let _ = self.getPerformanceChart(inView: self.landscapeLayoutContainer)
                }
                else {
                    let _ = self.getValueOverTimeChart(inView: self.landscapeLayoutContainer)
                }
            }
            else {
                self.portraitLayoutContainer.isHidden = false
                self.navigationController?.isNavigationBarHidden = false
                
                for i in 0..<self.landscapeLayoutContainer.subviews.count {
                    self.landscapeLayoutContainer.subviews[i].removeFromSuperview()
                }
            }
        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        initializeMarketDataView()
        initializeAccountView()

        let needle = radialGauge.scales[0].indicators[0] as! TKGaugeNeedle
        needle.setValueAnimated(80, withDuration: 1.5, mediaTimingFunction: kCAMediaTimingFunctionEaseInEaseOut)
        
        bottomContainerPageControl.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)

        let chartTypeSegmentedControlHeight = chartTypeSegmentedControl.frame.size.height
        let helveticsNeue13 = FontHelper.getDefaultFont(size: 13.0, bold: true)
        let selectedBlueColor = UIColor(red: 42/255.0, green: 78/255.0, blue: 133/255.0, alpha: 1.00)
        let imageWithColorOrigin = CGPoint(x: 0, y: chartTypeSegmentedControlHeight - 1)
        let imageWithColorSize = CGSize(width: 1, height: chartTypeSegmentedControlHeight)

        chartTypeSegmentedControl.setTitleTextAttributes([NSFontAttributeName: helveticsNeue13,NSForegroundColorAttributeName:UIColor.lightGray], for:UIControlState.normal)
        chartTypeSegmentedControl.setTitleTextAttributes([NSFontAttributeName:helveticsNeue13,NSForegroundColorAttributeName: selectedBlueColor], for:UIControlState.selected)
        chartTypeSegmentedControl.setDividerImage(UIImage.imageWithColor(color: UIColor.clear, origin: imageWithColorOrigin, size: imageWithColorSize), forLeftSegmentState: UIControlState.normal, rightSegmentState: UIControlState.normal, barMetrics: UIBarMetrics.default)
        chartTypeSegmentedControl.setBackgroundImage(UIImage.imageWithColor(color: UIColor.lightGray, origin: imageWithColorOrigin, size: imageWithColorSize), for:UIControlState.normal, barMetrics:UIBarMetrics.default)
        chartTypeSegmentedControl.setBackgroundImage(UIImage.imageWithColor(color: selectedBlueColor, origin: imageWithColorOrigin, size: imageWithColorSize), for:UIControlState.selected, barMetrics:UIBarMetrics.default);
    }

    func setChartTypeBorder() {

        for  borderview in chartTypeSegmentedControl.subviews {
            
            let upperBorder: CALayer = CALayer()
            upperBorder.backgroundColor = UIColor.gray.cgColor

            upperBorder.frame = CGRect.init(x: 0, y: borderview.frame.size.height-1, width: borderview.frame.size.width, height: 1.0);
            borderview.layer.removeAllAnimations()
            borderview.layer.addSublayer(upperBorder);
        }
    }
    
    func initializeMarketDataView() {
        
        let marketData = PortfolioData.getMarketData()
        let containerOrigin = marketDataContainer.frame.origin
        let containerWidth = marketDataContainer.frame.width

        let offset: CGFloat = 10

        var y = containerOrigin.y + 2*offset
        let height: CGFloat = 62
        let width: CGFloat = (containerWidth / 2) - 1.5*offset
        
        let column1X = containerOrigin.x + offset
        let column2X = column1X + width + offset
        
        for i in 0..<marketData.count {
            let marketItem = marketData[i]
            
            let marketItemView = MarketItemView.load(marketItem: marketItem)
            
            if i % 2 == 0 {
                marketItemView.frame = CGRect(x: column1X, y: y, width: width, height: height)
            }
            else {
                marketItemView.frame = CGRect(x: column2X, y: y, width: width, height: height)
                y += height + offset
            }
            
            marketDataContainer.addSubview(marketItemView)
        }
    }
    
    func initializeAccountView() {
        
        let accounts = PortfolioData.getAccounts()
        let containerOrigin = accountContainer.frame.origin
        let containerWidth = accountContainer.frame.width
        
        let offset: CGFloat = 10
        
        var y = containerOrigin.y + 2*offset
        let height: CGFloat = 62
        let width: CGFloat = (containerWidth / 2) - 1.5*offset
        
        let column1X = containerOrigin.x + offset
        let column2X = column1X + width + offset
        
        for i in 0..<accounts.count {
            let account = accounts[i]
            
            let accountItemView = DashboardAccountItemView.load(accountItem:  account, swatchColor: Color.palette[i])
            
            if i % 2 == 0 {
                accountItemView.frame = CGRect(x: column1X, y: y, width: width, height: height)
            }
            else {
                accountItemView.frame = CGRect(x: column2X, y: y, width: width, height: height)
                y += height + offset
            }
            
            accountContainer.addSubview(accountItemView)
        }
    }
    
    func getPerformanceData() -> (portfolioData: PortfolioData, portfolioReturns: [TKChartDataPoint], indexReturns: [TKChartDataPoint], indexName: String, minReturnValue: Double, maxReturnValue: Double) {

        var portfolioReturns = [TKChartDataPoint]()
        var indexReturns = [TKChartDataPoint]()
        var maxReturnValue: Double = 0.0, minReturnValue: Double = 0.0
        var indexName = ""
        let portfolioData = PortfolioData.load(trailingPeriod: _currentTrailingPeriod)
        
        for portfolioDataItem in (portfolioData?.portfolioDataItems)! {
           portfolioReturns.append(TKChartDataPoint(x: portfolioDataItem.returnDate, y: portfolioDataItem.portfolioReturnPercent))


            switch _currentIndexType {
            case .Index2:
                indexReturns.append(TKChartDataPoint(x: portfolioDataItem.returnDate, y: portfolioDataItem.index2ReturnPercent))
                indexName = portfolioData!.index2Name
            case .Index3:
                indexReturns.append(TKChartDataPoint(x: portfolioDataItem.returnDate, y: portfolioDataItem.index3ReturnPercent))
                indexName = portfolioData!.index3Name
            default:
                indexReturns.append(TKChartDataPoint(x: portfolioDataItem.returnDate, y: portfolioDataItem.index1ReturnPercent))
                indexName = portfolioData!.index1Name
            }

            minReturnValue = min(minReturnValue, portfolioDataItem.portfolioReturnPercent, portfolioDataItem.index1ReturnPercent)
            maxReturnValue = max(maxReturnValue, portfolioDataItem.portfolioReturnPercent, portfolioDataItem.index1ReturnPercent)
        }
        
        return (portfolioData: portfolioData!, portfolioReturns, indexReturns, indexName: indexName, minReturnValue, maxReturnValue)
    }
    
    func getValueData() -> (portfolioData: PortfolioData, portfolioValues: [TKChartDataPoint], minValue: Double, maxValue: Double) {
        
        var portfolioValues = [TKChartDataPoint]()
        var maxValue: Double = 0.0, minValue: Double = 0.0
        
        let portfolioData = PortfolioData.load(trailingPeriod: _currentTrailingPeriod)
        
        for portfolioDataItem in (portfolioData?.portfolioDataItems)! {
            portfolioValues.append(TKChartDataPoint(x: portfolioDataItem.returnDate, y: portfolioDataItem.marketValue))
            
            minValue = min(minValue, portfolioDataItem.marketValue)
            maxValue = max(maxValue, portfolioDataItem.marketValue)
        }
        
        return (portfolioData: portfolioData!, portfolioValues, minValue, maxValue)
    }
    
    func updateDateRangeLevel(portfolioData: PortfolioData) {
        dateRangeLabel.text = "Date range: \(portfolioData.inceptionDate.toShortDateString()) - \(portfolioData.endDate.toShortDateString())"
    }
    
    func initializePerformanceChart() {
        
        self.performanceChart = getPerformanceChart(inView: performanceChartContainer)
    }
    
    func getPerformanceChart(inView: UIView) -> TKChart {
        
        let performanceChart = TKChart(frame: inView.bounds)
        
        performanceChart.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.flexibleWidth.rawValue | UIViewAutoresizing.flexibleHeight.rawValue)
        //performanceChart.allowAnimations = true
        inView.addSubview(performanceChart)
        
        
        let performanceData = getPerformanceData()
        
        portfolioTotalReturnLabel.text = performanceData.portfolioData.totalPortfolioReturnPercent.toPercent(noOfDecimals: 1)
        setLabelColor(label: portfolioTotalReturnLabel, value: performanceData.portfolioData.totalPortfolioReturnPercent)
        
        indexTotalReturnLabel.text = performanceData.portfolioData.totalIndex1ReturnPercent.toPercent(noOfDecimals: 1)
        setLabelColor(label: indexTotalReturnLabel, value: performanceData.portfolioData.totalIndex1ReturnPercent)
        
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
        paletteItem2.stroke = TKStroke(color: UIColor(red: 154/255.0, green: 181/255.0, blue: 228/255.0, alpha: 1.00))
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
        //  xAxis.style.labelStyle.firstLabelTextAlignment = .left
        
        performanceChart.xAxis = xAxis
        
        let yAxis = TKChartNumericAxis(minimum: performanceData.minReturnValue, andMaximum: performanceData.maxReturnValue)
        yAxis.style.labelStyle.font = FontHelper.getDefaultFont(size: 8.0, light: true)
        yAxis.style.labelStyle.textAlignment = TKChartAxisLabelAlignment(rawValue: TKChartAxisLabelAlignment.right.rawValue | TKChartAxisLabelAlignment.bottom.rawValue)
        
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
    
    private func openPopoverMenu() {
        let pomVC = PopOverMenuVC()
        
        pomVC.popoverPresentationController!.sourceView = self.indexNameLabel
        pomVC.popoverPresentationController!.sourceRect = CGRect(x: 0, y: 10, width: 10, height: 10)
        pomVC.popoverPresentationController!.delegate = self
        
        pomVC.menuItems.append((text: PortfolioData.portfolioData_All!.index1Name, action: {
            [unowned self] in
            self.indexNameLabel.text = PortfolioData.portfolioData_All!.index1Name
            self._currentIndexType = .Index1
            self.initializePerformanceChart()
        }))

        pomVC.menuItems.append((text: PortfolioData.portfolioData_All!.index2Name, action: {
            [unowned self] in
            self.indexNameLabel.text = PortfolioData.portfolioData_All!.index2Name
            self._currentIndexType = .Index2
            self.initializePerformanceChart()
        }))
        
        pomVC.menuItems.append((text: PortfolioData.portfolioData_All!.index3Name, action: {
            [unowned self] in
            self.indexNameLabel.text = PortfolioData.portfolioData_All!.index3Name
            self._currentIndexType = .Index3
            self.initializePerformanceChart()
        }))
       
        self.present(pomVC, animated: true, completion: nil)
    }
    
    private func setAllocationCenterLabel(point: TKChartData) {
        allocationChartContainer.bringSubview(toFront: allocationClassNameLabel)
        allocationChartContainer.bringSubview(toFront: allocationClassValueLabel)
        allocationClassNameLabel.text = point.dataName
        allocationClassValueLabel.text = (point.dataXValue as! Double).toPercent(noOfDecimals: 1)
        allocationClassDollarValueLabel.text = (point.dataYValue as! Double).toCurrency()
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
        func chart(_ chart: TKChart, didSelectPoint point: TKChartData, in series: TKChartSeries, at index: Int) {
        if chart == allocationChart {
            setAllocationCenterLabel(point: point)
        }
    }
    
    func chart(_ chart: TKChart, trackballDidTrackSelection selection: [Any]) {
        let str = NSMutableString()
        var i = 0
        let count = selection.count
        
        let allData = selection as! [TKChartSelectionInfo]
       
        str.append("\((allData[0].dataPoint!.dataXValue as! Date).toShortDateString())\n")
        
        if _topContainerViewName == .Performance {
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
        else if _topContainerViewName == .ValueOverTime {
            let data = allData[0].dataPoint as TKChartData!
            str.append("\(allData[0].series!.title!): \((data!.dataYValue as! Double).toCurrency()) \n")
        }
        
        chart.trackball.tooltip.text = str as String
    }
    
    func setLabelColor(label: UILabel, value: Double) {
        if value < 0 {
            label.textColor = UIColor.red
        }
        else {
            label.textColor = UIColor(red: 15/255.0, green: 91/255.0, blue: 0/255.0, alpha: 1.0)
        }
    }
    
    func initializeValueOverTimeChart() {
        
        self.valueOverTimeChart =  getValueOverTimeChart(inView: valueOverTimeChartContainer)
    }

    func getValueOverTimeChart(inView: UIView) -> TKChart {
        let valueOverTimeChart = TKChart(frame: inView.bounds)
        valueOverTimeChart.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.flexibleWidth.rawValue | UIViewAutoresizing.flexibleHeight.rawValue)
        inView.addSubview(valueOverTimeChart)
        
        valueOverTimeChart.gridStyle.horizontalFill = nil
        
        let valueData = getValueData()
        
        
        portfolioTotalReturnDollarValue.text = valueData.portfolioData.totalPortfolioReturnDollar.toCurrency()
        setLabelColor(label: portfolioTotalReturnDollarValue, value: valueData.portfolioData.totalPortfolioReturnDollar)
        
        portfolioTotalMarketValueLabel.text = valueData.portfolioData.totalPortfolioMarketValueDollar.toCurrency()
        
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
        // xAxis.style.labelStyle.firstLabelTextAlignment = .left //hide to left
        
        valueOverTimeChart.xAxis = xAxis
        
        let yAxis = TKChartNumericAxis(minimum: valueData.minValue, andMaximum: valueData.maxValue)
        yAxis.style.labelStyle.font = FontHelper.getDefaultFont(size: 8.0, light: true)
        yAxis.style.labelStyle.textAlignment = TKChartAxisLabelAlignment(rawValue: TKChartAxisLabelAlignment.right.rawValue | TKChartAxisLabelAlignment.bottom.rawValue)
        
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

    func initializeGoalChart() {
        
        radialGauge.labelTitleOffset = CGPoint(x: radialGauge.labelTitle.bounds.origin.x, y: radialGauge.labelTitle.bounds.origin.y - 60)
        radialGauge.labelTitle.text = "80%"
        radialGauge.labelSubtitle.text = "on track"
        radialGauge.labelTitle.font = FontHelper.getDefaultFont(size: 20.0)
        
        goalChartContainer.addSubview(radialGauge)
        goalChartContainer.bringSubview(toFront: radialGauge)
        let scale = TKGaugeRadialScale(minimum: 0, maximum: 100)
        scale.startAngle = CGFloat(M_PI)
        scale.endAngle = CGFloat(2*M_PI)
        
        scale.labels.hidden = true
        scale.ticks.hidden = true

        radialGauge.addScale(scale)
        
        let ranges = [ TKRange(minimum: 0, andMaximum: 70),
                       TKRange(minimum: 71, andMaximum: 90),
                       TKRange(minimum: 91, andMaximum: 100) ]
        
        let colors = [ UIColor(red: 255/255.0, green: 200/255.0, blue: 200/255.0, alpha: 1.00), //light red
                       UIColor(red: 0.38, green: 0.73, blue: 0.00, alpha: 1.00), //dark green
                       UIColor(red: 1.00, green: 0.85, blue: 0.00, alpha: 1.00),
                       UIColor(red: 255/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.00), // light red
                       UIColor(red: 0.77, green: 1.00, blue: 0.00, alpha: 1.00), // dark green
                       UIColor(red: 0.96, green: 0.56, blue: 0.00, alpha: 1.00)
                        ]
        
        for i in 0..<ranges.count {
            
            let gradientSegment = TKGaugeSegment(range: ranges[i])
            
            if i == 1 {
                let darkGreen =  UIColor(red: 0.38, green: 0.73, blue: 0.00, alpha: 1.00)
                let lightGreen = UIColor(red: 0.77, green: 1.00, blue: 0.00, alpha: 1.00)
                gradientSegment.fill = TKLinearGradientFill(colors: [lightGreen, darkGreen, lightGreen])

            }
            else {
            gradientSegment.fill = TKLinearGradientFill(colors: [colors[i], colors[i + 3]])
           
            }
            // gradientSegment.cap = TKGaugeSegmentCap.round
            gradientSegment.width = 0.2
            gradientSegment.cap = .edge
          //  gradientSegment.location = 0.5 + CGFloat(i) * 0.25
            scale.addSegment(gradientSegment)
            
        }
        
        // >> gauge-needle-swift
        let needle = TKGaugeNeedle()
        needle.length = 0.8
        needle.width = 2
        
        needle.topWidth = 6
        needle.circleRadius = 0
        needle.shadowOffset = CGSize(width: 1, height: 1);
        needle.shadowOpacity = 0.8;
        needle.shadowRadius = 1.5;
        scale.addIndicator(needle)

        //remove trial label
        radialGauge.subviews[radialGauge.subviews.count - 1].removeFromSuperview()

    }
    
    func initializeAllocationChart() {

        let bounds = allocationChartDonutContainer.bounds

        allocationChart.frame = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height).insetBy(dx: 0, dy: 0)
        allocationChart.autoresizingMask = UIViewAutoresizing(rawValue:~UIViewAutoresizing().rawValue)

        allocationChart.legend.isHidden = true

        allocationChart.legend.style.insets = UIEdgeInsets.zero
        allocationChart.legend.style.offset = UIOffset.zero
        allocationChartDonutContainer.addSubview(allocationChart)

        let array:[TKChartDataPoint] = PortfolioData.getAllocations().map({TKChartDataPoint(x: $0.percent, y: $0.dollar, name: $0.name)})
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

        allocationChart.delegate = self
        
        setAllocationCenterLabel(point: array[0])

        //remove trial label
        allocationChart.subviews[allocationChart.subviews.count - 1].removeFromSuperview()
    }

    private var _donutLabelAdded = false
    override func viewDidLayoutSubviews() {
        let bounds = goalChartContainer.bounds
        let size = goalChartContainer.bounds.size
        let offset = CGFloat(20)
        
        radialGauge.frame = CGRect(x: offset*2, y: bounds.origin.y + 1.5*offset, width: size.width - offset*4, height: bottomContainer.frame.origin.y - bounds.origin.y - offset*8)
    }
    
    private func addGestures(){
        let bottomContainerSwipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.bottomContainerSwipe(swipeGesture:)))
        bottomContainerSwipeRightGesture.direction = .right
        bottomContainer.addGestureRecognizer(bottomContainerSwipeRightGesture)

        let  bottomContainerSwipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.bottomContainerSwipe(swipeGesture:)))
        bottomContainerSwipeLeftGesture.direction = .left
        bottomContainer.addGestureRecognizer(bottomContainerSwipeLeftGesture)

        let topContainerSwipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.topContainerSwipe(swipeGesture:)))
        topContainerSwipeRightGesture.direction = .right
        topContainer.addGestureRecognizer(topContainerSwipeRightGesture)
        
        let  topContainerSwipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.topContainerSwipe(swipeGesture:)))
        topContainerSwipeLeftGesture.direction = .left
        topContainer.addGestureRecognizer(topContainerSwipeLeftGesture)

        indexNameLabel.isUserInteractionEnabled = true
        let  indexNameTouchedGesture = UITapGestureRecognizer(target: self, action: #selector(self.indexNameTap(tapGesture:)))
        indexNameLabel.addGestureRecognizer(indexNameTouchedGesture)

    }
    
    func resetTrailingPeriodButtonsStyle() {
        
        let helveticaNeue12 = FontHelper.getDefaultFont(size: 12.0)
        
        let color = UIColor.darkGray

        trailingPeriod1MButton.titleLabel?.font = helveticaNeue12
        trailingPeriod1MButton.setTitleColor(color, for: .normal)
        trailingPeriod3MButton.titleLabel?.font = helveticaNeue12
        trailingPeriod3MButton.setTitleColor(color, for: .normal)
        trailingPeriod1YrButton.titleLabel?.font = helveticaNeue12
        trailingPeriod1YrButton.setTitleColor(color, for: .normal)
        trailingPeriod3YrButton.titleLabel?.font = helveticaNeue12
        trailingPeriod3YrButton.setTitleColor(color, for: .normal)
        trailingPeriod5YrButton.titleLabel?.font = helveticaNeue12
        trailingPeriod5YrButton.setTitleColor(color, for: .normal)
        trailingPeriodAllButton.titleLabel?.font = helveticaNeue12
        trailingPeriodAllButton.setTitleColor(color, for: .normal)
    }
    
    @IBAction func trailingPeriodChangedTo1M(_ sender: UIButton) {
        
        resetTrailingPeriodButtonsStyle()
        sender.titleLabel?.font = trailingPeriodButtonSelectedFont
        sender.setTitleColor(selectedBlueColor, for: .normal)
        _currentTrailingPeriod = .M1
        initializePerformanceChart()
        initializeValueOverTimeChart()
    }
    
    @IBAction func trailingPeriodChangedTo3M(_ sender: UIButton) {
        resetTrailingPeriodButtonsStyle()
        sender.titleLabel?.font = trailingPeriodButtonSelectedFont
        sender.setTitleColor(selectedBlueColor, for: .normal)
        _currentTrailingPeriod = .M3
        initializePerformanceChart()
        initializeValueOverTimeChart()
    }
    
    @IBAction func trailingPeriodChangedTo1Yr(_ sender: UIButton) {
        resetTrailingPeriodButtonsStyle()
        sender.titleLabel?.font = trailingPeriodButtonSelectedFont
        sender.setTitleColor(selectedBlueColor, for: .normal)
        _currentTrailingPeriod = .Y1
        initializePerformanceChart()
        initializeValueOverTimeChart()
    }
    
    @IBAction func trailingPeriodChangedTo3Yr(_ sender: UIButton) {
        resetTrailingPeriodButtonsStyle()
        sender.titleLabel?.font = trailingPeriodButtonSelectedFont
        sender.setTitleColor(selectedBlueColor, for: .normal)
        _currentTrailingPeriod = .Y3
        initializePerformanceChart()
        initializeValueOverTimeChart()
    }

    @IBAction func trailingPeriodChangedTo5Yr(_ sender: UIButton) {
        resetTrailingPeriodButtonsStyle()
        sender.titleLabel?.font = trailingPeriodButtonSelectedFont
        sender.setTitleColor(selectedBlueColor, for: .normal)
        _currentTrailingPeriod = .Y5
        initializePerformanceChart()
        initializeValueOverTimeChart()
    }
    
    @IBAction func trailingPeriodChangedToAll(_ sender: UIButton) {
        resetTrailingPeriodButtonsStyle()
        sender.titleLabel?.font = FontHelper.getDefaultFont(size: 12.0, bold: true)
        sender.setTitleColor(selectedBlueColor, for: .normal)
        _currentTrailingPeriod = .All
        initializePerformanceChart()
        initializeValueOverTimeChart()
    }
    
    @IBAction func chartTypeValueChanged(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            changeTopPage(direction: .right)
        }
        else {
            changeTopPage(direction: .left)
        }
    }
    
    private func changeTopPage(direction: UISwipeGestureRecognizerDirection) {
        
        
        switch direction {
        case UISwipeGestureRecognizerDirection.left:

            switch _topContainerViewName {
            case .Performance:
                toggleBetweenViews(viewsToShow: [valueOverTimeChartContainer, valueOverTimeChartLegendContainer], viewsToHide: [performanceChartContainer, performanceChartLegendContainer], toLeft: true)
                _topContainerViewName = .ValueOverTime
            case .ValueOverTime:
                break
            }
            
        case UISwipeGestureRecognizerDirection.right:
            
            switch _topContainerViewName {
            case .Performance:
                break
            case .ValueOverTime:
                toggleBetweenViews(viewsToShow: [performanceChartContainer, performanceChartLegendContainer], viewsToHide: [valueOverTimeChartContainer, valueOverTimeChartLegendContainer], toLeft: false)
                _topContainerViewName = .Performance
                break
            }
        default:
            break
        }
    }

    func indexNameTap(tapGesture: UITapGestureRecognizer) {
        openPopoverMenu()
    }

    
    func topContainerSwipe(swipeGesture: UISwipeGestureRecognizer) {
        changeTopPage(direction: swipeGesture.direction)
    }
    
    func bottomContainerSwipe(swipeGesture: UISwipeGestureRecognizer) {
        changeBottomPage(direction: swipeGesture.direction)
    }
    
    @IBAction func bottomContainerPageChange(_ sender: AnyObject) {
        if sender.currentPage > _bottomContainerViewName.rawValue {
            changeBottomPage(direction: .left)
        }
        else if sender.currentPage < _bottomContainerViewName.rawValue {
            changeBottomPage(direction: .right)
        }
    }
    
    private func changeBottomPage(direction: UISwipeGestureRecognizerDirection){
        switch direction {
        case UISwipeGestureRecognizerDirection.left:
            switch _bottomContainerViewName {
            case .MarketData:
                toggleBetweenViews(viewsToShow: [accountContainer], viewsToHide: [marketDataContainer], toLeft: true)
                _bottomContainerViewName = .Account
            case .Account:
                toggleBetweenViews(viewsToShow: [goalChartContainer], viewsToHide: [accountContainer], toLeft: true)
                _bottomContainerViewName = .Goal
            case .Goal:
                toggleBetweenViews(viewsToShow: [allocationChartContainer], viewsToHide: [goalChartContainer], toLeft: true)
                _bottomContainerViewName = .Allocation
            case .Allocation:
                break
            }
        case UISwipeGestureRecognizerDirection.right:
            switch _bottomContainerViewName {
            case .MarketData:
               break
            case .Account:
                toggleBetweenViews(viewsToShow: [marketDataContainer], viewsToHide: [accountContainer], toLeft: false)
                _bottomContainerViewName = .MarketData
            case .Goal:
                toggleBetweenViews(viewsToShow: [accountContainer], viewsToHide: [goalChartContainer], toLeft: false)
                _bottomContainerViewName = .Account
            case .Allocation:
                toggleBetweenViews(viewsToShow: [goalChartContainer], viewsToHide: [allocationChartContainer], toLeft: false)
                _bottomContainerViewName = .Goal
            }
        default:
            break
        }
    }
}
