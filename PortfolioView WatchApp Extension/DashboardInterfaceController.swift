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

class DashboardInterfaceController: WKInterfaceController {

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
    @IBOutlet var trailing3YrButton: WKInterfaceButton!
    @IBOutlet var trailingAllButton: WKInterfaceButton!

    var portfolioData: PortfolioData!
    let titleFont = UIFont.systemFont(ofSize: 7.0, weight: UIFontWeightLight)
    let dateRangeFont = UIFont.italicSystemFont(ofSize: 5.0)
    let buttonFont = UIFont.systemFont(ofSize: 7.0, weight: UIFontWeightLight)
    let buttonSelectedFont = UIFont.systemFont(ofSize: 7.0, weight: UIFontWeightHeavy)
    let valueFont = UIFont.systemFont(ofSize: 16.0, weight: UIFontWeightMedium)
    let value2Font = UIFont.systemFont(ofSize: 11.0, weight: UIFontWeightMedium)
    
    override func willActivate() {
        super.willActivate()
        
        self.setTitle("summary")
        portfolioMarketValueTitleLabel.setAttributedText(getAttributedString("market value", font: titleFont))
        netEarningsTitleLabel.setAttributedText(getAttributedString("earnings", font: titleFont))
        totalReturnTitleLabel.setAttributedText(getAttributedString("return", font: titleFont))
        
        updateForTrailingAll()
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
    
    @IBAction func updateForTrailing3Yr() {
        updateFor(trailingPeriod: .Y3, button: trailing3YrButton)
    }
    
    @IBAction func updateForTrailingAll() {
        updateFor(trailingPeriod: .All, button: trailingAllButton)
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
        setButtonText(trailing3YrButton, text: TrailingPeriod.Y3.rawValue)
        setButtonText(trailingAllButton, text: TrailingPeriod.All.rawValue)
    }
    
    func setButtonText(_ button: WKInterfaceButton, text: String, isSelected: Bool = false) {
        
        if !isSelected {
            button.setAttributedTitle(getAttributedString(text, font: buttonFont, color: UIColor.lightGray))
        }
        else {
            button.setAttributedTitle(getAttributedString(text, font: buttonSelectedFont, color: UIColor.lightGray))
        }
    }
    
    func updateMarketValue() {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.maximumFractionDigits = 0
        let mvCurrency = currencyFormatter.string(from: (portfolioData.totalPortfolioMarketValueDollar as NSNumber))!
        portfolioMarketValueLabel.setAttributedText(getAttributedString(mvCurrency, font: valueFont))
    }
    
    func updateEarnings() {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.maximumFractionDigits = 0
        
        let netEarningsCurrency = currencyFormatter.string(from: (portfolioData.totalPortfolioReturnDollar as NSNumber))!
        netEarningsLabel.setAttributedText(getAttributedString(netEarningsCurrency, font: value2Font, color: getCurrencyColor(value: portfolioData.totalPortfolioReturnDollar)))
    }
    
    func updateTotalReturn() {
        let str = String(format: "%.1f%%", portfolioData.totalPortfolioReturnPercent)
        totalReturnLabel.setAttributedText(getAttributedString(str, font: value2Font, color: getCurrencyColor(value: portfolioData.totalPortfolioReturnDollar)))
    }
    
    func updateChart(trailingPeriod: TrailingPeriod) {
        
        let frame = CGRect(0, 0, contentFrame.width, contentFrame.height / 3)
        let scale = WKInterfaceDevice.current().screenScale
        
        portfolioData = PortfolioData.load(trailingPeriod: trailingPeriod)!
        
        let image = YOLineChartImage()
        image.strokeWidth = 1
        image.strokeColor = getCurrencyColor(value: portfolioData.totalPortfolioReturnDollar).withAlphaComponent(0.5)
        

        let marketValues = portfolioData.portfolioDataItems.map({$0.marketValue!})
        image.values = marketValues as [NSNumber]
        image.smooth = false
        let chartImage = image.draw(frame, scale: scale)
        
        self.chartImageView.setImage(chartImage)
    }
    
    func getAttributedString(_ str: String, font: UIFont, color: UIColor? = nil) -> NSAttributedString {
        
        var attributes: [String : Any] = [NSFontAttributeName: font]
        
        if let color = color {
            attributes[NSForegroundColorAttributeName] = color
        }
        
        let attrString = NSAttributedString(string: str, attributes: attributes)
        return attrString
    }
    
    func updateDateRangeLabel() {
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = .short
        let str = "\(dateformatter.string(from: portfolioData.inceptionDate)) - \(dateformatter.string(from: portfolioData.endDate))"
        dateRangeLabel.setAttributedText(getAttributedString(str, font: dateRangeFont))
    }
    
    func getCurrencyColor(value: Double) -> UIColor {
        if value < 0 {
            return UIColor(red: 98/255.0, green: 32/255.0, blue: 32/255.0, alpha: 1.0)
        }
        else {
            return UIColor(red: 30/255.0, green: 116/255.0, blue: 0/255.0, alpha: 1.0)
        }
    }
}
