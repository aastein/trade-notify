//
//  GetStatus.swift
//  Trade Notify
//
//  Created by Aaron Stein on 4/10/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import UIKit
import RealmSwift

public class UpdateIndSession {
    
    var isCacluating = false
    var timerStarted = false
    var updateTimer = NSTimer()
    
    @objc func updateIndData ()
    {
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue,
        {
            if self.isCacluating == false{
                self.isCacluating = true
                var stocks = getStock(nil)
                for i in 0 ..< (stocks?.count)!
                {
                    stocks = getStock(nil)
                    if stocks!.count > i && stocks![i].hasData == true
                    {
                        checkSetOscData(stocks![i].name)
                    }
                }
                self.isCacluating = false
            }
        })
    }
    
    public func startTimer () {
        if timerStarted == false {
            timerStarted = true
            updateTimer = NSTimer.scheduledTimerWithTimeInterval(20.0, target: self, selector: #selector(UpdateIndSession.updateIndData), userInfo: nil, repeats: true)
        }
    }
    
    public func stopTimer () {
        if timerStarted == true {
            updateTimer.invalidate()
        }
    }
}

func getOscHistDayDiff(histData: Results<HistData>?, oscInds: Results<OscData>?) -> Int
{

    //printOscData(oscInds)
    let lastDLDate = histData![0].date
    let lastIndDate = oscInds![0].date
    //print("lastDLDate", lastDLDate, "lastIndDate", lastIndDate)
    let dateDiff = NSCalendar.currentCalendar().components(NSCalendarUnit.Day, fromDate: lastDLDate, toDate: lastIndDate, options: [])
    return dateDiff.day
    
}


func checkSetOscData(stockName: String)
{
    //init local variables
    let stock = getStock(stockName)![0]
    let oscData = stock.oscData.sorted("date", ascending: false)
    let histData = stock.histData.sorted("date", ascending: false)
    var oscInds = [OscData]()
    var daysToCalc = Int(0)
    
    print("histDataCount", histData.count, "oscDataCout", oscData.count)
    daysToCalc = daysToCalculate(stockName)
    print("daysToCalc: \(daysToCalc)")
    print("strategy count", stock.strategy.count)
    print("stock strat", stock.strategy)
    if daysToCalc > 0 && stock.strategy.count > 0
    {
        print("1")
        let strategy = stock.strategy[0]
        let smoothK = Double(strategy.k)
        let smoothD = Double(strategy.d)
        let rsiLength = Double(strategy.rsiLength)
        let stochLength = Double(strategy.stochLength)
        let cciLength = Double(strategy.cciLength)
        print("2")
        //set minimum amount of data points needed for calculation
        var minDataNeeded = Int(0)
    
        if (rsiLength + stochLength + smoothD + smoothK) > cciLength
        {
            minDataNeeded = Int(rsiLength + stochLength + smoothD + smoothK)
        }
        else
        {
            minDataNeeded = Int(cciLength)
        }
        
        //add exisitng oscData to oscinds
        for i in 0 ..< oscData.count
        {
            oscInds.append(oscData[i])
        }
    print("3")
        //add needed oscInds to match size of histData
        for i in (0 ..< daysToCalc).reverse()
        {
            let oscPoint = OscData()
            oscPoint.date = histData[i].date
            oscPoint.stock = stock
            oscInds.insert(oscPoint, atIndex: 0)
        }
        print("4")
        if oscInds.count > minDataNeeded
        {
            oscInds = calculateInds(daysToCalc, histData: histData, oscInds: oscInds, strategy: strategy, debug: true)
        }
        
        var slimInds = [OscData]()
        print("5")
        for i in 0 ..< daysToCalc + 1
        {
            if i < oscInds.count
            {
                var temp = OscData()
                temp = oscInds[i]
                slimInds.append(temp)
            }
        }
        print("6")
        if histData.count > 0 { print("LAST HIST DATE", histData[0].date) }
        if oscData.count > 0 { print("LAST OSC DATE", oscData[0].date) }
        if oscInds.count > 0
        {
            print("LAST OSCINDS DATE", oscInds[0].date)
        }
        
        getSatus(stock, oscInds: slimInds, histData: histData, daysToCalc: daysToCalc)
    }
}

func getSatus (stock: Stock, oscInds: [OscData], histData: Results<HistData>, daysToCalc: Int) -> [OscData]
{
    let resultsOsc = getBacktestResults(stock.strategy[0], oscInds: oscInds, daysToCalc: daysToCalc)
    let cleanOsc = cleanBacktestDataAndGetPerformance(resultsOsc, histData: histData, isUpdate: true).oscData
    
    for data in cleanOsc!
    {
        data.save()
    }
    
    let k = cleanOsc![0].k
    let d = cleanOsc![0].d
    let cci = cleanOsc![0].cci
    let status = cleanOsc![0].status
    let lastStatus = getStock(stock.name)![0].status
    stock.updateStatus(status, lastStatus: lastStatus, k: k, d: d, cci: cci)
    return cleanOsc!
}

