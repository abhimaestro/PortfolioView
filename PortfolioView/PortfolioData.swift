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
    var index1ReturnPercent: Double!
    var index1UnitValue: Double!
    var index2ReturnPercent: Double!
    var index2UnitValue: Double!
    var index3ReturnPercent: Double!
    var index3UnitValue: Double!

    var marketValue: Double!
    
    required init?(map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
        portfolioReturnPercent    <- map["portfolioReturnPercent"]
        portfolioUnitValue    <- map["portfolioUnitValue"]
        index1ReturnPercent <- map["indexReturnPercent"]
        index1UnitValue <- map["indexUnitValue"]
        index2ReturnPercent <- map["indexReturnPercent"]
        index2UnitValue <- map["indexUnitValue"]
        index3ReturnPercent <- map["indexReturnPercent"]
        index3UnitValue <- map["indexUnitValue"]
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
    var index1Name: String!
    var index2Name: String!
    var index3Name: String!
    var totalIndex1ReturnPercent: Double!
    var totalIndex2ReturnPercent: Double!
    var totalIndex3ReturnPercent: Double!
    var totalPortfolioReturnDollar: Double!
    var totalPortfolioMarketValueDollar: Double!
    
    init(portfolioDataItems: [PortfolioDataItem]?) {
        
        if let portfolioDataItems = portfolioDataItems {
            self.portfolioDataItems = portfolioDataItems

            index1Name = "S&P 500"
            index2Name = "Russell 5000"
            index3Name = "Blended Index"

            let startItem = self.portfolioDataItems[0]
            let endItem = self.portfolioDataItems[self.portfolioDataItems.count - 1]
            
            self.totalPortfolioReturnPercent = ((endItem.portfolioUnitValue - startItem.portfolioUnitValue) / startItem.portfolioUnitValue) * 100
            self.totalIndex1ReturnPercent = ((endItem.index1UnitValue - startItem.index1UnitValue) / startItem.index1UnitValue) * 100
            self.totalIndex2ReturnPercent = ((endItem.index2UnitValue - startItem.index2UnitValue) / startItem.index2UnitValue) * 100
            self.totalIndex3ReturnPercent = ((endItem.index3UnitValue - startItem.index3UnitValue) / startItem.index3UnitValue) * 100
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

enum IndexType {
    case Index1
    case Index2
    case Index3
}
enum TrailingPeriod {
    case M1
    case M3
    case Y1
    case Y3
    case Y5
    case All
}
