//
//  HistDataClass.swift
//  Littlejohn
//
//  Created by Aaron Stein on 5/1/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import Foundation
import RealmSwift

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
                    //print("saving histData with pk = ", self.pk)
                    realm.add(self, update: true)
            }
        } catch let error as NSError {
            print("saveStrat failed.", error)
        }
    }
}