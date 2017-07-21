//
//  OscilatorData.swift
//  Trade Notify
//
//  Created by Aaron Stein on 6/20/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import Foundation
import RealmSwift


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
