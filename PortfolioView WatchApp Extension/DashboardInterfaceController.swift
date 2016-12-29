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
    @IBOutlet var dateRangeLabel: WKInterfaceLabel!
    
    var portfolioData: PortfolioData!
    let titleFont = UIFont.systemFont(ofSize: 7.0, weight: UIFontWeightLight)
    let valueFont = UIFont.systemFont(ofSize: 24.0, weight: UIFontWeightMedium)
    
    override func willActivate() {
        super.willActivate()

        
        let frame = CGRect(0, 0, contentFrame.width, contentFrame.height / 3)
        let chartImage = getChartImage(frame: frame, scale: WKInterfaceDevice.current().screenScale)
        self.chartImageView.setImage(chartImage)
    
        self.setTitle("portfolio value")
    
        portfolioMarketValueTitleLabel.setAttributedText(getAttributedString("current total", font: titleFont))
        netEarningsTitleLabel.setAttributedText(getAttributedString("net earnings", font: titleFont))
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.maximumFractionDigits = 0
        
        let mvCurrency = currencyFormatter.string(from: (portfolioData.totalPortfolioMarketValueDollar as NSNumber))!
        let netEarningsCurrency = currencyFormatter.string(from: (portfolioData.totalPortfolioReturnDollar as NSNumber))!
        
        portfolioMarketValueLabel.setAttributedText(getAttributedString(mvCurrency, font: valueFont))
        netEarningsLabel.setAttributedText(getAttributedString(netEarningsCurrency, font: valueFont))
        
        updateDateRangeLabel(portfolioData)
    }

    func getChartImage(frame: CGRect, scale: CGFloat) -> UIImage {
        let image = YOLineChartImage()
        image.strokeWidth = 1
        image.strokeColor = UIColor(red: 154/255.0, green: 181/255.0, blue: 228/255.0, alpha: 1.00)
        
        portfolioData = PortfolioData.load(trailingPeriod: .All)!
        let marketValues = portfolioData.portfolioDataItems.map({$0.marketValue!})
        image.values = marketValues as [NSNumber]
        image.smooth = false
        return image.draw(frame, scale: scale)
    }
    
    func getAttributedString(_ str: String, font: UIFont, color: UIColor? = nil) -> NSAttributedString {
        let attrString = NSAttributedString(string: str, attributes: [NSFontAttributeName: font])
        return attrString
    }
    
    func updateDateRangeLabel(_ portfolioData: PortfolioData) {
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = .short
        let str = "\(dateformatter.string(from: portfolioData.inceptionDate)) - \(dateformatter.string(from: portfolioData.endDate))"
        dateRangeLabel.setAttributedText(getAttributedString(str, font: titleFont))
    }
}
