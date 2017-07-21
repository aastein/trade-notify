//
//  Database.swift
//  Littlejohn
//
//  Created by Aaron Stein on 5/1/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import UIKit
import CoreData


// MARK: Save Methods

var managedContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)

func initManagedContext(setManagedContext: NSManagedObjectContext) {
    managedContext = setManagedContext
}

func saveStock(stockName: String, strategy: String?, listID: String?, status: String?, price: Double?, bid: Double?, ask: Double?, change: Double?, pChange: String?, fourOfour: Bool?) -> NSManagedObject? {

    let entity = NSEntityDescription.entityForName("StockCore", inManagedObjectContext: managedContext)
    let stock = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
    
    stock.setValue(stockName, forKey: "name")
    stock.setValue(strategy, forKey: "strategy")
    stock.setValue(listID, forKey: "listID")
    stock.setValue(status, forKey: "status")
    stock.setValue(price, forKey: "price")
    stock.setValue(bid, forKey: "bid")
    stock.setValue(ask, forKey: "ask")
    stock.setValue(change, forKey: "change")
    stock.setValue(pChange, forKey: "pChange")
    stock.setValue(fourOfour, forKey: "fourOfour")
    
    managedContext.performBlockAndWait{ () -> Void in
        
        do {
            try managedContext.save()
            print("stock \(stockName) saved to CoreData")
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    return stock
}

func saveHistData(stockName: String, date: NSDate, open: Double, high: Double, low: Double, close: Double, volume: Double, adjClose: Double) -> (NSManagedObjectContext) {
    
    let entity = NSEntityDescription.entityForName("HistDataCore", inManagedObjectContext: managedContext)
    let dataPoint = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
    
    dataPoint.setValue(adjClose, forKey: "adjClose")
    dataPoint.setValue(close, forKey: "close")
    dataPoint.setValue(date, forKey: "date")
    dataPoint.setValue(high, forKey: "high")
    dataPoint.setValue(low, forKey: "low")
    dataPoint.setValue(open, forKey: "open")
    dataPoint.setValue(stockName, forKey: "stockName")
    dataPoint.setValue(volume, forKey: "volume")
    
    managedContext.performBlockAndWait { () -> Void in
        do {
            try managedContext.save()
         //   print("HistData saved for \(stockName)")
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    return managedContext
}

func saveIndDatas(oscInd: NSManagedObject) -> NSManagedObject {

    managedContext.performBlockAndWait { () -> Void in
        do {
            try managedContext.save()
        //    print("IndData saved for \(stockName)")
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    return oscInd
    
}


func saveStrategy(name: String, k: Int, d: Int, stochLength: Int, stochMin: Double, stochMax: Double, rsiLength: Int, rsiMin: Double, rsiMax: Double, cciLength: Int, cciMin: Double, cciMax: Double) -> NSManagedObject? {
    
    let entity = NSEntityDescription.entityForName("StrategyCore", inManagedObjectContext: managedContext)
    let strategy = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
    
    strategy.setValue(name, forKey: "name")
    strategy.setValue(k, forKey: "k")
    strategy.setValue(d, forKey: "d")
    strategy.setValue(stochLength, forKey: "stochLength")
    strategy.setValue(stochMin, forKey: "stochMin")
    strategy.setValue(stochMax, forKey: "stochMax")
    strategy.setValue(rsiLength, forKey: "rsiLength")
    strategy.setValue(rsiMin, forKey: "rsiMin")
    strategy.setValue(rsiMax, forKey: "rsiMax")
    strategy.setValue(cciLength, forKey: "cciLength")
    strategy.setValue(cciMin, forKey: "cciMin")
    strategy.setValue(cciMax, forKey: "cciMax")
    
    print("setup managedobject for strategy")
    
    managedContext.performBlockAndWait{ () -> Void in
        
        do {
            try managedContext.save()
            print("strategy \(name) saved to CoreData")
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    return strategy
}



// MARK: Load all Data Methods

func loadCoreHistData() -> [NSManagedObject]? {
    
    let fetchRequest = NSFetchRequest(entityName: "HistDataCore")
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
    var coreHistData = [NSManagedObject]()
    
    managedContext.performBlockAndWait{ () -> Void in
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            print("HistData loaded")
            coreHistData = (results as? [NSManagedObject])!
        } catch let error as NSError {
            print("Could not loadCoreHistData \(error), \(error.userInfo)")
        }
    }
    
    return coreHistData
}



func loadCoreOscData() -> [NSManagedObject]? {
    
    let fetchRequest = NSFetchRequest(entityName: "IndDataCore")
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
    var coreOscData = [NSManagedObject]()
    
    managedContext.performBlockAndWait{ () -> Void in
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            print("IndData loaded")
            coreOscData = (results as? [NSManagedObject])!
        } catch let error as NSError {
            print("Could not loadCoreOscData \(error), \(error.userInfo)")
        }
    }
    return coreOscData
}


func loadCoreStocks() -> [NSManagedObject]? {

    let fetchRequest = NSFetchRequest(entityName: "StockCore")
    var coreStocks = [NSManagedObject]()
    
    managedContext.performBlockAndWait{ () -> Void in
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            print("Stocks Loaded")
            coreStocks = (results as? [NSManagedObject])!

        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    return coreStocks
}

func loadCoreStrategies() -> [NSManagedObject]? {
    
    let fetchRequest = NSFetchRequest(entityName: "StrategyCore")
    var coreStrategies = [NSManagedObject]()
    
    managedContext.performBlockAndWait{ () -> Void in
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            print("Strategies Loaded")
            coreStrategies = (results as? [NSManagedObject])!
            
        } catch let error as NSError {
            print("Could not loadCoreStocks \(error), \(error.userInfo)")
        }
    }
    return coreStrategies
}



// MARK: Load data by predicate methods

func loadStockHistData(stockName: String) -> [NSManagedObject]? {
    
    let fetchRequest = NSFetchRequest(entityName: "HistDataCore")
    fetchRequest.predicate = NSPredicate(format: "stockName == '\(stockName)'", stockName)
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
    var stockHistData = [NSManagedObject]()
    
    managedContext.performBlockAndWait{ () -> Void in
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            stockHistData = (results as? [NSManagedObject])!
        } catch let error as NSError {
            print("Could not load stock hist data \(error), \(error.userInfo)")
        }
    }
    
    return stockHistData
}


func loadStockOscData(stockName: String) -> [NSManagedObject]? {
    
    let fetchRequest = NSFetchRequest(entityName: "IndDataCore")
    fetchRequest.predicate = NSPredicate(format: "stockName == '\(stockName)'", stockName)
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
    var stockOscData = [NSManagedObject]()
    
    managedContext.performBlockAndWait{ () -> Void in
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            stockOscData = (results as? [NSManagedObject])!
        } catch let error as NSError {
            print("Could not load stock hist data \(error), \(error.userInfo)")
        }
    }
    
    return stockOscData
}



//MARK: Update Methods

func updateStockPrice(stockName: String, price: Double?, bid: Double?, ask: Double?, change: Double?, pChange: String?) -> NSManagedObject? {
    
    let fetchRequest = NSFetchRequest(entityName: "StockCore")
    //let entityDescription = NSEntityDescription.entityForName("StockCore")
    //fetchRequest.entity = entityDescription
    fetchRequest.predicate = NSPredicate(format: "name == '\(stockName)'", stockName)
    var stocks = [NSManagedObject]()
    
    managedContext.performBlockAndWait{ () -> Void in
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            stocks = (results as? [NSManagedObject])!
            
            if stocks[0].valueForKey("name") as! String == stockName {
                stocks[0].setValue(price, forKey: "price")
                stocks[0].setValue(bid, forKey: "bid")
                stocks[0].setValue(ask, forKey: "ask")
                stocks[0].setValue(change, forKey: "change")
                stocks[0].setValue(pChange, forKey: "pChange")
            }
            
        } catch let error as NSError {
            print("Could not update price for \(stockName) \(error), \(error.userInfo)")
        }
        
        do {
            if stocks[0].valueForKey("name") as! String == stockName {
                try stocks[0].managedObjectContext?.save()
                print("Updated Core Data Price \(stockName)")
            }
        } catch let error as NSError {
            print("Could not update price \(stockName) \(error), \(error.userInfo)")
        }
        
    }
    
    if stocks[0].valueForKey("name") as! String == stockName {
        return stocks[0]
    } else {
        return nil
    }
    
}

func updateStockList(stockName: String, listID: String) -> NSManagedObject? {
    
    let fetchRequest = NSFetchRequest(entityName: "StockCore")
    //let entityDescription = NSEntityDescription.entityForName("StockCore")
    //fetchRequest.entity = entityDescription
    fetchRequest.predicate = NSPredicate(format: "name == '\(stockName)'", stockName)
    var stocks = [NSManagedObject]()
    
    managedContext.performBlockAndWait{ () -> Void in
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            stocks = (results as? [NSManagedObject])!
            stocks[0].setValue(listID, forKey: "listID")
        } catch let error as NSError {
            print("Could not update list ID \(stockName) \(error), \(error.userInfo)")
        }
        
        do {
            try stocks[0].managedObjectContext?.save()
            print("listID update for \(stockName)")
        } catch let error as NSError {
            print("Could not update update list ID \(stockName) \(error), \(error.userInfo)")
        }
        
    }
    
    return stocks[0]
}


func updateStockStatus(stockName: String, status: String) -> NSManagedObject? {
    
    let fetchRequest = NSFetchRequest(entityName: "StockCore")
    //let entityDescription = NSEntityDescription.entityForName("StockCore")
    //fetchRequest.entity = entityDescription
    fetchRequest.predicate = NSPredicate(format: "name == '\(stockName)'", stockName)
    var stocks = [NSManagedObject]()
    
    managedContext.performBlockAndWait{ () -> Void in
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            stocks = (results as? [NSManagedObject])!
            stocks[0].setValue(status, forKey: "status")
        } catch let error as NSError {
            print("Could not update stock status \(stockName) \(error), \(error.userInfo)")
        }
        
        do {
            try stocks[0].managedObjectContext?.save()
            print("Updated Core Data Stock Stautus \(stockName)")
        } catch let error as NSError {
            print("Could not update stock status \(stockName) \(error), \(error.userInfo)")
        }
        
    }
    
    return stocks[0]
}




func updateStockStrat(stockName: String, strategy: String?) -> NSManagedObject {
    
    let fetchRequest = NSFetchRequest()
    let entityDescription = NSEntityDescription.entityForName("StockCore", inManagedObjectContext: managedContext)
    fetchRequest.entity = entityDescription
    fetchRequest.predicate = NSPredicate(format: "name == '\(stockName)'", stockName)
    var stock = [NSManagedObject]()
    
    managedContext.performBlockAndWait{ () -> Void in
        do {
            
            let result = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            stock.append(result[0])
            stock[0].setValue(strategy, forKey: "strategy")
            try stock[0].managedObjectContext?.save()
            print("Updated Strategy for Core Data Stock \(stockName)")
            
        } catch let error as NSError {
            print("Could not Update Strategy for Core Data Stock \(stockName) \(error), \(error.userInfo)")
        }
    }
    
    return stock[0]
}


func updateStrategy(oldName: String, newName: String, k: Int, d: Int, stochLength: Int, stochMin: Double, stochMax: Double, rsiLength: Int, rsiMin: Double, rsiMax: Double, cciLength: Int, cciMin: Double, cciMax: Double) -> NSManagedObject? {
    
    let fetchRequest = NSFetchRequest()
    let entityDescription = NSEntityDescription.entityForName("StrategyCore", inManagedObjectContext: managedContext)
    fetchRequest.entity = entityDescription
    fetchRequest.predicate = NSPredicate(format: "name == '\(oldName)'", oldName)
    var strategy = [NSManagedObject]()
    
    managedContext.performBlockAndWait{ () -> Void in
        do {
            
            let result = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            strategy.append(result[0])
            strategy[0].setValue(newName, forKey: "name")
            strategy[0].setValue(k, forKey: "k")
            strategy[0].setValue(d, forKey: "d")
            strategy[0].setValue(stochLength, forKey: "stochLength")
            strategy[0].setValue(stochMin, forKey: "stochMin")
            strategy[0].setValue(stochMax, forKey: "stochMax")
            strategy[0].setValue(rsiLength, forKey: "rsiLength")
            strategy[0].setValue(rsiMin, forKey: "rsiMin")
            strategy[0].setValue(rsiMax, forKey: "rsiMax")
            strategy[0].setValue(cciLength, forKey: "cciLength")
            strategy[0].setValue(cciMin, forKey: "cciMin")
            strategy[0].setValue(cciMax, forKey: "cciMax")
            try strategy[0].managedObjectContext?.save()
            print("Updated Strategy \(oldName):\(newName)")
            
        } catch let error as NSError {
            print("Could not Update Strategy \(oldName):\(newName) \(error), \(error.userInfo)")
        }
    }
    
    return strategy[0]
}



// MARK: Delete Methods

func deleteStock(stock: NSManagedObject) {
    
    let stockName = stock.valueForKey("name") as! String
    let fetchRequest = NSFetchRequest()
    let entityDescription = NSEntityDescription.entityForName("StockCore", inManagedObjectContext: managedContext)
    fetchRequest.entity = entityDescription
    fetchRequest.predicate = NSPredicate(format: "name == '\(stockName)'", stockName)
    managedContext.performBlockAndWait{ () -> Void in
        do {
            
            let result = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            let stock = result[0]
            managedContext.deleteObject(stock)
            try stock.managedObjectContext?.save()
            print("Deleted Core Data Stock \(stockName)")
            
        } catch let error as NSError {
            print("Could not delete stock \(stockName) \(error), \(error.userInfo)")
        }
    }
}


func deleteStrategy(strategy: NSManagedObject) {
    
    let name = strategy.valueForKey("name") as! String
    
    let fetchRequest = NSFetchRequest()
    let entityDescription = NSEntityDescription.entityForName("StrategyCore", inManagedObjectContext: managedContext)
    fetchRequest.entity = entityDescription
    fetchRequest.predicate = NSPredicate(format: "name == '\(name)'", name)
    managedContext.performBlockAndWait{ () -> Void in
        do {
            
            let result = try managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            let strategy = result[0]
            managedContext.deleteObject(strategy)
            try strategy.managedObjectContext?.save()
            print("Deleted Core Data Stock \(name)")
            
        } catch let error as NSError {
            print("Could not delete stock \(name) \(error), \(error.userInfo)")
        }
    }
    
}

func deleteHistData(stockName: String) {
    
    let fetchRequest = NSFetchRequest()
    let entityDescription = NSEntityDescription.entityForName("HistDataCore", inManagedObjectContext: managedContext)
    fetchRequest.entity = entityDescription
    fetchRequest.predicate = NSPredicate(format: "stockName == '\(stockName)'", stockName)
    
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    
    managedContext.performBlockAndWait{ () -> Void in
        
        do {
            try managedContext.persistentStoreCoordinator!.executeRequest(deleteRequest, withContext: managedContext)
        } catch let error as NSError {
            print("Could not delete histData for \(stockName) \(error), \(error.userInfo)")
        }
    }
}

func deleteIndData(stockName: String) {
    
 
    let fetchRequest = NSFetchRequest()
    let entityDescription = NSEntityDescription.entityForName("IndDataCore", inManagedObjectContext: managedContext)
    fetchRequest.entity = entityDescription
    fetchRequest.predicate = NSPredicate(format: "stockName == '\(stockName)'", stockName)
    
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    
    managedContext.performBlockAndWait{ () -> Void in
        
        do {
            try managedContext.persistentStoreCoordinator!.executeRequest(deleteRequest, withContext: managedContext)
        } catch let error as NSError {
            print("Could not delete histData for \(stockName) \(error), \(error.userInfo)")
        }
    }
    
}


// MARK: initialize objects
func initializeIndPoint() -> NSManagedObject  {
    let entity = NSEntityDescription.entityForName("IndDataCore", inManagedObjectContext: managedContext)
    let indPoint = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
    return indPoint
}










