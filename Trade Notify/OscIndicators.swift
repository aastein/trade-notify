//
//  OscIndicators.swift
//  Trade Notify
//
//  Created by Aaron Stein on 4/10/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import UIKit

class OscIndicators: NSObject, NSCoding{
    
    var date: NSString
    var up: Double
    var down: Double
    var avgUp: Double
    var avgDown: Double
    var RS: Double
    var RSI: Double
    var stoch: Double
    var K: Double
    var D: Double
    var pt: Double
    var CCI: Double

    
    struct oscIndPropertyKey {
        static let dateKey = "date"
        static let upKey = "up"
        static let downKey = "down"
        static let avgUpKey = "avgUp"
        static let avgDownKey = "avgDown"
        static let RSKey = "RS"
        static let RSIKey = "RSI"
        static let stochKey = "stoch"
        static let KKey = "K"
        static let DKey = "D"
        static let ptKey = "pt"
        static let CCIKey = "CCI"
    }

    init?(date: NSString, up: Double, down: Double, avgUp: Double, avgDown: Double, RS: Double, RSI: Double, stoch: Double, K: Double, D: Double, pt: Double, CCI: Double){
        
        self.date = date
        self.up = up
        self.down = down
        self.avgUp = avgUp
        self.avgDown = avgDown
        self.RS = RS
        self.RSI = RSI
        self.stoch = stoch
        self.K = K
        self.D = D
        self.pt = pt
        self.CCI = CCI
        
        super.init()
    }
    
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(date, forKey: oscIndPropertyKey.dateKey)
        aCoder.encodeObject(up, forKey: oscIndPropertyKey.upKey)
        aCoder.encodeObject(down, forKey: oscIndPropertyKey.downKey)
        aCoder.encodeObject(avgUp, forKey: oscIndPropertyKey.avgUpKey)
        aCoder.encodeObject(avgDown, forKey: oscIndPropertyKey.avgDownKey)
        aCoder.encodeObject(RS, forKey: oscIndPropertyKey.RSKey)
        aCoder.encodeObject(RSI, forKey: oscIndPropertyKey.RSIKey)
        aCoder.encodeObject(stoch, forKey: oscIndPropertyKey.stochKey)
        aCoder.encodeObject(K, forKey: oscIndPropertyKey.KKey)
        aCoder.encodeObject(D, forKey: oscIndPropertyKey.DKey)
        aCoder.encodeObject(pt, forKey: oscIndPropertyKey.ptKey)
        aCoder.encodeObject(CCI, forKey: oscIndPropertyKey.CCIKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let date = aDecoder.decodeObjectForKey(oscIndPropertyKey.dateKey) as! NSString
        let up = aDecoder.decodeObjectForKey(oscIndPropertyKey.upKey) as! Double
        let down = aDecoder.decodeObjectForKey(oscIndPropertyKey.downKey) as! Double
        let avgUp = aDecoder.decodeObjectForKey(oscIndPropertyKey.avgUpKey) as! Double
        let avgDown = aDecoder.decodeObjectForKey(oscIndPropertyKey.avgDownKey) as! Double
        let RS = aDecoder.decodeObjectForKey(oscIndPropertyKey.RSKey) as! Double
        let RSI = aDecoder.decodeObjectForKey(oscIndPropertyKey.RSIKey) as! Double
        let stoch = aDecoder.decodeObjectForKey(oscIndPropertyKey.stochKey) as! Double
        let K = aDecoder.decodeObjectForKey(oscIndPropertyKey.KKey) as! Double
        let D = aDecoder.decodeObjectForKey(oscIndPropertyKey.DKey) as! Double
        let pt = aDecoder.decodeObjectForKey(oscIndPropertyKey.ptKey) as! Double
        let CCI = aDecoder.decodeObjectForKey(oscIndPropertyKey.CCIKey) as! Double
        self.init(date: date, up: up, down: down, avgUp: avgUp, avgDown: avgDown, RS: RS, RSI: RSI, stoch: stoch, K: K, D: D, pt: pt, CCI: CCI)
    }
    
    
}

