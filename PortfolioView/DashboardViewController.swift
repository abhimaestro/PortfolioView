//
//  DashboardViewController.swift
//  PortfolioView
//
//  Created by Abhishek Sharma on 12/15/16.
//  Copyright © 2016 Abhishek Sharma. All rights reserved.
//

import UIKit
import Foundation

class DashboardViewController: UIViewController, TKChartDelegate, UIPopoverPresentationControllerDelegate {

    
    @IBOutlet weak var performanceChartContainer: UIView!
    @IBOutlet weak var valueOverTimeChartContainer: UIView!
    @IBOutlet weak var portraitLayoutContainer: UIView!
    @IBOutlet weak var landscapeLayoutContainer: UIView!
    @IBOutlet weak var topContainer: UIView!
    @IBOutlet weak var bottomContainer: UIView!
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

    let selectedBlueColor = UIColor(red: 42/255.0, green: 78/255.0, blue: 133/255.0, alpha: 1.0)
    let trailingPeriodButtonSelectedFont = FontHelper.getDefaultFont(size: 13.0, bold: true)
    
    let radialGauge = TKRadialGauge()
    let donutChart = TKChart()
    var valueOverTimeChart = TKChart()
    var performanceChart = TKChart()
    
    private enum TopContainerViewName: Int {
        case Performance = 0
        case ValueOverTime = 1
    }
    
    private enum BottomContainerViewName: Int {
        case Goal = 0
        case Allocation = 1
    }

    private var _currentTrailingPeriod: TrailingPeriod = .All
    private var _currentIndexType: IndexType = .Index1

    private var _topContainerViewName = TopContainerViewName.Performance {
        didSet {
            chartTypeSegmentedControl.selectedSegmentIndex = _topContainerViewName.rawValue
        }
    }
    
