//
//  realmDatabase.swift
//  Trade Notify
//
//  Created by Aaron Stein on 5/20/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import Foundation
import RealmSwift

// MARK: Fetch Methods
func getStock (name: String?) -> Results<Stock>? {

    do {
        let realm = try Realm()
        realm.refresh()
        if name != nil {
            let stock = realm.objects(Stock).filter("name = '\(name!)'")
           // if stock.count > 0 {print("found stocks", stock[0].name, "with listID", stock[0].listID)}
            return stock
        } else {
            //print(realm.objects(Stock))
            return realm.objects(Stock)
        }
    } catch let error as NSError {
        print("getStock failed.", error)
    }
    return nil
}

func getMetrics (name: String?) -> Results<Metrics>? {
    
    do {
        let realm = try Realm()
        if name != nil {
            return realm.objects(Metrics).filter("name = '\(name!)'").sorted("name", ascending: false)
        } else {
            return realm.objects(Metrics)
        }
    } catch let error as NSError {
        print("getStrat failed.", error)
    }
    return nil
}

func getPortData (stock: String?) -> Results<PortData>?
{
    do
    {
        let realm = try Realm()
        if stock != nil {
            return realm.objects(PortData).filter("stock.name = '\(stock!)'").sorted("date", ascending: false)
        } else {
            return realm.objects(PortData)
        }
    }
    catch let error as NSError
    {
        print("getHistData failed.", error)
    }
    return nil
}

//MARK: Delete Methods
func deletePortData (stock: String?)
{
    do
    {
        let realm = try Realm()
        try! realm.write
        {
            if stock != nil
            {
                realm.delete(getPortData(stock)!)
            }
            else
            {
                realm.delete(realm.objects(PortData))
            }
        }
    }
    catch let error as NSError
    {
        print("deletePortData failed.", error)
    }
}

func deleteHistData (stock: Stock?) {
    
    do {
        let realm = try Realm()
        try! realm.write {
            if stock != nil {
                let histData = stock!.histData
                for data in histData
                {
                    realm.delete(data)
                }
                
            } else {
                realm.delete(realm.objects(HistData))
            }
        }
    } catch let error as NSError {
        print("deleteHist failed.", error)
    }
}

func deleteOscData (stock: Stock?) {
    
    do {
        let realm = try Realm()
        try! realm.write {
            if stock != nil {
                let oscData = stock!.oscData
                for data in oscData
                {
                    realm.delete(data)
                }
                
            } else {
                realm.delete(realm.objects(OscData))
            }
        }
    } catch let error as NSError {
        print("deleteOscData failed.", error)
    }
}

func deleteStock (stock: String!) {
    
    do {
        let realm = try Realm()
        try! realm.write {
            realm.delete(getStock(stock)!)
        }
    } catch let error as NSError {
        print("deleteStock failed.", error)
    }
}

func deleteStrat (name: String) {
    
    do {
        let realm = try Realm()
        try! realm.write {
            realm.delete(realm.objects(Strat).filter("name = '\(name)'"))
        }
    } catch let error as NSError {
        print("deleteStrat failed.", error)
    }
}

func deleteMetrics (name: String) {
    
    do {
        let realm = try Realm()
        try! realm.write {
            realm.delete(realm.objects(Metrics).filter("name = '\(name)'"))
        }
    } catch let error as NSError {
        print("deleteStrat failed.", error)
    }
}





















