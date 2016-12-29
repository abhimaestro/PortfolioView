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
    @IBOutlet var trailing1MButton: WKInterfaceButton!
    @IBOutlet var trailing3MButton: WKInterfaceButton!
    @IBOutlet var trailing1YrButton: WKInterfaceButton!
    @IBOutlet var trailing3YrButton: WKInterfaceButton!
    @IBOutlet var trailingAllButton: WKInterfaceButton!

    var portfolioData: PortfolioData!
    let titleFont = UIFont.systemFont(ofSize: 7.0, weight: UIFontWeightLight)
    let dateRangeFont = UIFont.systemFont(ofSize: 5.0, weight: UIFontWeightThin)
    let buttonFont = UIFont.systemFont(ofSize: 5.0, weight: UIFontWeightLight)
    let buttonSelectedFont = UIFont.systemFont(ofSize: 6.0, weight: UIFontWeightHeavy)
    let valueFont = UIFont.systemFont(ofSize: 16.0, weight: UIFontWeightMedium)
    
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
        netEarningsLabel.setAttributedText(getAttributedString(netEarningsCurrency, font: valueFont, color: getCurrencyColor(value: portfolioData.totalPortfolioReturnDollar)))
        
        updateDateRangeLabel(portfolioData)
        
        //formatTrailingPeriodButtons()
    }

    func formatTrailingPeriodButtons(){
        trailing1MButton.setAttributedTitle(getAttributedString("1M", font: buttonFont))
        trailing3MButton.setAttributedTitle(getAttributedString("3M", font: buttonFont))
        trailing1YrButton.setAttributedTitle(getAttributedString("1Yr", font: buttonFont))
        trailing3YrButton.setAttributedTitle(getAttributedString("3Yr", font: buttonFont))
        trailingAllButton.setAttributedTitle(getAttributedString("All", font: buttonSelectedFont))
    }
    
    func getChartImage(frame: CGRect, scale: CGFloat) -> UIImage {
        
        portfolioData = PortfolioData.load(trailingPeriod: .All)!
        
        let image = YOLineChartImage()
        image.strokeWidth = 1
        image.strokeColor = getCurrencyColor(value: portfolioData.totalPortfolioReturnDollar).withAlphaComponent(0.5)
        

        let marketValues = portfolioData.portfolioDataItems.map({$0.marketValue!})
        image.values = marketValues as [NSNumber]
        image.smooth = false
        return image.draw(frame, scale: scale)
    }
    
    func getAttributedString(_ str: String, font: UIFont, color: UIColor? = nil) -> NSAttributedString {
        
        var attributes: [String : Any] = [NSFontAttributeName: font]
        
        if let color = color {
            attributes[NSForegroundColorAttributeName] = color
        }
        
        let attrString = NSAttributedString(string: str, attributes: attributes)
        return attrString
    }
    
    func updateDateRangeLabel(_ portfolioData: PortfolioData) {
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
