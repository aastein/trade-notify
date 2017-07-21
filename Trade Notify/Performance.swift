//
//  HistoricalPerformance.swift
//  Trade Notify
//
//  Created by Aaron Stein on 6/1/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import Foundation
import RealmSwift

func getHistPerformance(stockName: String?) -> (value: [Double], dates: [NSDate])
{
    let period = 253
    let stocks = getStock(stockName)?.filter("hasData = true")
    var portValue = [Double]()
    var dates = [NSDate]()
    var dataInit = false
    
    for _ in 0 ..< period
    {
        portValue.append(0.0)
        dates.append(NSDate())
    }
    
    for stock in stocks!
    {
        if stock.hasData == true {
            let histData = stock.histData.sorted("date", ascending: false)
            let oscData = stock.oscData.sorted("date", ascending: false)
            var holding = false
            var tempValue = [Double]()
            
            for _ in 0 ..< period
            {
                tempValue.append(0.0)
            }

            for i in (0 ..< period).reverse()
            {
                if holding == true
                {
                    let lastVal = histData[i + 1].close
                    let currVal = histData[i].close
                    tempValue[i] += ((currVal - lastVal) / lastVal) + tempValue[i + 1]
                }
                else if i < period - 1
                {
                    tempValue[i] = tempValue[i + 1]
                }
                
                if oscData[i].status == "Buy"
                {
                    holding = true
                }
                else if oscData[i].status == "Sell"
                {
                    holding = false
                }
                
                if !dataInit
                {
                    dates[i] = oscData[i].date
                }
                
                portValue[i] += (tempValue[i] / Double(stocks!.count)) * 100
            }
            tempValue.removeAll()
            dataInit = true
        }
    }
    
    return (portValue, dates)
}


func getUserPerformance() -> (value: [Double], dates: [NSDate])
{
    let stocks = getStock(nil)?.filter("hasData = true")
    var period = Int()
    var portValue = [Double]()
    var dates = [NSDate]()
    var oldestStock = Stock()
    var oldestData = Results<PortData>?()
    
    //get-set period size
    
    for stock in stocks!
    {
        let portData = getPortData(stock.name)
        if portData!.count > period
        {
            oldestStock = stock
            period = portData!.count
        }
    }
    
    //set portValue size 
    for _ in 0 ..< period
    {
        portValue.append(0.0)
    }
    print("finished setting portValue size")
    
    oldestData = getPortData(oldestStock.name)
    
    //set date array
    for i in 0 ..< oldestData!.count
    {
        dates.append(oldestData![oldestData!.count - 1 - i].date)
    }
    print("finished setting date array")
    
    for stock in stocks!
    {
        let portData = getPortData(stock.name)
        var holding = false
        var tempValue = [Double]()
        
        if portData!.count > 0
        {
            for _ in 0 ..< portData!.count
            {
                tempValue.append(0.0)
            }
            
            if portData!.count > 0
            {
                for i in (0 ..< portData!.count).reverse()
                {
                    if holding == true
                    {
                        let lastVal = portData![i + 1].value * Double(portData![i + 1].shares)
                        let currVal = portData![i].value * Double(portData![i + 1].shares)
                        tempValue[i] += ((currVal - lastVal) / lastVal) + tempValue[i + 1]
                    }
                    else if i < period - 1
                    {
                        tempValue[i] = tempValue[i + 1]
                    }
                    
                    if portData![i].shares > 0
                    {
                        holding = true
                    }
                    else if portData![i].shares == 0
                    {
                        holding = false
                    }
                    
                    portValue[i] += (tempValue[i] / Double(stocks!.count)) * 100
                    print("portValue[i]", portValue[i])
                }
            }
        }
    
        tempValue.removeAll()
    }
    
    return (portValue, dates)
}

func getSharpeRatio(metrics: Results<Metrics>?) -> Double
{
    let riskFreeReturn = 0.05
    var metrics = metrics
    var sharpeRatio = Double(0)
    var sumReturns = Double(0)
    var avgReturn = Double(0)
    var topSum = Double(0)
    var stdev = Double(0)
    
    if metrics == nil
    {
        metrics = getMetrics(nil)
    }
    
    for metric in metrics!
    {
        sumReturns += metric.totalReturnPercent
    }
    
    avgReturn = sumReturns / Double((metrics?.count)!)
    
    for metric in metrics!
    {
        topSum += ( metric.totalReturnPercent - avgReturn )*( metric.totalReturnPercent - avgReturn )
    }
    
    stdev = sqrt( topSum / Double(metrics!.count) )
    sharpeRatio = ( avgReturn - riskFreeReturn ) / stdev
    
    return sharpeRatio
}

func getAvgReturn(metrics: Results<Metrics>?) -> Double
{
    var avgReturn = Double(0)
    var metrics = metrics
    
    if metrics == nil
    {
        metrics = getMetrics(nil)
    }
    
    for metric in metrics!
    {
        avgReturn += metric.avgTradePercent
    }
    
    avgReturn = avgReturn / Double(metrics!.count)
    
    return avgReturn
}

func getAvgDaysPerTrade(metrics: Results<Metrics>?) -> Double
{
    var avgDaysPerTrade = Double(0)
    var metrics = metrics
    
    if metrics == nil
    {
        metrics = getMetrics(nil)
    }
    
    for metric in metrics!
    {
        avgDaysPerTrade += metric.avgDaysPerTrade
    }
    
    avgDaysPerTrade = avgDaysPerTrade / Double(metrics!.count)
    
    return avgDaysPerTrade
}

func getTotalTrades(metrics: Results<Metrics>?) -> (total: Double, avg: Double)
{
    var totalTrades = Double(0)
    var metrics = metrics
    var avgTrades = Double(0)
    
    if metrics == nil
    {
        metrics = getMetrics(nil)
    }
    
    for metric in metrics!
    {
        totalTrades += Double(metric.totalTrades)
    }
    
    avgTrades = totalTrades / Double(metrics!.count)
    
    return (totalTrades, avgTrades)
}

func getAvgPercentProfitable(metrics: Results<Metrics>?) -> Double
{
    var averagePP = Double(0)
    var metrics = metrics
    
    if metrics == nil
    {
        metrics = getMetrics(nil)
    }
    
    for metric in metrics!
    {
        averagePP += Double(metric.percentProfitable)
    }
    
    averagePP = averagePP / Double(metrics!.count)
    
    return averagePP
}






