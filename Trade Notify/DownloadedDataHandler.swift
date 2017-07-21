//
//  DownloadedDataHandler.swift
//  Trade Notify
//
//  Created by Aaron Stein on 5/18/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import UIKit
import RealmSwift

func saveStockPrice(data: String)
{
    var datas: [String]
    datas = data.componentsSeparatedByString(",")
    let nameRange = datas[1].startIndex.advancedBy(1) ..< datas[1].endIndex.advancedBy(-1)
    let pChangeRange = datas[5].startIndex.advancedBy(1) ..< datas[5].endIndex.advancedBy(-2)
    let name = datas[1].substringWithRange(Range<String.Index>(nameRange))
    let price = Double(datas[0])
    let bid = Double(datas[3])
    let ask = Double(datas[2])
    let change = Double(datas[4])
    let pChange = datas[5].substringWithRange(Range<String.Index>(pChangeRange))
    let stocks = getStock(name)
    let open = Double(datas[6])
    let low = Double(datas[7])
    let high = Double(datas[8].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))
    
    if stocks!.count > 0
    {
        let stock = stocks![0]
        let histPoint = HistData()
        histPoint.stock = stock
        let calendar = getUTC().calendar
        let components = getUTC().components
        let date = calendar!.dateFromComponents(components!)
        
        if components!.hour == 13
        {
            if components?.minute < 30 {
                components!.day -= 1
                components!.weekday -= 1
            }
        }
        else if components!.hour < 13
        {
            components!.day -= 1
            components!.weekday -= 1
        }
        
        components!.hour = 7
        components!.minute = 0
        components!.second = 0
        
        let histDate = calendar!.dateFromComponents(components!)
        
        if components?.weekday > 1
        {
            if (price != nil && high != nil && low != nil && open != nil)
            {
                histPoint.adjClose = price!
                histPoint.close = price!
                histPoint.date = histDate!
                histPoint.high = high!
                histPoint.low = low!
                histPoint.open = open!
                histPoint.stock = stock
                histPoint.save()
            }
        }
        //print("price", price)
        if price != nil
        {
            stock.updateQuote(price!, bid: bid!, ask: ask!, change: change!, pChange: pChange, updated: date!)
        }
    }
}

func saveStockHistPrice(data: String, url: String)
{
    let rows = data.componentsSeparatedByString("\n")
    let starIndex = url.lowercaseString.characters.indexOf("=")
    let endIndex = url.lowercaseString.characters.indexOf("&")
    let prefix = url.substringToIndex(starIndex!)
    let encapsul = url.substringToIndex(endIndex!)
    let advPre = (prefix.characters.count)+1
    let advEnc = (encapsul.characters.count)
    let range = url.startIndex.advancedBy(advPre) ..< url.startIndex.advancedBy(advEnc)
    let name = url.substringWithRange(Range<String.Index>(range))
    let stock = getStock(name)![0]
    //print("downloadDataHandler stockName", stock.name)
    //let som = saveOnMain()
    //var histData = [HistData]()
    
    for i in 1 ..< (rows.count-1)
    {
        let splitRow = rows[i].componentsSeparatedByString(",")
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        let dateString = splitRow[0]
        let date = dateFormat.dateFromString(dateString)
        let open = Double(splitRow[1])
        let high = Double(splitRow[2])
        let low = Double(splitRow[3])
        let close = Double(splitRow[4])
        let volume = Double(splitRow[5])
        let adjClose = Double(splitRow[6])
        let histPoint = HistData()
        histPoint.adjClose = adjClose!
        histPoint.close = close!
        histPoint.date = date!
        histPoint.high = high!
        histPoint.low = low!
        histPoint.open = open!
        histPoint.volume = volume!
        histPoint.stock = stock
        histPoint.save()
        //histData.append(histPoint)
    }
    
    //som.saveHistDataMain(name, histData: histData)
    
    if rows.count > 30
    {
        let btm = BacktestManager()
        btm.addStock(name)
    }
}






