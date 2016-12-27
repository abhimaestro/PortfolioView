//
//  DashboardViewController.swift
//  PortfolioView
//
//  Created by Abhishek Sharma on 12/15/16.
//  Copyright © 2016 Abhishek Sharma. All rights reserved.
//

import UIKit
import Foundation

class DashboardViewController: UIViewController, TKChartDelegate {

    
    @IBOutlet weak var performanceChartContainer: UIView!
    @IBOutlet weak var valueOverTimeChartContainer: UIView!
    @IBOutlet weak var topContainer: UIView!
    @IBOutlet weak var bottomContainer: UIView!
    @IBOutlet weak var allocationChartContainer: UIView!
    @IBOutlet weak var goalChartContainer: UIView!
    @IBOutlet weak var bottomContainerPageControl: UIPageControl!
    @IBOutlet weak var chartTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var performanceChartLegendContainer: UIView!
    @IBOutlet weak var valueOverTimeChartLegendContainer: UIView!
    @IBOutlet weak var portfolioTotalReturnLabel: UILabel!
    @IBOutlet weak var indexTotalReturnLabel: UILabel!

    let radialGauge = TKRadialGauge()
    
    private enum TopContainerViewName: Int {
        case Performance = 0
        case ValueOverTime = 1
    }
    
    private enum BottomContainerViewName: Int {
        case Goal = 0
        case Allocation = 1
    }

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
        let helveticsNeue13 = UIFont(name:"Helvetica-Bold", size:13.0)!
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
    
    func getPerformanceData(trailingPeriod: TrailingPeriod = .All) -> (portfolioData: PortfolioData, portfolioReturns: [TKChartDataPoint], indexReturns: [TKChartDataPoint], minReturnValue: Double, maxReturnValue: Double) {

        var portfolioReturns = [TKChartDataPoint]()
        var indexReturns = [TKChartDataPoint]()
        var maxReturnValue: Double = 0.0, minReturnValue: Double = 0.0

        let portfolioData = PortfolioData.load(trailingPeriod: trailingPeriod)
        
        for portfolioDataItem in (portfolioData?.portfolioDataItems)! {
           portfolioReturns.append(TKChartDataPoint(x: portfolioDataItem.returnDate, y: portfolioDataItem.portfolioReturnPercent))
            indexReturns.append(TKChartDataPoint(x: portfolioDataItem.returnDate, y: portfolioDataItem.indexReturnPercent))

            minReturnValue = min(minReturnValue, portfolioDataItem.portfolioReturnPercent, portfolioDataItem.indexReturnPercent)
            maxReturnValue = max(maxReturnValue, portfolioDataItem.portfolioReturnPercent, portfolioDataItem.indexReturnPercent)
        }
        
        return (portfolioData: portfolioData!, portfolioReturns, indexReturns, minReturnValue, maxReturnValue)
    }
    
    func initializePerformanceChart(trailingPeriod: TrailingPeriod = .All) {
        let chart = TKChart(frame: performanceChartContainer.bounds)
        chart.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.flexibleWidth.rawValue | UIViewAutoresizing.flexibleHeight.rawValue)
        performanceChartContainer.addSubview(chart)
    
       
       
        let performanceData = getPerformanceData()
        
        portfolioTotalReturnLabel.text = String(format: "%.1f%%", performanceData.portfolioData.totalPortfolioReturnPercent)
        indexTotalReturnLabel.text = String(format: "%.1f%%", performanceData.portfolioData.totalIndexReturnPercent)
        
        let series = TKChartAreaSeries(items:performanceData.portfolioReturns)
        series.selection = TKChartSeriesSelection.series
        series.title = "Your Portfolio"
        
        let series2 = TKChartLineSeries(items:performanceData.indexReturns)
        series2.selection = TKChartSeriesSelection.series
        series2.title = "S&P 500"

        series.style.palette = TKChartPalette()
        let selectedBlueColor = UIColor(red: 42/255.0, green: 78/255.0, blue: 133/255.0, alpha: 1.00)
        let paletteItem = TKChartPaletteItem()
        paletteItem.stroke = TKStroke(color: selectedBlueColor)
        paletteItem.fill = TKLinearGradientFill(colors: [selectedBlueColor, UIColor.white])
        series.style.palette!.addItem(paletteItem)
        
