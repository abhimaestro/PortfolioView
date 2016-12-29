//
//  PortfolioReturns.swift
//  PortfolioView
//
//  Created by Abhishek Sharma on 12/27/16.
//  Copyright © 2016 Abhishek Sharma. All rights reserved.
//

import Foundation
import ObjectMapper

public class PortfolioDataItem: Mappable {
    
    public var returnDate: Date!
    public var portfolioReturnPercent: Double!
    public var portfolioUnitValue: Double!
    public var index1ReturnPercent: Double!
    public var index1UnitValue: Double!
    public var index2ReturnPercent: Double!
    public var index2UnitValue: Double!
    public var index3ReturnPercent: Double!
    public var index3UnitValue: Double!
    public var marketValue: Double!
    
    public required init?(map: Map) {
    }
    
    // Mappable
    public func mapping(map: Map) {
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

public class PortfolioData {
    
    public static var portfolioData_1M: PortfolioData?
    public static var portfolioData_3M: PortfolioData?
    public static var portfolioData_1Yr: PortfolioData?
    public static var portfolioData_3Yr: PortfolioData?
    public static var portfolioData_5Yr: PortfolioData?
    public static var portfolioData_All: PortfolioData?
    
    public var portfolioDataItems = [PortfolioDataItem]()
    public var inceptionDate: Date!
    public var endDate: Date!
    public var totalPortfolioReturnPercent: Double!
    public var index1Name: String!
    public var index2Name: String!
    public var index3Name: String!
    public var totalIndex1ReturnPercent: Double!
    public var totalIndex2ReturnPercent: Double!
    public var totalIndex3ReturnPercent: Double!
    public var totalPortfolioReturnDollar: Double!
    public var totalPortfolioMarketValueDollar: Double!
    
    public init(portfolioDataItems: [PortfolioDataItem]?) {
        
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

    public static func load(trailingPeriod: TrailingPeriod = .All) -> PortfolioData? {
        

        
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
    
    public static func getPortfolioDataItems(fileName: String) -> [PortfolioDataItem]? {
        
        let path = Bundle(for: PortfolioData.self).path(forResource: fileName, ofType: "json")!
        
        //print(Bundle.allFrameworks.)
        //let path = Bundle.main.path(forResource: fileName, ofType: "json", inDirectory: "PortfolioViewShared")!
        
        let jsonData = try? String(contentsOfFile: path, encoding: String.Encoding.utf8)
        
        let portfolioDataItems: [PortfolioDataItem]? = Mapper<PortfolioDataItem>().mapArray(JSONString: jsonData!)

        return portfolioDataItems
    }
    
    public static func getAllocations() -> [(name: String, percent: Double, dollar: Double)] {
        return [
            (name: "Equity", percent: 70.0, dollar: 231000.0),
            (name: "Fixed Income", percent: 15.0, dollar: 49500),
            (name:"Alternatives", percent: 10.0, dollar: 33000.0),
            (name: "Cash", percent: 5.0, dollar: 16500)]
    }
}

public enum IndexType {
    case Index1
    case Index2
    case Index3
}

public enum TrailingPeriod : String {
    case M1 = "1M"
    case M3 = "3M"
    case Y1 = "1Yr"
    case Y3 = "3Yr"
    case Y5 = "5Yr"
    case All = "All"
}
