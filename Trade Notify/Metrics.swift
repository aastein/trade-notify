//
//  Metrics.swift
//  Trade Notify
//
//  Created by Aaron Stein on 6/20/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import Foundation
import RealmSwift

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