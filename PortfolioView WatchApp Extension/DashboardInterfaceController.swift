//
//  DashboardInterfaceController.swift
//  PortfolioView
//
//  Created by Abhishek Sharma on 12/29/16.
//  Copyright © 2016 Abhishek Sharma. All rights reserved.
//

import WatchKit
import Foundation
import YOChartImageKit
import PortfolioViewShared
import WatchConnectivity

class DashboardInterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet weak var chartImageView: WKInterfaceImage!
    @IBOutlet var portfolioMarketValueTitleLabel: WKInterfaceLabel!
    @IBOutlet var portfolioMarketValueLabel: WKInterfaceLabel!
    @IBOutlet var netEarningsTitleLabel: WKInterfaceLabel!
    @IBOutlet var netEarningsLabel: WKInterfaceLabel!
    @IBOutlet var totalReturnTitleLabel: WKInterfaceLabel!
    @IBOutlet var totalReturnLabel: WKInterfaceLabel!
    
    @IBOutlet var dateRangeLabel: WKInterfaceLabel!
    @IBOutlet var trailing1MButton: WKInterfaceButton!
    @IBOutlet var trailing3MButton: WKInterfaceButton!
    @IBOutlet var trailing1YrButton: WKInterfaceButton!

    var portfolioData: PortfolioData!
    let buttonFont = UIFont.systemFont(ofSize: 16.0, weight: UIFontWeightLight)
    let buttonSelectedFont = UIFont.systemFont(ofSize: 16.0, weight: UIFontWeightHeavy)
    let valueFont = UIFont.systemFont(ofSize: 24.0, weight: UIFontWeightMedium)
    let value2Font = UIFont.systemFont(ofSize: 16.0, weight: UIFontWeightMedium)
    let session = WCSession.default()
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        updateForTrailing3M()
        session.delegate = self
        session.activate()
    }
    
    override func willActivate() {
        super.willActivate()
    }

    @IBAction func updateForTrailing1M() {
        updateFor(trailingPeriod: .M1, button: trailing1MButton)
    }

    
    @IBAction func updateForTrailing3M() {
        updateFor(trailingPeriod: .M3, button: trailing3MButton)
    }
    
    @IBAction func updateForTrailing1Yr() {
        updateFor(trailingPeriod: .Y1, button: trailing1YrButton)
    }
   
    func updateFor(trailingPeriod: TrailingPeriod, button: WKInterfaceButton) {
        resetTrailingPeriodButtons()
        setButtonText(button, text: trailingPeriod.rawValue, isSelected: true)
        
        updateChart(trailingPeriod: trailingPeriod)
        updateEarnings()
        updateTotalReturn()
        updateMarketValue()
        updateDateRangeLabel()
    }
    
    func resetTrailingPeriodButtons() {
        setButtonText(trailing1MButton, text: TrailingPeriod.M1.rawValue)
        setButtonText(trailing3MButton, text: TrailingPeriod.M3.rawValue)
        setButtonText(trailing1YrButton, text: TrailingPeriod.Y1.rawValue)
    }
    
    func setButtonText(_ button: WKInterfaceButton, text: String, isSelected: Bool = false) {
        
        if !isSelected {
            button.setAttributedTitle(text.toAttributed(font: buttonFont, color: UIColor.lightGray))
        }
        else {
            button.setAttributedTitle(text.toAttributed(font: buttonSelectedFont, color: UIColor.lightGray))
        }
    }
    
    func updateMarketValue() {
        portfolioMarketValueLabel.setAttributedText(portfolioData.totalPortfolioMarketValueDollar.toCurrency().toAttributed(font: valueFont))
    }
    
    func updateEarnings() {
        netEarningsLabel.setAttributedText(portfolioData.totalPortfolioReturnDollar.toCurrency().toAttributed(font: value2Font, color: Color.getValueColor(value: portfolioData.totalPortfolioReturnDollar)))
    }
    
    func updateTotalReturn() {
        totalReturnLabel.setAttributedText(portfolioData.totalPortfolioReturnPercent.toPercent(noOfDecimals: 1).toAttributed(font: value2Font, color: Color.getValueColor(value: portfolioData.totalPortfolioReturnDollar)))
    }
    
    func updateChart(trailingPeriod: TrailingPeriod) {
        
        let currentDevice = WKInterfaceDevice.current()
        
        let imageHeight = currentDevice.getWatchSize() == .large ? contentFrame.height / 3 : contentFrame.height / 4
        let frame = CGRect(0, 0, contentFrame.width, imageHeight)
        let scale = currentDevice.screenScale
        
        portfolioData = PortfolioData.load(trailingPeriod: trailingPeriod)!
        
        let image = YOLineChartImage()
        image.strokeWidth = 1
        image.strokeColor = Color.getValueColor(value: portfolioData.totalPortfolioReturnDollar)
        
        image.values = portfolioData.portfolioDataItems.map({$0.marketValue as NSNumber})
        image.smooth = false
        let chartImage = image.draw(frame, scale: scale)
        
        self.chartImageView.setImage(chartImage)
    }
    
    func updateDateRangeLabel() {
        dateRangeLabel.setText("\(portfolioData.inceptionDate.toShortDateString()) - \(portfolioData.endDate.toShortDateString())")
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        
        guard let isUserLoggedIn = applicationContext["isUserLoggedIn"] as? Bool else { return }
        
        if !isUserLoggedIn  {
            WKInterfaceController.reloadRootControllers(withNames: ["stagingIC"], contexts: nil)
        }
    }
}
