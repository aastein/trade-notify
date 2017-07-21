//
//  GetStatus.swift
//  Trade Notify
//
//  Created by Aaron Stein on 4/10/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import UIKit
 /*
func getStatus(stock: Stock, stockData: StockData, strategies: [Strategy], currPrice: Double?) -> Stock {

    //set local variables
    var histData = stockData.histData!
    let dataSize = histData.count
    var oscInds = [OscIndicators]()
    var strategy = Strategy(name: "Default", type: "Stoch RSI", smoothK: 3, smoothD: 3, stochLength: 14, rsiLength: 14, overSold: 20, overBought: 80, cciPeriod: 20)
    
    // stoch variables
    var sumUp: Double
    var sumDown: Double
    
    //cci varaibles
    var adj = Double(0)
    var ptMA = Double(0)
    var ptAD = Double(0)
    
    //find assigned stategy
    for i in 0 ..< strategies.count {
        if stock.strategy == strategies[i].name {
            strategy = strategies[i]
        }
    }
    
    //set local variables for strategy parameters
    let rsiLength = Double(strategy!.rsiLength)
    let stochLength = Double(strategy!.stochLength)
    let smoothK = Double(strategy!.smoothK)
    let smoothD = Double(strategy!.smoothD)
    let cciLength = Double(strategy!.cciPeriod)

    //if currPrice is not nil, then function was called to append new data for current price, thus last hist data was 0 or 1 days ago. If more than 1 day ago its better to download hist data and append that

    if stockData.oscInds?.count > 0 {
        
        let dateDiff = stockData.histData!.count - (stockData.oscInds?.count)!
        oscInds = stockData.oscInds!
    
        /* aadress complex cases later (when oscinds data is very outdated and currentlly market is open
        if dateDiff > 1 {
            print("dateDiff is greater than 1")
        }
        
        if dateDiff == 1 {
            print("dateDiff is greater than 1")
        }
         */
        
 //       print("#1 datediff", dateDiff)
        
   //     print( "Stock is ", stock.name, ". Dates", stock.histData![0].date!, (stock.oscInds?[0].date)!, (stock.oscInds?[1].date)!, (stock.oscInds?[2].date)!)
        
        if (stockData.oscInds?[1].date)! == "Placeholder"{
                stockData.oscInds?.removeAtIndex(2)
        }
        
 //       print("Indicator dateDiff is ", dateDiff, "last HistDate", histData[0].date!, "lastIndDate", oscInds[0].date)
  //      print("i = 1 ", dateDiff, "last HistDate", histData[1].date!, "lastIndDate", oscInds[1].date)
  //      print("i = 2", dateDiff, "last HistDate", histData[2].date!, "lastIndDate", oscInds[2].date)
        
        
        if dateDiff == 1 {
            
   //         print("dateDiff is 1")
            
            //append last historical data

            let indInsert = OscIndicators(date: histData[0].date!, up: 0, down: 0, avgUp: 0, avgDown: 0, RS: 0, RSI: 0, stoch: 0, K: 0, D: 0, pt: 0 , CCI: 0)
            oscInds.insert(indInsert!, atIndex: 0)

            //calculate last row in oscInds
            
            //set index of row needing updating
            let i = 0
            
            
            // for CCI calc: high and low are adjusted here
            
            //find multiply factor if any
            adj = 1
            
            if histData[i].close > 1.5*histData[i].adjClose! {
                
                adj = (histData[i].close!/histData[i].adjClose!)
                adj = round(adj)
                
            }
            
            //let cciHigh = histData[i].high!/adj
           // let cciLow = histData[i].low!/adj
            let cciClose = histData[i].adjClose
            //oscInds[i].pt = (cciHigh + cciLow + cciClose!)/3
            
            oscInds[i].pt = cciClose!
            // for CCI calc: get CCI
            
            //reset values for moving average and standard deviation
            ptMA = 0
            ptAD = 0
            
            // set initial moving average
            for j in 0 ..< Int(cciLength) {
                    ptMA += oscInds[i+j].pt
            }
                
            ptMA = ptMA/cciLength

            // set average deviation
            for j in 0 ..< Int(cciLength) {
                ptAD += abs(oscInds[i+j].pt - ptMA)
            }
            
            ptAD = ptAD*(1/cciLength)
            
            oscInds[i].CCI = (oscInds[i].pt - ptMA)/(0.015*ptAD)


            //rsi/srsi
            
            //set "up" and "down" values
            if histData[i].adjClose > histData[i+1].adjClose {
                oscInds[i].up = histData[i].adjClose! - histData[i+1].adjClose!
                oscInds[i].down = 0
            } else if histData[i].adjClose < histData[i+1].adjClose {
                oscInds[i].down = histData[i+1].adjClose! - histData[i].adjClose!
                oscInds[i].up = 0
            } else {
                oscInds[i].up = 0
                oscInds[i].down = 0
            }
            
            
            //reset sum values
            sumUp = 0
            sumDown = 0
            
            let lastAvgUp = oscInds[i+1].avgUp
            let lastAvgDown = oscInds[i+1].avgDown
            let currUp = oscInds[i].up
            let currDown = oscInds[i].down
            
            oscInds[i].avgUp = ( lastAvgUp * (rsiLength - 1) + currUp ) / rsiLength
            oscInds[i].avgDown = ( lastAvgDown * (rsiLength - 1) + currDown ) / rsiLength
            oscInds[i].RS = oscInds[i].avgUp / oscInds[i].avgDown
            oscInds[i].RSI = 100 - (100/(oscInds[i].RS+1))
            
            
            //get SotchRSI values and calculate StochRSI
            if i < dataSize - Int(rsiLength) - Int(stochLength) {
                
                var minRSI = oscInds[i].RSI
                var maxRSI = oscInds[i].RSI
                
                for j in 0 ..< Int(stochLength) {
                    
                    if oscInds[i+j].RSI < minRSI {
                        minRSI = oscInds[i+j].RSI
                    }
                    
                    if oscInds[i+j].RSI > maxRSI {
                        maxRSI = oscInds[i+j].RSI
                    }
                    
                }
                
                oscInds[i].stoch = ( oscInds[i].RSI - minRSI ) / ( maxRSI - minRSI)
                
                // get K
                if i < dataSize - Int(rsiLength) - Int(stochLength) - Int(smoothK) {
                    
                    //if i == dataSize - Int(rsiLength) - Int(stochLength) - Int(smoothK) {
                    
                    var sumStoch = Double(0)
                    
                    for j in 0 ..< Int(smoothK) {
                        
                        sumStoch += oscInds[i+j].stoch
                        
                    }
                    
                    oscInds[i].K = sumStoch / smoothK
                    
                    // } else {
                    //if-else comment out for use later as option smoothing. Current is SMA for K/D, can add option for EMA
                    // }
                    
                    if i < dataSize - Int(rsiLength) - Int(stochLength) - Int(smoothK) - Int(smoothD) {
                        
                        var sumStochD = Double(0)
                        
                        for j in 0 ..< Int(smoothD) {
                            
                            sumStochD += oscInds[i+j].K
                            
                        }
                        
                        oscInds[i].D = sumStochD / smoothD
                        
                    }
                }
            }
            

            
            //insert row if placeholder doesnt exist
            stockData.oscInds?.insert(oscInds[i], atIndex: 0)
            
    //        for j in 0 ..< 3 {
  //              print(oscInds[j].date, oscInds[j].K, oscInds[j].D)
   //         }
            
            /*
            if (100*oscInds[0].K) > strategy!.overBought {
                stock.status = "Sells"
            } else if (100*oscInds[0].K) < strategy!.overSold && oscInds[0].K > oscInds[1].K {
                stock.status = "Buys"
            } else {
                stock.status = "IND"
            }
             */
        
            
            
        } else if dateDiff == 0 && currPrice != nil {
            
  //          print("#2")
            
            //if histData already has placeholder, update current price
            if currPrice != nil && histData[0].date == "Placeholder" {
                
   //             print("updating placeholder value")
                histData[0].adjClose = currPrice
    
            }
            
            
            //append current price data if historial download doesnt have price and add placeholder for oscInds
            if currPrice != nil && histData[0].date != "Placeholder" {
                
    //            print("appeneding placeholder and setting value")
                
                let histInsert = HistDataPoint(date: "Placeholder", open: nil, high: nil, low: nil, close: nil, volume: nil, adjClose: currPrice)
                let indInsert = OscIndicators(date: "Placeholder", up: 0, down: 0, avgUp: 0, avgDown: 0, RS: 0, RSI: 0, stoch: 0, K: 0, D: 0, pt: 0 , CCI: 0)
                
                histData.insert(histInsert!, atIndex: 0)
                histData[0].adjClose = currPrice
                
                oscInds.insert(indInsert!, atIndex: 0)
                stockData.histData?.insert(histData[0], atIndex: 0)
                
            }
            
            
            
            //calculate last row in oscInds

            //set index of row needing updating
            let i = 0
            
            
            // for CCI calc: high and low are adjusted here
            
            //find multiply factor if any
            adj = 1
            
            if histData[i].close > 1.5*histData[i].adjClose! {
                
                adj = (histData[i].close!/histData[i].adjClose!)
                adj = round(adj)
                
            }
            
            //let cciHigh = histData[i].high!/adj
            // let cciLow = histData[i].low!/adj
            let cciClose = histData[i].adjClose
            //oscInds[i].pt = (cciHigh + cciLow + cciClose!)/3
            
            oscInds[i].pt = cciClose!
            // for CCI calc: get CCI
            
            //reset values for moving average and standard deviation
            ptMA = 0
            ptAD = 0
            
            // set initial moving average
            for j in 0 ..< Int(cciLength) {
                ptMA += oscInds[i+j].pt
            }
            
            ptMA = ptMA/cciLength
            
            // set average deviation
            for j in 0 ..< Int(cciLength) {
                ptAD += abs(oscInds[i+j].pt - ptMA)
            }
            
            ptAD = ptAD*(1/cciLength)
            
            oscInds[i].CCI = (oscInds[i].pt - ptMA)/(0.015*ptAD)
            
            //set "up" and "down" values
            if histData[i].adjClose > histData[i+1].adjClose {
                oscInds[i].up = histData[i].adjClose! - histData[i+1].adjClose!
                oscInds[i].down = 0
            } else if histData[i].adjClose < histData[i+1].adjClose {
                oscInds[i].down = histData[i+1].adjClose! - histData[i].adjClose!
                oscInds[i].up = 0
            } else {
                oscInds[i].up = 0
                oscInds[i].down = 0
            }
            
            
            //reset sum values
            sumUp = 0
            sumDown = 0
                
            let lastAvgUp = oscInds[i+1].avgUp
            let lastAvgDown = oscInds[i+1].avgDown
            let currUp = oscInds[i].up
            let currDown = oscInds[i].down
            
            oscInds[i].avgUp = ( lastAvgUp * (rsiLength - 1) + currUp ) / rsiLength
            oscInds[i].avgDown = ( lastAvgDown * (rsiLength - 1) + currDown ) / rsiLength
            oscInds[i].RS = oscInds[i].avgUp / oscInds[i].avgDown
            oscInds[i].RSI = 100 - (100/(oscInds[i].RS+1))
            
            
            //get SotchRSI values and calculate StochRSI
            if i < dataSize - Int(rsiLength) - Int(stochLength) {
                
                var minRSI = oscInds[i].RSI
                var maxRSI = oscInds[i].RSI
                
                for j in 0 ..< Int(stochLength) {
                    
                    if oscInds[i+j].RSI < minRSI {
                        minRSI = oscInds[i+j].RSI
                    }
                    
                    if oscInds[i+j].RSI > maxRSI {
                        maxRSI = oscInds[i+j].RSI
                    }
                    
                }
                
                oscInds[i].stoch = ( oscInds[i].RSI - minRSI ) / ( maxRSI - minRSI)
                
                // get K
                if i < dataSize - Int(rsiLength) - Int(stochLength) - Int(smoothK) {
                    
                    //if i == dataSize - Int(rsiLength) - Int(stochLength) - Int(smoothK) {
                    
                    var sumStoch = Double(0)
                    
                    for j in 0 ..< Int(smoothK) {
                        
                        sumStoch += oscInds[i+j].stoch
                        
                    }
                    
                    oscInds[i].K = sumStoch / smoothK
                    
                    // } else {
                    //if-else comment out for use later as option smoothing. Current is SMA for K/D, can add option for EMA
                    // }
                    
                    if i < dataSize - Int(rsiLength) - Int(stochLength) - Int(smoothK) - Int(smoothD) {
                        
                        var sumStochD = Double(0)
                        
                        for j in 0 ..< Int(smoothD) {
                            
                            sumStochD += oscInds[i+j].K
                            
                        }
                        
                        oscInds[i].D = sumStochD / smoothD
                        
                    }
                }
            }
            
 //           for j in 0 ..< 3 {
 //               print(oscInds[j].date, oscInds[j].K, oscInds[j].D)
 //           }

            
            //append updated row to stock.oscInds 
            if stockData.oscInds![0].date == "Placeholder" {
                //replace row if placeholder exists
                stockData.oscInds![0] = oscInds[i]
                
            } else {
                
                //insert row if placeholder doesnt exist
                stockData.oscInds?.insert(oscInds[i], atIndex: 0)
                
            }
            
            
            /*
            if (100*oscInds[0].K) > strategy!.overBought {
                stock.status = "Sells"
            } else if (100*oscInds[0].K) < strategy!.overSold && oscInds[0].K > oscInds[1].K {
                stock.status = "Buys"
            } else {
                stock.status = "IND"
            }
            */
            
            
        } //end if dayDiff is 0
        
        
        
    } else { //currPrice is nil, do full calculation [TODO: only do work past last iscInds hist date]
    
        //set minimum amount of data points needed for calculation
        var minDataNeeded = Int(0)
        if (rsiLength + stochLength + smoothD + smoothK) > cciLength {
            minDataNeeded = Int(rsiLength + stochLength + smoothD + smoothK)
            
        } else {
            minDataNeeded = Int(cciLength)
        }
        
        
        //initialize size of oscInds
        for _ in 0 ..< dataSize {
            let indPoint = OscIndicators(date: "Default", up: 0, down: 0, avgUp: 0, avgDown: 0, RS: 0, RSI: 0, stoch: 0, K: 0, D: 0, pt: 0 , CCI: 0)
            oscInds.append(indPoint!)
        }
        
        
        for i in (0 ..< dataSize).reverse() {
            //set date
            oscInds[i].date = histData[i].date!
        }
        

        
        /* Populate data in oscInds if enough data is present for calculation:
            1. set date
            2. set "up" and "down" values
            3. set "avgUp" and "avgDown"
            4. set "RS"
            5. set "RSI"
            6. set "K"
            7. set "D"
        */
        if dataSize > minDataNeeded {
            
            for i in (0 ..< dataSize).reverse() {
                
                
                // for CCI calc: high and low are adjusted here
                
                //find multiply factor if any 
                adj = 1
                
                if histData[i].close > 1.5*histData[i].adjClose! {
                    
                    adj = (histData[i].close!/histData[i].adjClose!)
                    adj = round(adj)
                
                }
                
      //        let cciHigh = histData[i].high!/adj
      //        let cciLow = histData[i].low!/adj
                let cciClose = histData[i].adjClose
                //oscInds[i].pt = (cciHigh + cciLow + cciClose!)/3
                
                oscInds[i].pt = cciClose!
                // for CCI calc: get CCI
                
                if i < dataSize - Int(cciLength) {
                    
                    //reset values for moving average and standard deviation
                    ptMA = 0
                    ptAD = 0
                    
                    // set initial moving average
                    if i <= dataSize - Int(cciLength) - 1 {
                        
                        for j in 0 ..< Int(cciLength) {
                            ptMA += oscInds[i+j].pt
                        }
                        
                        ptMA = ptMA/cciLength

                    }
                    
                    // set average deviation
                    for j in 0 ..< Int(cciLength) {
                        ptAD += abs(oscInds[i+j].pt - ptMA)
                    }

                    ptAD = ptAD*(1/cciLength)
                    
                    oscInds[i].CCI = (oscInds[i].pt - ptMA)/(0.015*ptAD)
//                    print(oscInds[i].date, oscInds[i].pt, ptMA, ptSD, oscInds[i].CCI)
                    

                }
                
                
                //set "up" and "down" values
                if i < dataSize-1 {
                    
                    if histData[i].adjClose > histData[i+1].adjClose {
                        oscInds[i].up = histData[i].adjClose! - histData[i+1].adjClose!
                        oscInds[i].down = 0
                    } else if histData[i].adjClose < histData[i+1].adjClose {
                        oscInds[i].down = histData[i+1].adjClose! - histData[i].adjClose!
                        oscInds[i].up = 0
                    } else {
                        oscInds[i].up = 0
                        oscInds[i].down = 0
                    }
                    
                }
                

                
                //makes sure data exists for averageing. Averaging type is EMA. Set all values for and including RSI
                if i < dataSize - Int(rsiLength) {
                    
                    //reset sum values
                    sumUp = 0
                    sumDown = 0
                    
                    //set initial average values
                    if i == dataSize - Int(rsiLength) - 1 {

                        //get sum of Up values in rsiLength
                        for j in 0 ..< Int(rsiLength) {
                            sumUp += oscInds[i+j].up

                        }
                        
                        oscInds[i].avgUp = sumUp/rsiLength
                        
                        for j in 0 ..< Int(rsiLength) {
                            sumDown += oscInds[i+j].down
                        }
                        
                        oscInds[i].avgDown = sumDown/rsiLength
                        
                        oscInds[i].RS = oscInds[i].avgUp / oscInds[i].avgDown
                        oscInds[i].RSI = 100 - (100/(oscInds[i].RS+1))

                    } else {
                        
                        let lastAvgUp = oscInds[i+1].avgUp
                        let lastAvgDown = oscInds[i+1].avgDown
                        let currUp = oscInds[i].up
                        let currDown = oscInds[i].down

                        oscInds[i].avgUp = ( lastAvgUp * (rsiLength - 1) + currUp ) / rsiLength
                        oscInds[i].avgDown = ( lastAvgDown * (rsiLength - 1) + currDown ) / rsiLength
                        oscInds[i].RS = oscInds[i].avgUp / oscInds[i].avgDown
                        oscInds[i].RSI = 100 - (100/(oscInds[i].RS+1))
                        
                        
                        //get SotchRSI values and calculate StochRSI
                        if i < dataSize - Int(rsiLength) - Int(stochLength) {
                            
                            var minRSI = oscInds[i].RSI
                            var maxRSI = oscInds[i].RSI
                            
                            for j in 0 ..< Int(stochLength) {
                                
                                if oscInds[i+j].RSI < minRSI {
                                    minRSI = oscInds[i+j].RSI
                                }
                                
                                if oscInds[i+j].RSI > maxRSI {
                                    maxRSI = oscInds[i+j].RSI
                                }
                            
                            }
                            
                            oscInds[i].stoch = ( oscInds[i].RSI - minRSI ) / ( maxRSI - minRSI)

                            // get K
                            if i < dataSize - Int(rsiLength) - Int(stochLength) - Int(smoothK) {
                            
                                //if i == dataSize - Int(rsiLength) - Int(stochLength) - Int(smoothK) {
                                    
                                var sumStoch = Double(0)
                                    
                                for j in 0 ..< Int(smoothK) {
                                    
                                    sumStoch += oscInds[i+j].stoch
                                    
                                }
                                    
                                oscInds[i].K = sumStoch / smoothK
                             
                               // } else {
                                    //if-else comment out for use later as option smoothing. Current is SMA for K/D, can add option for EMA
                               // }
                                
                                if i < dataSize - Int(rsiLength) - Int(stochLength) - Int(smoothK) - Int(smoothD) {
                                    
                                    var sumStochD = Double(0)
                                    
                                    for j in 0 ..< Int(smoothD) {
                                        
                                        sumStochD += oscInds[i+j].K
                                        
                                    }
                                    
                                    oscInds[i].D = sumStochD / smoothD
                                    
                                }
                            }
                        }
                    }
                }
            }
            
            //add indicator data to stock
            
            stockData.oscInds = oscInds
            
        }
    
    }
    
    
    // MARK: Strategy Conditions
    
    if stockData.oscInds?.count > 0 {
    
        if (100*oscInds[0].K) > strategy!.overBought && oscInds[0].K < oscInds[1].K {
            
            stock.status = "Sells"
            
        }
        
        if (100*oscInds[0].K) < strategy!.overSold && oscInds[0].K > oscInds[1].K && oscInds[0].K > oscInds[0].D {
            
            stock.status = "Buys"

            
        }
        
        if crossoverOversoldK(oscInds, strategy: strategy!) {
            
            stock.status = "Buys"
            
        }
        
        if crossoverKD(oscInds) {
            
            stock.status = "Sells"
            
        }
        
        if crossoverDK(oscInds, strategy: strategy!){
         
            stock.status = "Buys"
            
        }
        
        if oscInds[1].K > oscInds[0].K {
            
            stock.status = "Sells"
        }
        
        if stock.status != "Sells" && stock.status != "Buys" {
            
            stock.status = "IND"
            
        }
        

        
        
       // for i in 0 ..< stockData.histData!.count {
       //     print(stockData.histData![i].date!, ",", stockData.histData![i].adjClose, ",", stockData.oscInds![i].date)
       // }
        
        print("Calculated all data to date ", stockData.oscInds![0].date, stock.name, "is", stock.status!, "and k[0] =", (100*oscInds[0].K), "and k[1] =", (100*oscInds[1].K), "and CCI=", oscInds[0].CCI)
        
    } else {
        
        print("OSCINDS count is 0", stock.name)
        
    }


    return stock
    
}

func crossoverKD(oscInds: [OscIndicators]) -> Bool {
    
    let k0 = oscInds[0].K
    let k1 = oscInds[1].K
    let d0 = oscInds[0].K
    let d1 = oscInds[0].K
    
    if k1 > d1 && k0 < d0 {
        
        return true
        
    } else {
        
        return false
    }
    
}


func crossoverDK(oscInds: [OscIndicators], strategy: Strategy) -> Bool {
    
    let k0 = oscInds[0].K
    let k1 = oscInds[1].K
    let d0 = oscInds[0].K
    let d1 = oscInds[0].K
    let oversold = strategy.overSold/100
    
    if k1 < d1 && k0 > d0 && k1 < oversold {
        
        return true
        
    } else {
        
        return false
    }
    
}

func crossoverOversoldK(oscInds: [OscIndicators], strategy: Strategy) -> Bool {
    
    let k0 = oscInds[0].K
    let k1 = oscInds[1].K
    let oversold = (strategy.overSold)/100

    
    if k0 > oversold && k1 < oversold {
        
        return true
        
    } else {
        
        return false
    }
    
}
*/
