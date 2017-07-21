//
//  Stock.swift
//  Trade Notify
//
//  Created by Aaron Stein on 6/20/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import Foundation
import RealmSwift

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