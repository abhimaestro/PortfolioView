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
    
    init(portfolioDataItems: [PortfolioDataItem]?) {
        
        if let portfolioDataItems = portfolioDataItems {
            self.portfolioDataItems = portfolioDataItems
            
            let startItem = self.portfolioDataItems[0]
            let endItem = self.portfolioDataItems[self.portfolioDataItems.count - 1]
            
            self.totalPortfolioReturnPercent = ((endItem.portfolioUnitValue - startItem.portfolioUnitValue) / startItem.portfolioUnitValue) * 100
            self.totalIndexReturnPercent = ((endItem.indexUnitValue - startItem.indexUnitValue) / startItem.indexUnitValue) * 100

            self.inceptionDate = startItem.returnDate
            self.endDate = endItem.returnDate
        }
    }
    
    static func load(trailingPeriod: TrailingPeriod = .All) -> PortfolioData? {
        
        var fileName = "portfolioData_Inception"
        
        switch trailingPeriod {
        case .M1:
            fileName = "portfolioData_1M"
            break
        case .M3:
            fileName = "portfolioData_3M"
            break
        case .Y1:
            fileName = "portfolioData_1Yr"
            break
        case .Y3:
            fileName = "portfolioData_3Yr"
            break
        case .Y5:
            fileName = "portfolioData_5Yr"
            break
        default:
            fileName = "portfolioData_Inception"
        }
        
        let path = Bundle.main.path(forResource: fileName, ofType: "json")!
    
        let jsonData = try? String(contentsOfFile: path, encoding: String.Encoding.utf8)
        
        let portfolioDataItems: [PortfolioDataItem]? = Mapper<PortfolioDataItem>().mapArray(JSONString: jsonData!)

        return PortfolioData(portfolioDataItems: portfolioDataItems)
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
