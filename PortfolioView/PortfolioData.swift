//
//  PortfolioReturns.swift
//  PortfolioView
//
//  Created by Abhishek Sharma on 12/27/16.
//  Copyright © 2016 Abhishek Sharma. All rights reserved.
//

import Foundation
import ObjectMapper

class PortfolioDataItem: Mappable {
    
    var returnDate: Date!
    var portfolioReturnPercent: Double!
    var portfolioUnitValue: Double!
    var indexReturnPercent: Double!
    var indexUnitValue: Double!
    var marketValue: Double!
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        portfolioReturnPercent    <- map["portfolioReturnPercent"]
        portfolioUnitValue    <- map["portfolioUnitValue"]
        indexReturnPercent    <- map["indexReturnPercent"]
        indexUnitValue    <- map["indexUnitValue"]
        marketValue    <- map["marketValue"]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        
        if let dateString = map["returnDate"].currentValue as? String, let _date = dateFormatter.date(from: dateString) {
            returnDate = _date
        }
    }
}

class PortfolioData {
    
    var portfolioDataItems = [PortfolioDataItem]()
    var inceptionDate: Date!
    var endDate: Date!
    var totalPortfolioReturnPercent: Double!
    var totalIndexReturnPercent: Double!
    var totalPortfolioReturnDollar: Double!
    var totalPortfolioMarketValueDollar: Double!
    
    init(portfolioDataItems: [PortfolioDataItem]?) {
        
        if let portfolioDataItems = portfolioDataItems {
            self.portfolioDataItems = portfolioDataItems
            
            let startItem = self.portfolioDataItems[0]
            let endItem = self.portfolioDataItems[self.portfolioDataItems.count - 1]
            
            self.totalPortfolioReturnPercent = ((endItem.portfolioUnitValue - startItem.portfolioUnitValue) / startItem.portfolioUnitValue) * 100
            self.totalIndexReturnPercent = ((endItem.indexUnitValue - startItem.indexUnitValue) / startItem.indexUnitValue) * 100
            self.totalPortfolioReturnDollar = (endItem.marketValue - startItem.marketValue)
            self.totalPortfolioMarketValueDollar = endItem.marketValue
            self.inceptionDate = startItem.returnDate
            self.endDate = endItem.returnDate
        }
    }
    
    static var portfolioData_1M: PortfolioData?
    static var portfolioData_3M: PortfolioData?
    static var portfolioData_1Yr: PortfolioData?
    static var portfolioData_3Yr: PortfolioData?
    static var portfolioData_5Yr: PortfolioData?
    static var portfolioData_All: PortfolioData?
    
    static func load(trailingPeriod: TrailingPeriod = .All) -> PortfolioData? {
        

        
        switch trailingPeriod {
        case .M1:
            if portfolioData_1M == nil {
               portfolioData_1M = PortfolioData(portfolioDataItems: getPortfolioDataItems(fileName: "portfolioData_1M"))
            }
            return portfolioData_1M

        case .M3:
            if portfolioData_3M == nil {
                portfolioData_3M = PortfolioData(portfolioDataItems: getPortfolioDataItems(fileName: "portfolioData_3M"))
            }
            return portfolioData_3M

        case .Y1:
            if portfolioData_1Yr == nil {
                portfolioData_1Yr = PortfolioData(portfolioDataItems: getPortfolioDataItems(fileName: "portfolioData_1Yr"))
            }
            return portfolioData_1Yr

        case .Y3:
            if portfolioData_3Yr == nil {
                portfolioData_3Yr = PortfolioData(portfolioDataItems: getPortfolioDataItems(fileName: "portfolioData_3Yr"))
            }
            return portfolioData_3Yr
            
        case .Y5:
            if portfolioData_5Yr == nil {
                portfolioData_5Yr = PortfolioData(portfolioDataItems: getPortfolioDataItems(fileName: "portfolioData_5Yr"))
            }
            return portfolioData_5Yr
            
        default:
            if portfolioData_All == nil {
                portfolioData_All = PortfolioData(portfolioDataItems: getPortfolioDataItems(fileName: "portfolioData_All"))
            }
            return portfolioData_All
        }
    }
    
    static func getPortfolioDataItems(fileName: String) -> [PortfolioDataItem]? {
        
        let path = Bundle.main.path(forResource: fileName, ofType: "json")!
        
        let jsonData = try? String(contentsOfFile: path, encoding: String.Encoding.utf8)
        
        let portfolioDataItems: [PortfolioDataItem]? = Mapper<PortfolioDataItem>().mapArray(JSONString: jsonData!)

        return portfolioDataItems
    }
}

enum TrailingPeriod {
    case M1
    case M3
    case Y1
    case Y3
    case Y5
    case All
}
