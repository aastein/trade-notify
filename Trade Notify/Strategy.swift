//
//  Strategy.swift
//  Trade Notify
//
//  Created by Aaron Stein on 6/20/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import Foundation
import RealmSwift

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