    private var _bottomContainerViewName = BottomContainerViewName.Goal {
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

        //NotificationCenter.default.addObserver(self, selector: #selector(ViewController.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil, completion: {
            _ in
            
            if UIDevice.current.orientation.isLandscape {
                    self.landscapeLayoutContainer.isHidden = false
                    self.portraitLayoutContainer.isHidden = true
                self.navigationController?.isNavigationBarHidden = true
                
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
                self.landscapeLayoutContainer.isHidden = true
                self.portraitLayoutContainer.isHidden = false
                self.navigationController?.isNavigationBarHidden = false
                
                for i in 0..<self.landscapeLayoutContainer.subviews.count {
                    self.landscapeLayoutContainer.subviews[i].removeFromSuperview()
                }
            }
        })
        
    }
    
    func imageWithColor(color: UIColor) -> UIImage {
        
        let rect = CGRect.init(x: 0.0, y: 0.0, width: 1.0, height: chartTypeSegmentedControl.frame.size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor);
        context!.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let needle = radialGauge.scales[0].indicators[0] as! TKGaugeNeedle
        needle.setValueAnimated(80, withDuration: 1.5, mediaTimingFunction: kCAMediaTimingFunctionEaseInEaseOut)
        
        bottomContainerPageControl.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)

        let chartTypeSegmentedControlHeight = chartTypeSegmentedControl.frame.size.height
        let helveticsNeue13 = UIFont(name:"HelveticaNeue-Bold", size:13.0)!
        let selectedBlueColor = UIColor(red: 42/255.0, green: 78/255.0, blue: 133/255.0, alpha: 1.00)
        let imageWithColorOrigin = CGPoint(x: 0, y: chartTypeSegmentedControlHeight - 1)
        let imageWithColorSize = CGSize(width: 1, height: chartTypeSegmentedControlHeight)

        chartTypeSegmentedControl.setTitleTextAttributes([NSFontAttributeName: helveticsNeue13,NSForegroundColorAttributeName:UIColor.lightGray], for:UIControlState.normal)
        chartTypeSegmentedControl.setTitleTextAttributes([NSFontAttributeName:helveticsNeue13,NSForegroundColorAttributeName: selectedBlueColor], for:UIControlState.selected)
        chartTypeSegmentedControl.setDividerImage(UIImage.imageWithColor(color: UIColor.clear, origin: imageWithColorOrigin, size: imageWithColorSize), forLeftSegmentState: UIControlState.normal, rightSegmentState: UIControlState.normal, barMetrics: UIBarMetrics.default)
        chartTypeSegmentedControl.setBackgroundImage(UIImage.imageWithColor(color: UIColor.lightGray, origin: imageWithColorOrigin, size: imageWithColorSize), for:UIControlState.normal, barMetrics:UIBarMetrics.default)
        chartTypeSegmentedControl.setBackgroundImage(UIImage.imageWithColor(color: selectedBlueColor, origin: imageWithColorOrigin, size: imageWithColorSize), for:UIControlState.selected, barMetrics:UIBarMetrics.default);
     
       // setChartTypeBorder()

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
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = .short
        dateRangeLabel.text = "Date range: \(dateformatter.string(from: portfolioData.inceptionDate)) - \(dateformatter.string(from: portfolioData.endDate))"
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
        
        portfolioTotalReturnLabel.text = String(format: "%.1f%%", performanceData.portfolioData.totalPortfolioReturnPercent)
        setLabelColor(label: portfolioTotalReturnLabel, value: performanceData.portfolioData.totalPortfolioReturnPercent)
        
        indexTotalReturnLabel.text = String(format: "%.1f%%", performanceData.portfolioData.totalIndex1ReturnPercent)
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
        xAxis.style.labelStyle.font = UIFont(name:"HelveticaNeue-Light", size:9.0)!
        xAxis.setPlotMode(TKChartAxisPlotMode.onTicks)
        xAxis.style.majorTickStyle.ticksHidden = true
        xAxis.style.lineHidden = true
        xAxis.style.labelStyle.textAlignment = TKChartAxisLabelAlignment(rawValue: TKChartAxisLabelAlignment.top.rawValue)
        xAxis.style.labelStyle.textOffset = UIOffset(horizontal: 0, vertical: -2)
        //  xAxis.style.labelStyle.firstLabelTextAlignment = .left
        
        performanceChart.xAxis = xAxis
        
        let yAxis = TKChartNumericAxis(minimum: performanceData.minReturnValue, andMaximum: performanceData.maxReturnValue)
        yAxis.style.labelStyle.font = UIFont(name:"HelveticaNeue-Light", size:8.0)!
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
        allocationClassValueLabel.text = String(format: "%.1f%%", (point.dataXValue as! Double))
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
        func chart(_ chart: TKChart, didSelectPoint point: TKChartData, in series: TKChartSeries, at index: Int) {
        if chart == donutChart {
            setAllocationCenterLabel(point: point)
        }
    }
    
    func chart(_ chart: TKChart, trackballDidTrackSelection selection: [Any]) {
        let str = NSMutableString()
        var i = 0
        let count = selection.count
        
        let allData = selection as! [TKChartSelectionInfo]
        let xDate = allData[0].dataPoint!.dataXValue as! Date
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = .short
        let dateString = dateformatter.string(from: xDate)
        
        str.append("\(dateString)\n")
        
        if _topContainerViewName == .Performance {
        for info in allData {
            let data = info.dataPoint as TKChartData!
           
             let dataValue = String(format: "%.1f%%", (data!.dataYValue as! Double))
            
            str.append("\(info.series!.title!): \(dataValue)")
            // str.append("\(data?.dataYValue as! Float)")
            if (i<count-1) {
                str.append("\n");
            }
            i += 1
            }
        }
        
        else if _topContainerViewName == .ValueOverTime {
            let data = allData[0].dataPoint as TKChartData!
            
            let currencyFormatter = NumberFormatter()
            currencyFormatter.numberStyle = .currency
            currencyFormatter.maximumFractionDigits = 0
            
            let dataValue = currencyFormatter.string(from: (data!.dataYValue as! NSNumber))!
            str.append("\(allData[0].series!.title!): \(dataValue) \n")
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
        
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.maximumFractionDigits = 0
        portfolioTotalReturnDollarValue.text = currencyFormatter.string(from: (valueData.portfolioData.totalPortfolioReturnDollar as NSNumber))!
        setLabelColor(label: portfolioTotalReturnDollarValue, value: valueData.portfolioData.totalPortfolioReturnDollar)
        
        portfolioTotalMarketValueLabel.text = currencyFormatter.string(from: (valueData.portfolioData.totalPortfolioMarketValueDollar as NSNumber))!
        
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
        xAxis.style.labelStyle.font = UIFont(name:"HelveticaNeue-Light", size:9.0)!
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

         donutChart.frame = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height).insetBy(dx: 0, dy: 0)
        donutChart.autoresizingMask = UIViewAutoresizing(rawValue:~UIViewAutoresizing().rawValue)

        //donutChart.allowAnimations = true
        donutChart.legend.isHidden = true
//        donutChart.legend.style.position = .right


        donutChart.legend.style.insets = UIEdgeInsets.zero
        donutChart.legend.style.offset = UIOffset.zero
        allocationChartDonutContainer.addSubview(donutChart)



        let array:[TKChartDataPoint] = [
            TKChartDataPoint(name: "Equity", value: 70.0),
            TKChartDataPoint(name: "Fixed Income", value: 15.0),
            TKChartDataPoint(name:"Alternatives", value: 10.0),
            TKChartDataPoint(name: "Cash", value: 5.0)]
        
        let donutSeries = TKChartDonutSeries(items:array)

        donutSeries.style.paletteMode = .useItemIndex
        donutSeries.style.palette = TKChartPalette()

        let colorsLiberty = [
            UIColor(red: 207/255.0, green: 248/255.0, blue: 246/255.0, alpha: 1.0),
            UIColor(red: 148/255.0, green: 212/255.0, blue: 212/255.0, alpha: 1.0),
            UIColor(red: 136/255.0, green: 180/255.0, blue: 187/255.0, alpha: 1.0),
            UIColor(red: 118/255.0, green: 174/255.0, blue: 175/255.0, alpha: 1.0),
            UIColor(red: 42/255.0, green: 109/255.0, blue: 130/255.0, alpha: 1.0)
        ]

        let colorsJoyful =  [
            UIColor(red: 217/255.0, green: 80/255.0, blue: 138/255.0, alpha: 1.0),
            UIColor(red: 254/255.0, green: 149/255.0, blue: 7/255.0, alpha: 1.0),
            UIColor(red: 254/255.0, green: 247/255.0, blue: 120/255.0, alpha: 1.0),
            UIColor(red: 106/255.0, green: 167/255.0, blue: 134/255.0, alpha: 1.0),
            UIColor(red: 53/255.0, green: 194/255.0, blue: 209/255.0, alpha: 1.0)
        ]

        let colorsPastel = [
                UIColor(red: 64/255.0, green: 89/255.0, blue: 128/255.0, alpha: 1.0),
                UIColor(red: 149/255.0, green: 165/255.0, blue: 124/255.0, alpha: 1.0),
                UIColor(red: 217/255.0, green: 184/255.0, blue: 162/255.0, alpha: 1.0),
                UIColor(red: 191/255.0, green: 134/255.0, blue: 134/255.0, alpha: 1.0),
                UIColor(red: 179/255.0, green: 48/255.0, blue: 80/255.0, alpha: 1.0)
        ]

        let colorsColorful = [
            UIColor(red: 193/255.0, green: 37/255.0, blue: 82/255.0, alpha: 1.0),
            UIColor(red: 255/255.0, green: 102/255.0, blue: 0/255.0, alpha: 1.0),
            UIColor(red: 245/255.0, green: 199/255.0, blue: 0/255.0, alpha: 1.0),
            UIColor(red: 106/255.0, green: 150/255.0, blue: 31/255.0, alpha: 1.0),
            UIColor(red: 179/255.0, green: 100/255.0, blue: 53/255.0, alpha: 1.0)
        ]
        
        let colorsVordiplom = [
            UIColor(red: 192/255.0, green: 255/255.0, blue: 140/255.0, alpha: 1.0),
            UIColor(red: 255/255.0, green: 247/255.0, blue: 140/255.0, alpha: 1.0),
            UIColor(red: 255/255.0, green: 208/255.0, blue: 140/255.0, alpha: 1.0),
            UIColor(red: 140/255.0, green: 234/255.0, blue: 255/255.0, alpha: 1.0),
            UIColor(red: 255/255.0, green: 140/255.0, blue: 157/255.0, alpha: 1.0)
        ]
        
//        Color One - R 106 G 213 B 207
//        Color Two - R 148 G 120 B162
//        Color Three - R 166 G 208 B100
//        Color Four - R 216 G 82 B 85
//        Color Five - R 89 G 156 B 155
//        Color Six - R 208 G 138 B 60
//        Color Seven - R 99 G 138 B 199
//        Color Eight - R 192 G 100 B 88
//        
        let colorsCustom = [
            UIColor(red: 106/255.0, green: 213/255.0, blue: 207/255.0, alpha: 1.0),
            UIColor(red: 148/255.0, green: 120/255.0, blue: 162/255.0, alpha: 1.0),
            UIColor(red: 166/255.0, green: 208/255.0, blue: 100/255.0, alpha: 1.0),
            UIColor(red: 216/255.0, green: 82/255.0, blue: 85/255.0, alpha: 1.0),
            UIColor(red: 89/255.0, green: 156/255.0, blue: 155/255.0, alpha: 1.0)
        ]
        
        for color in colorsCustom {
            let paletteItem = TKChartPaletteItem(fill: TKSolidFill(color: color))
            donutSeries.style.palette!.addItem(paletteItem)
        }


        
        donutSeries.selection = TKChartSeriesSelection.dataPoint
        donutSeries.innerRadius = 0.7
        donutSeries.expandRadius = 1.1
        donutSeries.rotationEnabled = false
        donutSeries.labelDisplayMode = .outside
        //donutChart.allowAnimations = false

        donutChart.addSeries(donutSeries)

        donutChart.delegate = self
        
        setAllocationCenterLabel(point: array[0])

        //remove trial label
        donutChart.subviews[donutChart.subviews.count - 1].removeFromSuperview()
    }

    private var _donutLabelAdded = false
    override func viewDidLayoutSubviews() {
        let bounds = bottomContainer.bounds
        let size = bottomContainer.bounds.size
        let offset = CGFloat(50)
        
        radialGauge.frame = CGRect(x: offset, y: bounds.origin.y + offset, width: size.width - offset*2, height: bottomContainer.frame.origin.y - bounds.origin.y - offset*4)

//        for i in 0..<donutChart.legend.container.itemCount {
//            let legendItem = donutChart.legend.container.item(at: i)
//            legendItem!.label.font = FontHelper.getDefaultFont(size: 11.0, light: true)
//        }
        
        
//        if !_donutLabelAdded {
//
//            let donutCenterX = bounds.origin.x + (bounds.width - donutChart.legend.container.frame.width - 20)
//            let donutCenterY = bounds.origin.y + (bounds.height / 2)
//            var label = UILabel()
//            label.text = "Hello"
//            label.font = FontHelper.getDefaultFont(size: 10.0)
//            label.frame = CGRect(x: donutCenterX, y: donutCenterY, width: 30, height: 20)
//            label.sizeToFit()
//            allocationChartContainer.addSubview(label)
//            _donutLabelAdded = true
//        }
    }
    
    private func addGestures(){
        let bottomContainerSwipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.bottomContainerSwipe(swipeGesture:)))
        bottomContainerSwipeRightGesture.direction = .right
        bottomContainer.addGestureRecognizer(bottomContainerSwipeRightGesture)
        
