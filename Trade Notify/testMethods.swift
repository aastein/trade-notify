//
//  testMethods.swift
//  Trade Notify
//
//  Created by Aaron Stein on 5/21/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import UIKit

func makeStockList(priceUpdater: UpdatePriceSession){
    
    var watchList = ["AA", "AAPL", "ABBV", "ABX", "AIG", "AKER", "AMD", "AMBR", "AN", "ANFI", "APC", "APIC", "APPS", "APTO", "AXP", "BAC", "BAX", "BBT", "BK", "BP", "BTG", "C", "CBAY", "CCL", "CHK", "CL", "CMA", "CMCSA", "CNIT", "CNX", "COP", "CSX", "CWCO", "CZR", "DAL", "DB", "DOW", "DVN", "DX", "EMC", "ENDP", "EWY", "F", "FB", "FCX", "FF" , "FOSL", "FOXA", "GE", "GM", "GNVC", "GPRO", "GS", "GTXI", "HAL", "HES", "HLT", "HST", "INTC", "JCI", "JD", "JPM" , "JVA", "KEY", "KKD", "KMI", "KO", "KR",  "LVS" , "MAR", "MAT", "MCUR", "MDLZ", "MET", "MGT", "MO", "MOH", "MPC", "MS", "MSFT", "MTU", "NBIX", "NEM", "NEOT", "NKE","NM", "NVDA", "OAS", "OIL", "OGXI", "ORCL", "ORIG", "PAAS", "PBR", "PFE", "PLD", "PYPL", "QQQ", "RAI", "RF", "RIG", "SBUX", "SIRI", "SKX", "SKY", "SMFG", "SMMT", "SPY", "SRPT", "STI", "STV", "STX", "SUNW", "SWHC", "SWN", "SYF", "TGT", "TROV", "TWTR", "URI", "USB", "UUP", "VALE", "VIAB", "VLO", "VRX", "WFC", "WLL", "WMT", "X", "YHOO", "CNAT", "CASI", "KERX", "JWN", "HHS", "TCS", "MRK", "AAL", "CSCO", "EBAY", "IGA", "LUV",  "ZN", "TXN", "XON", "QCOM", "SCHW", "UAL", "MRO", "UA", "CBS", "DFS", "GME", "SGYPW", "SGYP", "TRP", "KKD", "HK", "DRAM", "GEVO", "VMRI", "TRQ", "CNXR", "VGX", "AUMN", "SKLN" ]
    
   // var portfolio = []
    
    for i in 0 ..< watchList.count {
        let stock = Stock(value: ["name" : watchList[i], "listID" : "Watch List"])
        stock.save()
        priceUpdater.downloadHistData(watchList[i])
    }
    
    //for i in 0 ..< portfolio.count {
   // saveStock(portfolio[i], strategy: getStrat(nil)![0].name, listID: "Portfolio", status: nil, price: nil, bid: nil, ask: nil, change: nil, pChange: nil, updated: nil, k: nil, d: nil, cci: nil, sellPrice: nil, buyPrice: nil, hasData: false, progress: nil)
   // }
}