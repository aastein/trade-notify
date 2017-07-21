//
//  StockClass.swift
//  Trade Notify
//
//  Created by Aaron Stein on 3/25/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import UIKit

class Stock: NSObject, NSCoding {
    
    // MARK: Properties
    var name: String!
    var price: String?
    var strategy: String?
    var url: String?
    var status: String?
    var fourOfour: Bool?
    var isDLHisData: Bool?
    var listID: String!
    var ask: String?
    var bid: String?
    var change: String?
    var pChange: String?
    
    // MARK: Archiving paths
    
    //Stocks
    static let DocumentsDirectoryStocks = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURLStocks = DocumentsDirectoryStocks.URLByAppendingPathComponent("Stocks")
    
    
    // MARK: Types
    struct stockPropertyKey {
        static let nameKey = "name"
        static let priceKey = "price"
        static let strategyKey = "strategy"
        static let urlKey = "url"
        static let statusKey = "status"
        static let fourOfourKey = "fourOfour"
        static let isDLHisDataKey = "isDLHisData"
        static let listIDKey = "ListID"
        static let askKey = "ask"
        static let bidKey = "bid"
        static let changeKey = "change"
        static let pChangeKey = "pChange"

    
    }
    
    // MARK: Initialization
    init?(name: String, price: String?, strategy: String?, url: String?, status: String?, fourOfour: Bool, isDLHisData: Bool, listID: String, ask: String?, bid: String?, change: String?, pChange: String?){
        
        // Initialize store properties
        self.name = name
        self.price = price
        self.strategy = strategy
        self.url = url
        self.status = status
        self.fourOfour = fourOfour
        self.isDLHisData = isDLHisData
        self.listID = listID
        self.ask = ask
        self.bid = bid
        self.change = change
        self.pChange = pChange
        
        super.init()
        
        //Initialization should fail if there is no name
        if name.isEmpty{
            return nil
        }
    }


    //MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: stockPropertyKey.nameKey)
        aCoder.encodeObject(price, forKey: stockPropertyKey.priceKey)
        aCoder.encodeObject(strategy, forKey: stockPropertyKey.strategyKey)
        aCoder.encodeObject(url, forKey: stockPropertyKey.urlKey)
        aCoder.encodeObject(status, forKey: stockPropertyKey.statusKey)
        aCoder.encodeObject(fourOfour, forKey: stockPropertyKey.fourOfourKey)
        aCoder.encodeObject(isDLHisData, forKey: stockPropertyKey.isDLHisDataKey)
        aCoder.encodeObject(listID, forKey: stockPropertyKey.listIDKey)
        aCoder.encodeObject(ask, forKey: stockPropertyKey.askKey)
        aCoder.encodeObject(bid, forKey: stockPropertyKey.bidKey)
        aCoder.encodeObject(change, forKey: stockPropertyKey.changeKey)
        aCoder.encodeObject(pChange, forKey: stockPropertyKey.pChangeKey)
    }

    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey(stockPropertyKey.nameKey) as! String
        let price = aDecoder.decodeObjectForKey(stockPropertyKey.priceKey) as? String
        let strategy = aDecoder.decodeObjectForKey(stockPropertyKey.strategyKey) as? String
        let url = aDecoder.decodeObjectForKey(stockPropertyKey.urlKey) as? String
        let status = aDecoder.decodeObjectForKey(stockPropertyKey.statusKey) as? String
        let fourOfour = aDecoder.decodeObjectForKey(stockPropertyKey.fourOfourKey) as? Bool
        let isDLHisData = aDecoder.decodeObjectForKey(stockPropertyKey.isDLHisDataKey) as? Bool
        let listID = aDecoder.decodeObjectForKey(stockPropertyKey.listIDKey) as? String
        let ask = aDecoder.decodeObjectForKey(stockPropertyKey.askKey) as? String
        let bid = aDecoder.decodeObjectForKey(stockPropertyKey.bidKey) as? String
        let change = aDecoder.decodeObjectForKey(stockPropertyKey.changeKey) as? String
        let pChange = aDecoder.decodeObjectForKey(stockPropertyKey.pChangeKey) as? String
        
        
        
        self.init(name: name, price: price, strategy: strategy, url: url, status: status, fourOfour: fourOfour!, isDLHisData: isDLHisData!, listID: listID!, ask: ask, bid: bid, change: change, pChange: pChange )
    }


}