//        allocationChartContainer.addGestureRecognizer(donutChartSwipeRightGesture)
//        goalChartContainer.addGestureRecognizer(bottomContainerSwipeRightGesture)

        let  bottomContainerSwipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.bottomContainerSwipe(swipeGesture:)))
        bottomContainerSwipeLeftGesture.direction = .left
        bottomContainer.addGestureRecognizer(bottomContainerSwipeLeftGesture)
//        allocationChartContainer.addGestureRecognizer(bottomContainerSwipeLeftGesture)
//        goalChartContainer.addGestureRecognizer(bottomContainerSwipeRightGesture)

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
                //valueOverTimeChart.animate()
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
                //performanceChart.animate()
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
            case .Goal:
                toggleBetweenViews(viewsToShow: [allocationChartContainer], viewsToHide: [goalChartContainer], toLeft: true)
                _bottomContainerViewName = .Allocation
                //donutChart.animate()
            case .Allocation:
                break
            }
        case UISwipeGestureRecognizerDirection.right:
            switch _bottomContainerViewName {
            case .Goal:
                break
            case .Allocation:
                toggleBetweenViews(viewsToShow: [goalChartContainer], viewsToHide: [allocationChartContainer], toLeft: false)
                _bottomContainerViewName = .Goal
            }
        default:
            break
        }
    }
    
    func unsafeRandomIntFrom(start: Int, to end: Int) -> Int {
        return Int(arc4random_uniform(UInt32(end - start + 1))) + start
    }
}
