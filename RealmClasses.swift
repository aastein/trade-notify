//
//  realmClasses.swift
//  Trade Notify
//
//  Created by Aaron Stein on 5/20/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import Foundation
import RealmSwift


class PortData: Object
{
    dynamic var date: NSDate = NSDate()
    dynamic var value: Double = 0.0
    dynamic var shares: Int = 0
    dynamic var stock: Stock?
    dynamic var action = ""
    
    func save()
    {
        do
        {
            let realm = try Realm()
            try! realm.write
            {
                realm.add(self)
            }
        }
        catch let error as NSError
        {
            print("Save PortData Failed.", error)
        }
    }
    
}

class HistData: Object
{
    dynamic var adjClose: Double = 0.0
    dynamic var close: Double = 0.0
    dynamic var date: NSDate = NSDate()
    dynamic var high: Double = 0.0
    dynamic var low: Double = 0.0
    dynamic var open: Double = 0.0
    dynamic var stock: Stock?
    dynamic var volume: Double = 0.0
    dynamic var pk = ""
    
    override static func primaryKey() -> String?
    {
        return "pk"
    }
    
    func saveOnMainThread(stockName: String){
        dispatch_async(dispatch_get_main_queue()) {
       //     self.save(stockName)
        }
    }
    
    func save()
    {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "M/d/yy"
        
        do
        {
            let realm = try Realm()
            realm.refresh()
            try! realm.write
            {
                let fDate = formatter.stringFromDate(self.date)
                self.pk = self.stock!.name + fDate
                print("saving histData with pk = ", self.pk)
                realm.add(self, update: true)
            }
        } catch let error as NSError {
            print("saveStrat failed.", error)
        }
    }
}

class OscData: Object
{    
    dynamic var avgDown: Double = 0.0
    dynamic var avgUp: Double = 0.0
    dynamic var cci: Double = 0.0
    dynamic var d: Double = 0.0
    dynamic var date: NSDate = NSDate()
    dynamic var down: Double = 0.0
    dynamic var k: Double = 0.0
    dynamic var pt: Double = 0.0
    dynamic var rs: Double = 0.0
    dynamic var rsi: Double = 0.0
    dynamic var stoch: Double = 0.0
    dynamic var stock: Stock?
    dynamic var up: Double = 0.0
    dynamic var status = ""
    dynamic var pk = ""
    
    override static func primaryKey() -> String?
    {
        return "pk"
    }
    
    func save()
    {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "M/d/yy"
        
        do
        {
            let realm = try Realm()
            try! realm.write
            {
                if self.pk == ""
                {
                    let fDate = formatter.stringFromDate(self.date)
                    self.pk = self.stock!.name + fDate
                }
                realm.add(self, update: true)
            }
        }
        catch let error as NSError
        {
            print("saveStrat failed.", error)
        }
    }
}

class Stock: Object
{
    dynamic var k: Double = -1.0
    dynamic var d: Double = -1.0
    dynamic var cci: Double = -1.0
    dynamic var ask: Double = -1.0
    dynamic var bid: Double = -1.0
    dynamic var change: Double = -1.0
    dynamic var listID = ""
    dynamic var name = ""
    dynamic var upated = NSDate(timeIntervalSinceReferenceDate: 0)
    dynamic var pChange = ""
    dynamic var price: Double = -1.0
    dynamic var sellPrice: Double = -1.0
    dynamic var buyPrice: Double = -1.0
    dynamic var status = ""
    dynamic var lastStatus = ""
    dynamic var hasData: Bool = false
    dynamic var progress = Float(0)
    dynamic var score = Double(0)
    let strategy = LinkingObjects(fromType: Strat.self, property: "stock")
    let oscData = LinkingObjects(fromType: OscData.self, property: "stock")
    let histData = LinkingObjects(fromType: HistData.self, property: "stock")
    
    override static func primaryKey() -> String?
    {
        return "name"
    }
    
    func saveOnMainThread (type: String)
    {
        dispatch_async(dispatch_get_main_queue())
        {
            self.save()
        }
    }
    
