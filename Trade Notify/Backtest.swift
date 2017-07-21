//
//  BacktestModule.swift
//  Trade Notify
//
//  Created by Aaron Stein on 5/25/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import UIKit
import RealmSwift


class BacktestManager: NSObject
{
    
    private var operations = [Int: GetStratOperation]()
    
    let queue: NSOperationQueue = {
        let _queue = NSOperationQueue()
        _queue.name = "getStrat"
        _queue.maxConcurrentOperationCount = 1
        
        return _queue
    }()
    
    func  addStock(stockName: String) -> GetStratOperation
    {
        let operation = GetStratOperation(stockname: stockName)
        queue.addOperation(operation)
        return operation
    }
    
    func cancelAll()
    {
        queue.cancelAllOperations()
    }
}

class GetStratOperation: AsynchronousOperation
{
    var stockName: String
    
    init(stockname: String)
    {
        stockName = stockname
    }
    
    override func main()
    {
        testStrats(stockName)
    }
    
}

func testStrats(stockName: String)
{
    var bestStrat = Strat()
    var bestMetrics = Metrics()
    let bufferDays = 30
    let stock = getStock(stockName)![0]
    let histData = stock.histData.sorted("date", ascending: false)
    let daysToCalc = histData.count
    
    if daysToCalc > 0
    {
        bestMetrics.name = stockName
        bestMetrics.strat = bestStrat
        bestStrat.stock = stock
        bestStrat.name = stockName
        bestStrat.rsiLength = 14
        bestStrat.stochLength = 14
        bestStrat.rsiMin = 30
        bestStrat.rsiMax = 70
        bestStrat.stochMin = 20
        bestStrat.stochMax = 80
        bestStrat.k = 3
        bestStrat.d = 3

        
        print("calculating strategy for", stockName)
    
        var count = Double(0)
        
        for rsiLength in 2 ..< 16 // iterate through rsiLength
        {
            for stochLength in 2 ..< 16 // iterate through stochLength
            {
                for k in 1 ..< 6 //iterate though k/d assume k = d
                {
                    for d in 1 ..< 6 //iterate though k/d assume k = d
                    {
                        if (rsiLength < (10 + stochLength)) && (stochLength < (10 + rsiLength))
                        {
                            
                            var tempOsc = [OscData]()
                            
                            for i in 0 ..< daysToCalc
                            {
                                let oscPoint = OscData()
                                oscPoint.date = histData[i].date
                                tempOsc.append(oscPoint)
                            }

                            let tempStrat = Strat()
                            tempStrat.name = stockName
                            tempStrat.stock = stock
                            tempStrat.cciLength = ( rsiLength + stochLength ) / 2
                            tempStrat.cciMax = 100
                            tempStrat.cciMin = -100
                            tempStrat.rsiLength = rsiLength
                            tempStrat.stochLength = stochLength
                            tempStrat.rsiMin = 30
                            tempStrat.rsiMax = 70
                            tempStrat.stochMin = 1
                            tempStrat.stochMax = 99
                            tempStrat.k = k
                            tempStrat.d = d
                            
                            let results = getBacktestResults(tempStrat, oscInds: calculateInds(daysToCalc, histData: histData, oscInds: tempOsc, strategy: tempStrat, debug: false ), daysToCalc: daysToCalc - bufferDays )
                            
                            if results.count > 2
                            {
                                let tempMetrics = cleanBacktestDataAndGetPerformance(results, histData: histData, isUpdate: false).metrics
                                //print(tempMetrics!.score, bestMetrics.score)
                                if tempMetrics!.score > bestMetrics.score
                                {
                                //print("SET BEST METRIC================", tempMetrics!.score, tempMetrics!.totalReturn)
                                    bestStrat = tempStrat
                                    bestMetrics = tempMetrics!
                                    bestMetrics.strat = bestStrat
                                }
                            }
                            
                            tempOsc.removeAll()
                        }
                    }
                }
                
                count += 1
                let progress = Float(count / (14*14))
                stock.updateProgress(progress)
            }
        }
        print("finished calculating")
        if bestMetrics.totalReturn <= 0 || bestMetrics.totalReturnPercent <= 0
        {
            print("best strategy did not meet critera")
            deleteHistData(stock)
            scheduleLocalBadStratNotification(stockName)
            deleteStock(stockName)
            print("deleted", stockName)
        }
        else
        {
            stock.updateScore(bestMetrics.score)
            bestMetrics.save()
            bestStrat.save()
            checkSetOscData(stockName)
            
            // print("best strat is: ", bestStrat.name, bestStrat.k, bestStrat.d, bestStrat.stochLength, bestStrat.stochMin, bestStrat.stochMax, bestStrat.rsiLength, bestStrat.rsiMin, bestStrat.rsiMax, bestStrat.cciLength, bestStrat.cciMin, bestStrat.cciMax)
            
           // print("\(stockName) score", bestMetrics.score, "bestGain: ", bestMetrics.totalReturn, "rsiLength \(bestStrat.rsiLength), stochLength \(bestStrat.stochLength), rsiMin \(30), rsiMax \(100-30), stochMin \(1), stochMax \(100-1), k \(bestStrat.k), d \(bestStrat.d)")
        }
    }
}

