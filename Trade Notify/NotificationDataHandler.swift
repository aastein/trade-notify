//
//  NotificationDataHandler.swift
//  Trade Notify
//
//  Created by Aaron Stein on 5/24/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import UIKit
import RealmSwift



func getAlertPrices (stock: Stock, oscInds: [OscData], histData: [HistData] ) {
    
    var sellPrice = Double(0)
    var buyPrice = Double(0)
    let isLive = isMarketLive()
    let lastTradeDate = getLastTradeDate()
    var oscIndex = Int(0)
    var histIndex = Int(0)
    var lastK = Double(0)
    let boundryValue = 0.0001
    var buyKs = [Double]()
    var buyK = Double(2)
    let smoothD = stock.strategy!.d
    let stochMin = (stock.strategy?.stochMin)!
    var sellK = Double(0)
    var sellKs = [Double]()

    if oscInds.count > 2
    {
        if !isLive
        {
            for i in 0 ..< oscInds.count
            {
                if oscInds[i].date == lastTradeDate
                {
                    oscIndex = i
                    break
                }
            }
            
            for i in 0 ..< histData.count
            {
                if histData[i].date == lastTradeDate
                {
                    histIndex = i
                    break
                }
            }
        }

        lastK = oscInds[oscIndex].k
        
        // MARK: Condition 1 (buy)
        /* 
            k(a) > d
            k(b) > lastK
            k(c)*100 > 5
            k(d)*100 < 50
    `   */
        
        var minKsOne = [Double]()
        var minKOne = Double(0)
        
        var sumK = Double() //condition 1a
        for i in oscIndex ..< (smoothD + oscIndex)
        { //condition2
            sumK += oscInds[i].k
        }
        
        minKsOne.append( ( sumK +  ( Double(smoothD) * boundryValue ) ) / ( Double(smoothD) - 1 ) ) //ka
        minKsOne.append( boundryValue + lastK ) // kb
        minKsOne.append( 0.05 + boundryValue ) //kc
        
        // find smallest k that satisfies all conditions
        for minK in minKsOne
        {
            if minK > minKOne
            {
                minKOne = minK
            }
        }
        
        if minKOne < 0.5
        {
            buyKs.append(minKOne)
        } else {
            buyKs.append( 0.5 - boundryValue )
        }
        
        //MARK: Condition 2 (buy)
        /*
            k > stochMin
            k(last) < stochMin
         */
        
        if oscInds[oscIndex].k < stochMin / 100
        {
            buyKs.append( (stochMin / 100) + boundryValue )
        }
        
        //MARK: Condition 3 (sell)
        /*
            k < d
        */
        
        sumK = Double(0)
        
        for i in oscIndex ..< (smoothD + oscIndex)
        {
            sumK += oscInds[i].k
        }
        
        sellKs.append( ( oscInds[oscIndex].k + boundryValue ) - sumK )
        
        //MARK: Condition 4 (sell)
        /*
            k < kLast
        */
        
        sellKs.append( oscInds[oscIndex].k - boundryValue )
        
        //MARK: get minK for buyPrice
        print("BUYKs are", buyKs)
        for kVal in buyKs
        {
            if kVal < buyK
            {
                buyK = kVal
            }
        }
        
        for kVal in sellKs
        {
            if kVal > sellK
            {
                sellK = kVal
            }
        }
        print("BUYK is", buyK)
        
        buyPrice = pFromBuyK ((buyK + 0.1 ), boundryValue: boundryValue, stock: stock, oscInds: oscInds, histData: histData, oscIndex: oscIndex, histIndex: histIndex )
        sellPrice = pFromSellK ((sellK - 0.1) , boundryValue: boundryValue, stock: stock, oscInds: oscInds, histData: histData, oscIndex: oscIndex, histIndex: histIndex )
    
        saveStock(stock.name, strategy: nil, listID: nil, status: nil, price: nil, bid: nil, ask: nil, change: nil, pChange: nil, updated: nil, k: nil , d: nil, cci: nil, sellPrice: sellPrice, buyPrice: buyPrice, hasData: nil, progress: nil)
    }

}