    func save() -> Stock?
    {
        do
        {
            let realm = try Realm()
            realm.refresh()
            try! realm.write
                {
                    realm.add(self, update: true)
            }
            return self
        } catch let error as NSError {
            print("saveStock failed.", error)
        }
        return nil
    }
    
    func updateQuote(price: Double, bid: Double, ask: Double, change: Double, pChange: String, updated: NSDate)
    {
        do
        {
            let realm = try Realm()
            realm.refresh()
            try! realm.write
            {
                self.price = price
                self.bid = bid
                self.ask = ask
                self.change = change
                self.pChange = pChange
                self.upated = updated
                realm.add(self, update: true)
            }
        }
        catch let error as NSError
        {
            print("stock.updateQuote failed.", error)
        }
    }
    
    func updateProgress(progress: Float)
    {
        do
        {
            let realm = try Realm()
            realm.refresh()
            try! realm.write
                {
                    self.progress = progress
                    realm.add(self, update: true)
            }
        }
        catch let error as NSError
        {
            print("stock.updateQuote failed.", error)
        }
    }
    
    func updateScore(score: Double)
    {
        do
        {
            let realm = try Realm()
            realm.refresh()
            try! realm.write
                {
                    self.score = score
                    realm.add(self, update: true)
            }
        }
        catch let error as NSError
        {
            print("stock.updateQuote failed.", error)
        }
    }
    
    func updateListID(listID: String)
    {
        do
        {
            let realm = try Realm()
            realm.refresh()
            try! realm.write
                {
                    self.listID = listID
                    realm.add(self, update: true)
            }
        }
        catch let error as NSError
        {
            print("stock.updateQuote failed.", error)
        }
    }
    
    func updateStatus(status: String, lastStatus: String, k: Double, d: Double, cci: Double)
    {
        do
        {
            let realm = try Realm()
            realm.refresh()
            try! realm.write
                {
                    self.status = status
                    self.lastStatus = lastStatus
                    self.k = k
                    self.d = d
                    self.cci = cci
                    self.hasData = true
                    self.progress = 1
                    realm.add(self, update: true)
            }
        }
        catch let error as NSError
        {
            print("stock.updateQuote failed.", error)
        }
    }

}

class Strat: Object {
    
    dynamic var cciLength: Int = 0
    dynamic var cciMax: Double = 0.0
    dynamic var cciMin: Double = 0.0
    dynamic var d: Int = 0
    dynamic var k: Int = 0
    dynamic var name = ""
    dynamic var rsiLength: Int = 0
    dynamic var rsiMax: Double = 0.0
    dynamic var rsiMin: Double = 0.0
    dynamic var stochLength: Int = 0
    dynamic var stochMax: Double = 0.0
    dynamic var stochMin: Double = 0.0
    dynamic var stock: Stock?
    let metrics = LinkingObjects(fromType: Metrics.self, property: "strat")
    
    override static func primaryKey() -> String?
    {
        return "name"
    }
    
    func saveOnMainThread ()
    {
        dispatch_async(dispatch_get_main_queue())
        {
            self.save()
        }
    }
    
    func save()
    {
        do
        {
            let realm = try Realm()
            try! realm.write
            {
                realm.add(self, update: true)
            }
        }
        catch let error as NSError
        {
            print("saveStrat failed.", error)
        }
    }

}

class Metrics: Object
{
    dynamic var name = ""
    dynamic var percentProfitable: Double = 0.0
    dynamic var totalReturn: Double = 0.0
    dynamic var totalReturnPercent: Double = 0.0
    dynamic var avgTrade: Double = 0.0
    dynamic var avgTradePercent: Double = 0.0
    dynamic var totalTrades: Int = 0
    dynamic var score: Double = DBL_MAX * -1
    dynamic var avgDaysPerTrade: Double = 0
    dynamic var strat: Strat?
    
    override static func primaryKey() -> String?
    {
        return "name"
    }
    
    func saveOnMainThread ()
    {
        dispatch_async(dispatch_get_main_queue())
        {
            self.save()
        }
    }
    
    func save() -> Metrics?
    {
        do {
            let realm = try Realm()
            realm.refresh()
            try! realm.write {
                realm.add(self, update: true)
            }
            return self
        } catch let error as NSError {
            print("Save Metrics failed.", error)
        }
        return nil
    }
}