func getBacktestResults (strategy: Strat, oscInds: [OscData], daysToCalc: Int) -> [OscData] {

    //set local variables for strategy parameters
    let stochMin = strategy.stochMin
    var daystocalc = daysToCalc
    
    if daysToCalc == oscInds.count
    {
        daystocalc -= 1
    }
    
    for i in 0 ..< daystocalc
    {
        let nowK = oscInds[i].k
        let lastK = oscInds[i + 1].k
        let nowD = oscInds[i].d
        var status = "IND"
        
        // condiditon 1 - crossover above SRSI = 5
        if (100*nowK) > 5 && nowK > lastK && nowK > nowD && nowK*100 < 70
        {
            status = "Buy"
        }
        
        // condiditon 2 - k cross over stochMin
        if (100*nowK) > stochMin && (100*lastK) < stochMin
        {
            status = "Buy"
        }
        
        // condiditon 3
        if  nowK < nowD
        {
            status = "Sell"
        }
        
        // condiditon 4
        if lastK > nowK
        {
            status = "Sell"
        }
        
        if oscInds.count < 240
        {
            do
            {
                let realm = try Realm()
                try! realm.write
                {
                    oscInds[i].status = status
                }
            }
            catch let error as NSError
            {
                print("saveStrat failed.", error)
            }
        }
        else
        {
            oscInds[i].status = status
        }
        
    }
    return oscInds
}

func cleanBacktestDataAndGetPerformance ( backtestData: [OscData], histData: Results<HistData>, isUpdate: Bool ) -> (metrics: Metrics?, oscData: [OscData]?)
{
    //print("cleanBacktestDataAndGetPerformance")
    var currStatus = "Sold"
    var cleanData = backtestData

    for i in (0 ..< cleanData.count).reverse()
    {
        var setStatus = ""
        
        if currStatus == "Sold" && cleanData[i].status == "Buy" //stock not held. initiate buy.
        {
            currStatus = "Bought"
            setStatus = "Buy"
        }
        else if currStatus == "Bought" && cleanData[i].status == "Sell" //stock is held. initiate sell.
        {
            currStatus = "Sold"
            setStatus = "Sell"
        }

        
        if backtestData.count < 240
        {
            do
            {
                let realm = try Realm()
                try! realm.write
                {
                    cleanData[i].status = setStatus
                }
            }
            catch let error as NSError
            {
                print("saveStrat failed.", error)
            }
        }
        else
        {
            cleanData[i].status = setStatus
        }
        
        //print("oscDateCleanDAta index:", i, "date",  cleanData[i].date, cleanData[i].status)
        
    }
    
    if isUpdate
    {
        return (nil, cleanData)
    }

    return (getPerformance(cleanData, histData: histData), cleanData)
}

func getPerformance(backtestData: [OscData], histData: Results<HistData>) -> Metrics
{
    
    let stratMetrics = Metrics()
    let period = backtestData.count - 30
    var totalReturn = Double(0)
    var buyPrice = Double(0)
    var sellPrice = Double(0)
    var totalCompletedTrades = Int(0)
    var totalProfitableTrades = Int(0)
    var sumPercents = Double(0)
    var avgDaysPerTrade = Double(0)
    var holding = false
    var daysInTrade = Double(0)
    var sumDown = Double(0)
    
    
    for i in (0 ..< period).reverse()
    {
        if holding == true
        {
            daysInTrade += 1
        }
        
        if backtestData[i].status == "Buy" //buy action
        {
            buyPrice = histData[i].close
            holding = true
            
        }
        else if backtestData[i].status == "Sell" //sell action
        {
            var returnPerSale = Double(0)
            
            holding = false
            avgDaysPerTrade += daysInTrade
            daysInTrade = 0
            
            sellPrice = histData[i].close
            returnPerSale = sellPrice - buyPrice
            totalCompletedTrades += 1
            totalReturn += returnPerSale
            sumPercents += returnPerSale/buyPrice
            
            if returnPerSale > 0
            {
                totalProfitableTrades += 1
            }
            else
            {
                sumDown += returnPerSale
            }
        }
    }
    
    avgDaysPerTrade = avgDaysPerTrade / Double(totalCompletedTrades)
    let percentProfitable = Double(totalProfitableTrades) / Double(totalCompletedTrades)
    var score = Double(DBL_MAX * -1)
    
    if totalProfitableTrades > 20 
    {
        score = sumDown
    }
    
    stratMetrics.avgDaysPerTrade = avgDaysPerTrade
    stratMetrics.percentProfitable = percentProfitable
    stratMetrics.totalReturn = totalReturn
    stratMetrics.totalReturnPercent = sumPercents
    stratMetrics.avgTrade = totalReturn / Double(totalCompletedTrades)
    stratMetrics.avgTradePercent = sumPercents / Double(totalCompletedTrades)
    stratMetrics.totalTrades = totalCompletedTrades
    stratMetrics.score = score
    return stratMetrics
}