func pFromBuyK (k: Double, boundryValue: Double, stock: Stock, oscInds: [OscData], histData: [HistData], oscIndex: Int, histIndex: Int ) -> Double {
    
  //  print("pFromBuyK")
  //  print("buy k is \(k)")
    
    let strategy = stock.strategy!
    let smoothK = Double(strategy.k)
    let stochLength = Double(strategy.stochLength)
    let rsiLength = Double(strategy.rsiLength)
    
    var stochSum = Double(0)
    
    for i in oscIndex ..< (Int(smoothK) - 1 + oscIndex)
    {
        stochSum += oscInds[i].stoch
//        print("adding \(oscInds[i].stoch) to stochSum")
    }
    
 //   print("stochSum is \(stochSum)")
    
    let reqStoch = k * smoothK - stochSum
    
 //   print("buy reqStoch = \(reqStoch)")
    
    var minRSI = Double(100)
    var maxRSI = Double(0)
    var reqRSI = Double(0)
    
    for i in oscIndex ..< (Int(stochLength - 1) + oscIndex)
    {
        let newRSI = oscInds[i].rsi
        
  //      print("buyRSI at index \(i) is \(newRSI)")
        
        if newRSI < minRSI
        {
            minRSI = newRSI
  //          print("minRSI set to  \(minRSI)")
        }
        
        if newRSI > maxRSI
        {
            maxRSI = newRSI
        }
    }
    
    if reqStoch == 1
    { // rsi is now max rsi. Therefore rsi is rsiMax + (n->0)
        reqRSI = maxRSI
        
    } else //rsi is not maxRSI or minRSI
    {
        reqRSI = reqStoch * (maxRSI-minRSI) + minRSI
        if reqRSI < minRSI {
   //         print("FUCKKKKKKKK REQRSI IS LESS THAN MINRSI", reqRSI, minRSI)
        }
    }
    
    let reqRS = (100 / ( 100 - reqRSI)) - 1
    
    let reqAvgUp = ( reqRS * oscInds[oscIndex].avgDown * (rsiLength - 1 ) ) / rsiLength
    
    let reqUp = ( reqAvgUp * rsiLength ) - ( oscInds[oscIndex].avgUp * ( rsiLength - 1 ))
    
    return histData[histIndex].adjClose + reqUp
    
}


func pFromSellK (k: Double, boundryValue: Double, stock: Stock, oscInds: [OscData], histData: [HistData], oscIndex: Int, histIndex: Int ) -> Double {
    
 //   print("sell k is \(k)")
    
    let strategy = stock.strategy!
    let smoothK = Double(strategy.k)
    let stochLength = Double(strategy.stochLength)
    let rsiLength = Double(strategy.rsiLength)
    
    var stochSum = Double(0)
    
    for i in oscIndex ..< (Int(smoothK) - 1 + oscIndex)
    {
        stochSum += oscInds[i].stoch
  //      print("adding \(oscInds[i].stoch) to stochSum")
    }
  //  print("stochSum is \(stochSum)")
    let reqStoch = k * smoothK - stochSum
  //  print("buy reqStoch = \(reqStoch)")
    var minRSI = Double(100)
    var maxRSI = Double(0)
    var reqRSI = Double(0)
    
    for i in oscIndex ..< (Int(stochLength - 1) + oscIndex)
    {
        let newRSI = oscInds[i].rsi
  //      print("buyRSI at index \(i) is \(newRSI)")
        if newRSI < minRSI
        {
            minRSI = newRSI
  //          print("minRSI set to  \(minRSI)")
        }
        
        if newRSI > maxRSI
        {
            maxRSI = newRSI
    //        print("maxRSI set to  \(maxRSI)")
        }
    }
    
    if reqStoch == 0
    { // rsi is now min rsi. Therefore rsi is rsiMax + (n->0)
        reqRSI = minRSI
        
    } else //rsi is not maxRSI or minRSI
    {
        reqRSI = reqStoch * (maxRSI-minRSI) + minRSI
        if reqRSI > maxRSI {
  //          print("FUCKKKKKKKK REQRSI IS MORE THAN MINRSI", reqRSI, maxRSI)
        }
    }
    
    let reqRS = (100 / ( 100 - reqRSI)) - 1
    
    let reqAvgDown = ( ( 1 / reqRS ) * (oscInds[oscIndex].avgUp * (rsiLength - 1 ) ) / rsiLength )
    
    let reqDown = ( reqAvgDown * rsiLength ) - ( oscInds[oscIndex].avgDown * ( rsiLength - 1 ))
    
    return histData[histIndex].adjClose - reqDown
    
}