        // >> chart-axis-datetime-swift
        let xAxis = TKChartDateTimeAxis(minimumDate: performanceData.portfolioData.inceptionDate, andMaximumDate: performanceData.portfolioData.endDate)
        //xAxis.majorTickIntervalUnit = TKChartDateTimeAxisIntervalUnit.custom
        xAxis.majorTickInterval = 2
        xAxis.style.labelStyle.font = UIFont(name:"HelveticaNeue-Light", size:9.0)!
        xAxis.setPlotMode(TKChartAxisPlotMode.onTicks)
        xAxis.style.majorTickStyle.ticksHidden = true
        xAxis.style.lineHidden = true
        xAxis.style.labelStyle.textAlignment = TKChartAxisLabelAlignment(rawValue: TKChartAxisLabelAlignment.top.rawValue)
        xAxis.style.labelStyle.textOffset = UIOffset(horizontal: 0, vertical: -2)
        xAxis.style.labelStyle.firstLabelTextAlignment = .left
        
        chart.xAxis = xAxis
       
        let yAxis = TKChartNumericAxis(minimum: performanceData.minReturnValue, andMaximum: performanceData.maxReturnValue)
        yAxis.style.labelStyle.font = UIFont(name:"HelveticaNeue-Light", size:8.0)!
        yAxis.style.labelStyle.textAlignment = TKChartAxisLabelAlignment(rawValue: TKChartAxisLabelAlignment.right.rawValue | TKChartAxisLabelAlignment.bottom.rawValue)
        
        yAxis.style.majorTickStyle.ticksHidden = true
        yAxis.style.lineHidden = true
        yAxis.labelFormat = "%.0f%%"
        yAxis.style.lineStroke = TKStroke(color:UIColor(white:0.85, alpha:1.0), width:2)

        chart.yAxis = yAxis


        
        chart.addSeries(series)
        chart.addSeries(series2)
        
        chart.allowTrackball = true
        chart.trackball.snapMode = TKChartTrackballSnapMode.allClosestPoints
        chart.delegate = self
        chart.trackball.tooltip.style.textAlignment = NSTextAlignment.left
        chart.trackball.tooltip.style.font = UIFont(name:"HelveticaNeue-Light", size:11.0)!
        
