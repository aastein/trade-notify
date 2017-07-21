//
//  PortfolioPerformanceData.swift
//  Trade Notify
//
//  Created by Aaron Stein on 6/20/16.
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