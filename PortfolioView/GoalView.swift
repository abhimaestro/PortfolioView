//
//  GoalView.swift
//  PortfolioView
//
//  Created by Abhishek Sharma on 1/3/17.
//  Copyright © 2017 Abhishek Sharma. All rights reserved.
//

import UIKit
import PortfolioViewShared

class GoalView: UIView {

    @IBOutlet weak var goalDialContainer: UIView!
    @IBOutlet weak var goalAccumulationContainer: UIView!
    @IBOutlet weak var goalAsOfDate: UILabel!

    let radialGauge = TKRadialGauge()
    let linearGauge = TKLinearGauge()
    
    class func load(goalInfo: GoalInfo, container: UIView) -> GoalView {
        
        var xibView = Bundle.main.loadNibNamed("GoalView", owner: self, options: nil)
        let goalView = xibView?[0] as! GoalView
        
        goalView.frame = CGRect(0, 0, container.frame.width, container.frame.height)
        goalView.initializeGoalChart(goalInfo)
        goalView.initializeGoalAccumulation(goalInfo)
        
        container.addSubview(goalView)
        container.sendSubview(toBack: goalView)
        return goalView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = goalDialContainer.bounds
        let size = self.bounds.size
        let offset = CGFloat(10)
        
        radialGauge.frame = CGRect(x: offset, y: bounds.origin.y + 2*offset, width: size.width - 2*offset, height: size.height)
        
        linearGauge.frame = CGRect(x: offset, y: goalAccumulationContainer.bounds.origin.y - 5, width: goalAccumulationContainer.bounds.size.width - 2*offset, height: goalAccumulationContainer.bounds.size.height)
        
        let needle = radialGauge.scales[0].indicators[0] as! TKGaugeNeedle
        needle.setValueAnimated(80, withDuration: 1.5, mediaTimingFunction: kCAMediaTimingFunctionEaseInEaseOut)
    }
    
    func initializeGoalChart(_ goalInfo: GoalInfo) {
        
        goalAsOfDate.text = String("as of: \(goalInfo.goalAsOfDate.toShortDateString())")
        
        radialGauge.labelTitleOffset = CGPoint(x: radialGauge.labelTitle.bounds.origin.x, y: radialGauge.labelTitle.bounds.origin.y - 60)
        radialGauge.labelTitle.text = goalInfo.probability.toPercent()
        radialGauge.labelSubtitle.text = goalInfo.probability < 70 ? "off track" : "on track"
        radialGauge.labelTitle.font = FontHelper.getDefaultFont(size: 20.0)
        
        goalDialContainer.addSubview(radialGauge)
        goalDialContainer.bringSubview(toFront: radialGauge)
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
    
    func initializeGoalAccumulation(_ goalInfo: GoalInfo) {
        
        goalAccumulationContainer.addSubview(self.linearGauge)
        
        let scale1 = TKGaugeLinearScale(minimum: goalInfo.retiremenGoal.startYear, maximum: goalInfo.retiremenGoal.retirementYear)
        scale1.ticks.position = TKGaugeTicksPosition.inner
        self.linearGauge.addScale(scale1)
        
        let completedSegment = TKGaugeSegment(minimum: goalInfo.retiremenGoal.startYear, maximum: goalInfo.retiremenGoal.asOfYear)
        completedSegment.width = 0.08
        completedSegment.width2 = 0.08
        completedSegment.location = 0.62
        completedSegment.fill = TKSolidFill(color:  UIColor(red: 0.38, green: 0.73, blue: 0.00, alpha: 1.00))
        scale1.addSegment(completedSegment)
        
        let scale2 = TKGaugeLinearScale(minimum: goalInfo.retiremenGoal.marketValueStart, maximum: goalInfo.retiremenGoal.marketValueRetirement)
        self.linearGauge.addScale(scale2)
        
        scale2.ticks.position = TKGaugeTicksPosition.outer
        scale2.ticks.majorTicksCount = 3
        scale2.ticks.minorTicksCount = 0
        scale2.labels.position = TKGaugeLabelsPosition.outer
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.maximumFractionDigits = 0
        scale2.labels.formatter = currencyFormatter
        scale2.labels.count = 2
        scale2.labels.font = FontHelper.getDefaultFont(size: 8, light: true)
        for i in 0..<self.linearGauge.scales.count {
            let s = self.linearGauge.scales[i] as! TKGaugeLinearScale
            s.stroke = TKStroke(color:UIColor.gray, width:2)
            s.ticks.majorTicksStroke = TKStroke(color:UIColor.gray, width:1)
            s.labels.color = UIColor.gray
            s.ticks.offset = 0
            s.offset = CGFloat(i)*0.12 + 0.60
            s.ticks.minorTicksLength = 0
        }
        
        //remove trial label
        linearGauge.subviews[linearGauge.subviews.count - 1].removeFromSuperview()
    }

}