func calculateInds (daysToCalc: Int, histData: Results<HistData>, oscInds: [OscData], strategy: Strat, debug: Bool) -> [OscData]
{
    
    let smoothK = Double(strategy.k)
    let smoothD = Double(strategy.d)
    let rsiLength = Double(strategy.rsiLength)
    let stochLength = Double(strategy.stochLength)
    let cciLength = Double(strategy.cciLength)

    // stoch variables
    var sumUp: Double
    var sumDown: Double
    
    //cci varaibles
    var ptMA = Double(0)
    var ptAD = Double(0)
    
    var daystocalc = daysToCalc
    
    if daystocalc == oscInds.count
    {
        daystocalc -= 1
    }
    
    for i in (0 ..< daystocalc).reverse()
    {
        var up = Double()
        var down = Double()
        let close = histData[i].close
        oscInds[i].pt = close
        
        if i <= oscInds.count - Int(cciLength)
        { // for CCI calc: get CCI
            
            //reset values for moving average and standard deviation
            ptMA = 0
            ptAD = 0
            
            // set moving average
            if i <= oscInds.count - Int(cciLength)
            {
                for j in 0 ..< Int(cciLength)
                {
                    ptMA += oscInds[i+j].pt
                }
                
                ptMA = ptMA/cciLength
            }
            
            // set average deviation
            for j in 0 ..< Int(cciLength)
            {
                ptAD += abs((oscInds[i+j].pt) - ptMA)
            }
            
            ptAD = ptAD*(1/cciLength)
            let cci = ((oscInds[i].pt) - ptMA)/(0.015*ptAD)
            oscInds[i].cci = cci
        }
        
        //begin RSI/SRSI calc
        //set "up" and "down" values
        if i < oscInds.count-1
        {
            
            if close > histData[i+1].close
            {
                up = close - histData[i+1].close
                down = 0
            } else if close < histData[i+1].close
            {
                down = histData[i+1].close - close
                up = 0
            } else
            {
                up = 0
                down = 0
            }
            
            oscInds[i].down = down
            oscInds[i].up = up
        }
        
        if i <= oscInds.count - Int(rsiLength)
        { //makes sure data exists for averageing. Averaging type is EMA. Set all values for and including RSI
            
            //reset sum values
            sumUp = 0
            sumDown = 0
            
            //set initial average values
            if i == oscInds.count - Int(rsiLength) - 1
            {
                //get sum of Up values in rsiLength
                for j in 0 ..< Int(rsiLength)
                {
                    sumUp += oscInds[i+j].up
                }
                
                
                for j in 0 ..< Int(rsiLength)
                {
                    sumDown += oscInds[i+j].down
                }
                
                let avgUp = sumUp/rsiLength
                let avgDown = sumDown/rsiLength
                let rs = avgUp / avgDown
                let rsi = 100 - (100/(rs + 1))
                
                oscInds[i].avgDown = avgDown
                oscInds[i].avgUp = avgUp
                oscInds[i].rs = rs
                oscInds[i].rsi = rsi
                
            } else
            {
                let lastAvgUp = oscInds[i+1].avgUp
                let lastAvgDown = oscInds[i+1].avgDown
                let currUp = oscInds[i].up
                let currDown = oscInds[i].down
                
                let avgUp = ( lastAvgUp * (rsiLength - 1) + currUp ) / rsiLength
                let avgDown = ( lastAvgDown * (rsiLength - 1) + currDown ) / rsiLength
                let rs = avgUp / avgDown
                let rsi = 100 - (100/(rs + 1))
                
                oscInds[i].avgDown = avgDown
                oscInds[i].avgUp = avgUp
                oscInds[i].rs = rs
                oscInds[i].rsi = rsi
                
                //get SotchRSI values and calculate StochRSI
                if i < oscInds.count - Int(rsiLength) - Int(stochLength)
                {
                    var minRSI = oscInds[i].rsi
                    var maxRSI = minRSI
                    
                    for j in 0 ..< Int(stochLength)
                    {
                        let newRSI = oscInds[i+j].rsi
                        
                        if newRSI < minRSI
                        {
                            minRSI = newRSI
                        }
                        
                        if newRSI > maxRSI
                        {
                            maxRSI = newRSI
                        }
                    }
                    
                    let stoch = ( oscInds[i].rsi - minRSI ) / ( maxRSI - minRSI)
                    oscInds[i].stoch = stoch
                    
                    // get K
                    if i < oscInds.count - Int(rsiLength) - Int(stochLength) - Int(smoothK)
                    {
                        var sumStoch = Double(0)
                        
                        for j in 0 ..< Int(smoothK)
                        {
                            sumStoch += oscInds[i+j].stoch
                            
                        }
                        
                        let k = sumStoch / smoothK
                        oscInds[i].k = k
                        
                        if i < oscInds.count - Int(rsiLength) - Int(stochLength) - Int(smoothK) - Int(smoothD)
                        {
                            var sumStochD = Double(0)
                            
                            for j in 0 ..< Int(smoothD)
                            {
                                sumStochD += oscInds[i+j].k
                                
                            }
                            
                            let d = sumStochD / smoothD
                            oscInds[i].d = d
                        }
                    }
                }
            }
        }
    }
    return oscInds
}