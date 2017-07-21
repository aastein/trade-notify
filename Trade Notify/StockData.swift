//
//  StockDataClass.swift
//  Trade Notify
//
//  Created by Aaron Stein on 4/25/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import UIKit

class StockData: NSObject, NSCoding {
    
    // MARK: Properties
    var name: String!
    var histData: [HistDataPoint]?
    var oscInds: [OscIndicators]?
    
    // MARK: Archiving paths
    
    //Stocks
    static let DocumentsDirectoryStockData = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURLStockData = DocumentsDirectoryStockData.URLByAppendingPathComponent("StockData")
    
    
    // MARK: Types
    struct stockDataPropertyKey {
        static let nameKey = "name"
        static let histDataKey = "histData"
        static let oscIndsKey = "oscInds"
        
    }
    
    // MARK: Initialization
    init?(name: String, histData: [HistDataPoint]?, oscInds: [OscIndicators]?){
        
        // Initialize store properties
        self.name = name
        self.histData = histData
        self.oscInds = oscInds
        
        super.init()
        
        //Initialization should fail if there is no name
        if name.isEmpty{
            return nil
        }
    }
    
    
    //MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: stockDataPropertyKey.nameKey)
        aCoder.encodeObject(histData, forKey: stockDataPropertyKey.histDataKey)
        aCoder.encodeObject(oscInds, forKey: stockDataPropertyKey.oscIndsKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey(stockDataPropertyKey.nameKey) as! String
        let histData = aDecoder.decodeObjectForKey(stockDataPropertyKey.histDataKey) as? [HistDataPoint]
        let oscInds = aDecoder.decodeObjectForKey(stockDataPropertyKey.oscIndsKey) as? [OscIndicators]

        self.init(name: name, histData: histData, oscInds: oscInds)
    }
    
    
}
