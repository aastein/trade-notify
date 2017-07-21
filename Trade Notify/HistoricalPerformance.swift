//
//  HistoricalPerformance.swift
//  Trade Notify
//
//  Created by Aaron Stein on 6/1/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import Foundation
import RealmSwift

func getHistPerformance() -> (value: [Double], dates: [NSDate])
{
    let period = 210
    let stocks = getStock(nil)?.filter("hasData = true")
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
        let histData = getHistData(stock.name)
        let oscData = getOscData(stock.name)
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
                let lastVal = histData![i + 1].close
                let currVal = histData![i].close
                tempValue[i] += ((currVal - lastVal) / lastVal) + tempValue[i + 1]
            }
            else if i < period - 1
            {
                tempValue[i] = tempValue[i + 1]
            }
            
            if oscData![i].status == "Buy"
            {
                holding = true
            }
            else if oscData![i].status == "Sell"
            {
                holding = false
            }
            
            if !dataInit
            {
                dates[i] = oscData![i].date
            }
            
            portValue[i] += (tempValue[i] / Double(stocks!.count)) * 100
        }
        
        tempValue.removeAll()
        dataInit = true
    }
    
    return (portValue, dates)
}


func getUserPerformance() -> (value: [Double], dates: [NSDate])
{
    var period = Int()
    let stocks = getStock(nil)?.filter("hasData = true")
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
    
    oldestData = getPortData(oldestStock.name)
    
    //set date array
    for i in 0 ..< oldestData!.count
    {
        dates.append(oldestData![oldestData!.count - i].date)
    }
    
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
            }
        }
    
        tempValue.removeAll()
    }
    
    return (portValue, dates)
}











