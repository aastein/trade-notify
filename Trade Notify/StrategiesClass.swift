//
//  StrategiesClass.swift
//  Trade Notify
//
//  Created by Aaron Stein on 3/26/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import UIKit

class Strategy: NSObject, NSCoding {
    
    // MARK: Properties
    var name: String!
    var smoothK: Int!
    var smoothD: Int!
    var stochLength: Int!
    var rsiLength: Int!
    var overSold: Double!
    var overBought: Double!
    var cciPeriod: Int!
    
    // MARK: Archiving paths

    static let DocumentsDirectoryStrategies = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURLStrategy = DocumentsDirectoryStrategies.URLByAppendingPathComponent("Strategy")
    
    // MARK: Types
    struct strategyPropertyKey {
        static let nameKey = "name"
        static let smoothKKey = "smoothK"
        static let smoothDKey = "smoothD"
        static let stochLengthKey = "stochLength"
        static let rsiLengthKey = "rsiLength"
        static let overSoldKey = "overSold"
        static let overBoughtKey = "overBought"
        static let cciPeriodKey = "cciPeriod"
    }
    
    
    //Initialization
    
    init?(name: String, smoothK: Int, smoothD: Int, stochLength: Int, rsiLength: Int, overSold: Double, overBought: Double, cciPeriod: Int){
        
        self.name = name
        self.smoothK = smoothK
        self.smoothD = smoothD
        self.stochLength = stochLength
        self.rsiLength = rsiLength
        self.overSold = overSold
        self.overBought = overBought
        self.cciPeriod = cciPeriod
        
        super.init()
        
        if name.isEmpty || smoothK < 1 || smoothD < 1 || stochLength < 1 || rsiLength < 1 || cciPeriod < 1 {
            return nil
        }
    }

    
    //MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(name, forKey: strategyPropertyKey.nameKey)
        aCoder.encodeObject(smoothK, forKey: strategyPropertyKey.smoothKKey)
        aCoder.encodeObject(smoothD, forKey: strategyPropertyKey.smoothDKey)
        aCoder.encodeObject(stochLength, forKey: strategyPropertyKey.stochLengthKey)
        aCoder.encodeObject(rsiLength, forKey: strategyPropertyKey.rsiLengthKey)
        aCoder.encodeObject(overSold, forKey: strategyPropertyKey.overSoldKey)
        aCoder.encodeObject(overBought, forKey: strategyPropertyKey.overBoughtKey)
        aCoder.encodeObject(cciPeriod, forKey: strategyPropertyKey.cciPeriodKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        let name = aDecoder.decodeObjectForKey(strategyPropertyKey.nameKey) as! String
        let smoothK = aDecoder.decodeObjectForKey(strategyPropertyKey.smoothKKey) as! Int
        let smoothD = aDecoder.decodeObjectForKey(strategyPropertyKey.smoothDKey) as! Int
        let stochLength = aDecoder.decodeObjectForKey(strategyPropertyKey.stochLengthKey) as! Int
        let rsiLength = aDecoder.decodeObjectForKey(strategyPropertyKey.rsiLengthKey) as! Int
        let overSold = aDecoder.decodeObjectForKey(strategyPropertyKey.overSoldKey) as! Double
        let overBought = aDecoder.decodeObjectForKey(strategyPropertyKey.overBoughtKey) as! Double
        let cciPeriod = aDecoder.decodeObjectForKey(strategyPropertyKey.cciPeriodKey) as! Int
        
        self.init(name: name, smoothK: smoothK, smoothD: smoothD, stochLength: stochLength, rsiLength: rsiLength, overSold: overSold, overBought: overBought, cciPeriod: cciPeriod)
    }

    
    
    
}