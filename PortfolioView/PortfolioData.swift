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
    
    init(portfolioDataItems: [PortfolioDataItem]?) {
        
        if let portfolioDataItems = portfolioDataItems {
            self.portfolioDataItems = portfolioDataItems
            
            self.inceptionDate = self.portfolioDataItems[0].returnDate
            self.endDate = self.portfolioDataItems[self.portfolioDataItems.count - 1].returnDate
        }
    }
    
    static func load() -> PortfolioData? {
        
        let path = Bundle.main.path(forResource: "portfolioData_Inception", ofType: "json")!
    
        let jsonData = try? String(contentsOfFile: path, encoding: String.Encoding.utf8)

        let mapper = Mapper<PortfolioDataItem>()
        
        let portfolioDataItems: [PortfolioDataItem]? = Mapper<PortfolioDataItem>().mapArray(JSONString: jsonData!)

        return PortfolioData(portfolioDataItems: portfolioDataItems)
        
    }
}
