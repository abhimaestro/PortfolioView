//
//  DashboardViewController.swift
//  PortfolioView
//
//  Created by Abhishek Sharma on 12/15/16.
//  Copyright © 2016 Abhishek Sharma. All rights reserved.
//

import UIKit
import Foundation

class DashboardViewController: UIViewController {

    @IBOutlet weak var topChartContainer: UIView!
    @IBOutlet weak var bottomContainer: UIView!
    @IBOutlet weak var allocationChartContainer: UIView!
    @IBOutlet weak var goalChartContainer: UIView!
    @IBOutlet weak var bottomContainerPageControl: UIPageControl!
    @IBOutlet weak var chartTypeSegmentedControl: UISegmentedControl!

    let radialGauge = TKRadialGauge()
    
    private enum BottomContainerViewName: Int {
        case Goal = 0

        case Allocation = 1
    }
    
    private var _bottomContainerViewName = BottomContainerViewName.Goal {
        didSet {
            bottomContainerPageControl.currentPage = _bottomContainerViewName.rawValue
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        initializePerformanceChart()

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
        chartTypeSegmentedControl.setTitleTextAttributes([NSFontAttributeName: helveticsNeue13,NSForegroundColorAttributeName:UIColor.lightGray], for:UIControlState.normal)
        chartTypeSegmentedControl.setTitleTextAttributes([NSFontAttributeName:helveticsNeue13,NSForegroundColorAttributeName: selectedBlueColor], for:UIControlState.selected)
        chartTypeSegmentedControl.setDividerImage(UIImage.imageWithColor(color: UIColor.clear, size: CGSize(width: 1, height: chartTypeSegmentedControlHeight)), forLeftSegmentState: UIControlState.normal, rightSegmentState: UIControlState.normal, barMetrics: UIBarMetrics.default)
        chartTypeSegmentedControl.setBackgroundImage(UIImage.imageWithColor(color: UIColor.lightGray, size: CGSize(width: 1, height: chartTypeSegmentedControlHeight)), for:UIControlState.normal, barMetrics:UIBarMetrics.default)
        chartTypeSegmentedControl.setBackgroundImage(UIImage.imageWithColor(color: selectedBlueColor, size: CGSize(width: 1, height: chartTypeSegmentedControlHeight)), for:UIControlState.selected, barMetrics:UIBarMetrics.default);
     
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
    
    @IBAction func chartTypeValueChanged(_ sender: UISegmentedControl) {

    }
    
    func initializePerformanceChart() {
        let chart = TKChart(frame: topChartContainer.bounds)
        chart.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.flexibleWidth.rawValue | UIViewAutoresizing.flexibleHeight.rawValue)
        topChartContainer.addSubview(chart)
    
        let calendar = Calendar(identifier:Calendar.Identifier.gregorian)
        var dateTimeComponents = DateComponents()
        dateTimeComponents.year = 2013
        dateTimeComponents.day = 1

       
        
        var array = [TKChartDataPoint]()
        for i in 1...12 {
            dateTimeComponents.month = i
            let random = unsafeRandomIntFrom(start: -10, to: 40)
            array.append(TKChartDataPoint(x:calendar.date(from: dateTimeComponents), y: random))
        }
        
        let series = TKChartAreaSeries(items:array)
        series.selection = TKChartSeriesSelection.series
        
        dateTimeComponents.month = 1
        let minDate = calendar.date(from: dateTimeComponents)!
        dateTimeComponents.month = 12
        let maxDate = calendar.date(from: dateTimeComponents)!
        
        // >> chart-axis-datetime-swift
        let xAxis = TKChartDateTimeAxis(minimumDate: minDate, andMaximumDate: maxDate)
        //xAxis.majorTickIntervalUnit = TKChartDateTimeAxisIntervalUnit.custom
        xAxis.majorTickInterval = 4
        //xAxis.setMajorTickCount(3)
        // xAxis.customLabels = [100:  UIColor.blue, 200: UIColor(red: 0.96, green: 0.00, blue: 0.22, alpha: 1.0), 400: UIColor(red: 0.00, green: 0.90, blue: 0.42, alpha: 1.0)]        // << chart-axis-datetime-swift
        
        // >> chart-category-plot-onticks-swift
        xAxis.setPlotMode(TKChartAxisPlotMode.onTicks)
        // << chart-category-plot-onticks-swift
        
        chart.xAxis = xAxis
        chart.addSeries(series)
        chart.yAxis!.style.labelStyle.textAlignment = TKChartAxisLabelAlignment(rawValue: TKChartAxisLabelAlignment.right.rawValue | TKChartAxisLabelAlignment.bottom.rawValue)

        chart.yAxis!.style.majorTickStyle.ticksHidden = true
        chart.yAxis!.style.lineHidden = true
       chart.yAxis!.labelFormat = "%.0f%%"
        // chart.yAxis!.style.labelStyle.lastLabelTextAlignment = TKChartAxisLabelAlignment(rawValue: TKChartAxisLabelAlignment.right.rawValue | TKChartAxisLabelAlignment.bottom.rawValue)
        
        chart.xAxis!.style.majorTickStyle.ticksHidden = true
        chart.xAxis!.style.lineHidden = true
        chart.xAxis!.style.labelStyle.firstLabelTextAlignment = .right
        chart.xAxis!.style.labelStyle.lastLabelTextAlignment = .left
        
       chart.insets = UIEdgeInsets.zero
    }
    
    func initializeGoalChart() {
        
        radialGauge.labelTitleOffset = CGPoint(x: radialGauge.labelTitle.bounds.origin.x, y: radialGauge.labelTitle.bounds.origin.y - 80)
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
        
        let colors = [ UIColor(red: 255/255.0, green: 130/255.0, blue: 130/255.0, alpha: 1.00),
                       UIColor(red: 0.38, green: 0.73, blue: 0.00, alpha: 1.00),
                       UIColor(red: 1.00, green: 0.85, blue: 0.00, alpha: 1.00),
                       UIColor(red: 255/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.00),
                       UIColor(red: 0.77, green: 1.00, blue: 0.00, alpha: 1.00),
                       UIColor(red: 0.96, green: 0.56, blue: 0.00, alpha: 1.00)
                        ]
        
        for i in 0..<ranges.count {
            
            let gradientSegment = TKGaugeSegment(range: ranges[i])
            gradientSegment.fill = TKLinearGradientFill(colors: [colors[i], colors[i + 3]])
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
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.bottomContainerSwipe(swipeGesture:)))
        swipeRightGesture.direction = .right
        bottomContainer.addGestureRecognizer(swipeRightGesture)
        
        let  swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.bottomContainerSwipe(swipeGesture:)))
        swipeLeftGesture.direction = .left
        bottomContainer.addGestureRecognizer(swipeLeftGesture)

    }
    
    func bottomContainerSwipe(swipeGesture: UISwipeGestureRecognizer) {
        changePage(direction: swipeGesture.direction)
    }
    
    @IBAction func bottomContainerPageChange(_ sender: AnyObject) {
        if sender.currentPage > _bottomContainerViewName.rawValue {
            changePage(direction: .left)
        }
        else if sender.currentPage < _bottomContainerViewName.rawValue {
            changePage(direction: .right)
        }
    }
    
    private func changePage(direction: UISwipeGestureRecognizerDirection){
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