        chart.insets = UIEdgeInsets.zero
        chart.gridStyle.horizontalFill = nil
    }
    
    func chart(_ chart: TKChart, trackballDidTrackSelection selection: [Any]) {
        let str = NSMutableString()
        var i = 0
        let count = selection.count
        
        let allDate = selection as! [TKChartSelectionInfo]
        let xDate = allDate[0].dataPoint!.dataXValue as! Date
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = .short
        
        let dateString = dateformatter.string(from: xDate)
        
        str.append("\(dateString)\n")
        
        for info in allDate {
            let data = info.dataPoint as TKChartData!
           
            
            str.append("\(info.series!.title!): \(data!.dataYValue as! Double)%")
            // str.append("\(data?.dataYValue as! Float)")
            if (i<count-1) {
                str.append("\n");
            }
            i += 1
        }

        chart.trackball.tooltip.text = str as String
    }
    
    func initializeValueOverTimeChart() {
        let chart = TKChart(frame: valueOverTimeChartContainer.bounds)
        chart.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.flexibleWidth.rawValue | UIViewAutoresizing.flexibleHeight.rawValue)
        valueOverTimeChartContainer.addSubview(chart)
        
        let calendar = Calendar(identifier:Calendar.Identifier.gregorian)
        var dateTimeComponents = DateComponents()
        dateTimeComponents.year = 2013
        dateTimeComponents.day = 1
        
        
        chart.gridStyle.horizontalFill = nil
        
        var array = [TKChartDataPoint]()

        for i in 1...12 {
            dateTimeComponents.month = i
            let random = unsafeRandomIntFrom(start: 100000, to: 300000)
            array.append(TKChartDataPoint(x:calendar.date(from: dateTimeComponents), y: random))
        }
        
        let series = TKChartAreaSeries(items:array)
        series.selection = TKChartSeriesSelection.series
        
        
        series.style.palette = TKChartPalette()
        let selectedBlueColor = UIColor(red: 42/255.0, green: 78/255.0, blue: 133/255.0, alpha: 1.0)
        let fillBlueColor = UIColor(red: 216/255.0, green: 231/255.0, blue: 255/255.0, alpha: 0.5)
        let paletteItem = TKChartPaletteItem()
        paletteItem.stroke = TKStroke(color: selectedBlueColor)
        paletteItem.fill = TKLinearGradientFill(colors: [selectedBlueColor, fillBlueColor, UIColor.white])
        series.style.palette!.addItem(paletteItem)
        
        dateTimeComponents.month = 1
        let minDate = calendar.date(from: dateTimeComponents)!
        dateTimeComponents.month = 12
        let maxDate = calendar.date(from: dateTimeComponents)!
        
        // >> chart-axis-datetime-swift
        let xAxis = TKChartDateTimeAxis(minimumDate: minDate, andMaximumDate: maxDate)
        //xAxis.majorTickIntervalUnit = TKChartDateTimeAxisIntervalUnit.custom
        xAxis.majorTickInterval = 4
        xAxis.style.labelStyle.font = UIFont(name:"HelveticaNeue-Light", size:9.0)!
        xAxis.setPlotMode(TKChartAxisPlotMode.onTicks)
        xAxis.style.majorTickStyle.ticksHidden = true
        xAxis.style.lineHidden = true
        xAxis.style.labelStyle.textAlignment = TKChartAxisLabelAlignment(rawValue: TKChartAxisLabelAlignment.top.rawValue)
        xAxis.style.labelStyle.textOffset = UIOffset(horizontal: 0, vertical: -2)
        xAxis.style.labelStyle.firstLabelTextAlignment = .left //hide to left
        
        chart.xAxis = xAxis
        
        let yAxis = TKChartNumericAxis(minimum: 100000, andMaximum: 300000)
        yAxis.style.labelStyle.font = UIFont(name:"HelveticaNeue-Light", size:8.0)!
        yAxis.style.labelStyle.textAlignment = TKChartAxisLabelAlignment(rawValue: TKChartAxisLabelAlignment.right.rawValue | TKChartAxisLabelAlignment.bottom.rawValue)
        
        yAxis.style.majorTickStyle.ticksHidden = true
        yAxis.style.lineHidden = true
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.maximumFractionDigits = 0
        
        yAxis.labelFormatter = currencyFormatter
        yAxis.style.lineStroke = TKStroke(color:UIColor(white:0.85, alpha:1.0), width:2)
        
        chart.yAxis = yAxis
        
        
        chart.addSeries(series)
        
        chart.insets = UIEdgeInsets.zero
        
    }

    
    func initializeGoalChart() {
        
        radialGauge.labelTitleOffset = CGPoint(x: radialGauge.labelTitle.bounds.origin.x, y: radialGauge.labelTitle.bounds.origin.y - 60)
        radialGauge.labelTitle.text = "80%"
        radialGauge.labelSubtitle.text = "on track"
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
            
//            let segment = TKGaugeSegment(range: ranges[i])
//            segment.width = 0.02
//            segment.fill = TKSolidFill(color: colors[i])
//            scale.addSegment(segment)
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

    }
    
    func initializeAllocationChart() {
        let donutChart = TKChart()
        
        let bounds = bottomContainer.bounds
        let offset = CGFloat(10)
        donutChart.frame = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height).insetBy(dx: 10, dy: 10)
        donutChart.autoresizingMask = UIViewAutoresizing(rawValue:~UIViewAutoresizing().rawValue)
        donutChart.allowAnimations = true
        donutChart.legend.isHidden = false
        donutChart.legend.style.position = TKChartLegendPosition.right
        
        donutChart.legend.style.insets = UIEdgeInsets.zero
        donutChart.legend.style.offset = UIOffset.zero
        print(donutChart.legend.style.offsetOrigin)
        allocationChartContainer.addSubview(donutChart)
        
        let array:[TKChartDataPoint] = [
            TKChartDataPoint(name: "Equity", value: 70),
            TKChartDataPoint(name: "Fixed Income", value: 15),
            TKChartDataPoint(name:"Alternatives", value: 10),
            TKChartDataPoint(name: "Cash", value: 5)]
        
        let donutSeries = TKChartPieSeries(items:array)
        donutSeries.selection = TKChartSeriesSelection.dataPoint
       // donutSeries.innerRadius = 0.7
        donutSeries.expandRadius = 1.1
        
        donutChart.addSeries(donutSeries)
    }
    
    override func viewDidLayoutSubviews() {
        let bounds = bottomContainer.bounds
        print(bounds)
        let size = bottomContainer.bounds.size
        let offset = CGFloat(30)
        
        radialGauge.frame = CGRect(x: offset, y: bounds.origin.y + offset, width: size.width - offset*2, height: bottomContainer.frame.origin.y - bounds.origin.y - offset*4)
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

    }
    
    
    @IBAction func trailingPeriodChangedTo1M(_ sender: Any) {
        initializePerformanceChart(trailingPeriod: .M1)
    }
    
    @IBAction func trailingPeriodChangedTo3M(_ sender: Any) {
    initializePerformanceChart(trailingPeriod: .M3)
    }
    
    @IBAction func trailingPeriodChangedTo1Yr(_ sender: Any) {
        initializePerformanceChart(trailingPeriod: .Y1)
    }
    
    @IBAction func trailingPeriodChangedTo3Yr(_ sender: Any) {
    initializePerformanceChart(trailingPeriod: .Y3)
    }

    @IBAction func trailingPeriodChangedTo5Yr(_ sender: Any) {
    initializePerformanceChart(trailingPeriod: .Y5)
    }
    
    @IBAction func trailingPeriodChangedToAll(_ sender: Any) {
        initializePerformanceChart(trailingPeriod: .All)
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
