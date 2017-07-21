//
//  checkUpdateCoreData.swift
//  Trade Notify
//
//  Created by Aaron Stein on 5/4/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import UIKit
import RealmSwift

func getLastCoreTradeDate (lasDownloadDate: NSDate!) -> NSDate? {
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "MM-dd-yyyy"
    
    let startDate = NSCalendar.currentCalendar().components([.Weekday,.Day , .Month , .Year], fromDate: NSDate())
    if startDate.weekday > 2 && startDate.weekday < 7
    {
        return NSDate()
    }
    else
    {
        for i in 1 ... 3
        {
            let newDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: (-1*i), toDate: NSDate(), options: NSCalendarOptions(rawValue: 0))!
            let returnCalendar = NSCalendar.currentCalendar().components([.Weekday,.Day , .Month , .Year], fromDate: newDate)
            if returnCalendar.weekday == 6
            {
                let dateString = String("\(returnCalendar.month)-\(returnCalendar.day)-\(returnCalendar.year)")
                return dateFormatter.dateFromString( dateString )!
            }
        }
    }
    return nil
}

func setHistDataUrl (stocks: Results<Stock>) -> [String]
{
    var urls = [String]()
    var lastDownloadDate = NSDate()
    var lastTradeDate = NSDate()
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"

    for i in 0 ..< stocks.count
    {
        let stockName = stocks[i].name
        let histData = stocks[i].histData.sorted("date", ascending: false)

        if histData.count > 0
        {
            lastDownloadDate = histData[0].date
        }
        else
        {
            let newDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: (-665), toDate: NSDate(), options: NSCalendarOptions(rawValue: 0))!
            let returnCalendar = NSCalendar.currentCalendar().components([.Weekday,.Day , .Month , .Year], fromDate: newDate)
            let dateString = String("\(returnCalendar.year)-\(returnCalendar.month)-\(returnCalendar.day)")
            lastDownloadDate = dateFormatter.dateFromString( dateString )!
        }
        
        lastTradeDate = getLastCoreTradeDate(lastDownloadDate)!
        let dateDiff = NSCalendar.currentCalendar().components(NSCalendarUnit.Day, fromDate: lastDownloadDate, toDate: lastTradeDate, options: [])
        let dayDiffDLToTrade = dateDiff.day

        let todayDateDiff = NSCalendar.currentCalendar().components(NSCalendarUnit.Day, fromDate: NSDate(), toDate: lastTradeDate, options: [])
        let dayDiffTodayToTrade = todayDateDiff.day //days from last historical data to last trade date
        
        let utcComponents = getUTC().components
        let currentTime = utcComponents!.hour

        if dayDiffDLToTrade > 1
        {
            let downloadFromDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: (-1*dayDiffDLToTrade), toDate: lastTradeDate, options: NSCalendarOptions(rawValue: 0))!
            let dateComponents = NSCalendar.currentCalendar().components([.Weekday,.Day , .Month , .Year], fromDate: downloadFromDate)
            let dateString = String("\(dateComponents.year)-\(Int(dateComponents.month)-1)-\(dateComponents.day)")
            var date = dateString.componentsSeparatedByString("-")
            
            if date[2].characters.count < 2
            {
                let newMonth = "0" + date[2]
                date[2] = newMonth
            }
            
            if date[1].characters.count < 2
            {
                let newDay = "0" + date[1]
                date[1] = newDay
            }

            urls.append("http://ichart.finance.yahoo.com/table.csv?s=\(stockName)&a=\(date[1])&b=\(date[2])&c=\(date[0])&g=d&ignore=.csv")
          
        }
        else if dayDiffDLToTrade == 1 && dayDiffTodayToTrade == 0 && currentTime >= 22
        {
            let downloadFromDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: 0, toDate: lastTradeDate, options: NSCalendarOptions(rawValue: 0))!
            let dateComponents = NSCalendar.currentCalendar().components([.Weekday,.Day , .Month , .Year], fromDate: downloadFromDate)
            let dateString = String("\(dateComponents.year)-\(Int(dateComponents.month)-1)-\(dateComponents.day)")
            var date = dateString.componentsSeparatedByString("-")
                    print("non formatted date is \(date)")
            
            if date[0].characters.count < 2
            {
                let newMonth = "0" + date[0]
                date[0] = newMonth
            }
            
            if date[1].characters.count < 2
            {
                let newDay = "0" + date[1]
                date[1] = newDay
            }
        
            urls.append("http://ichart.finance.yahoo.com/table.csv?s=\(stockName)&a=\(date[1])&b=\(date[2])&c=\(date[0])&g=d&ignore=.csv")
            
        }
        else if dayDiffDLToTrade == 1 && dayDiffTodayToTrade != 0
        {
            let downloadFromDate = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: (-1*dayDiffDLToTrade), toDate: lastTradeDate, options: NSCalendarOptions(rawValue: 0))!
            let dateComponents = NSCalendar.currentCalendar().components([.Weekday,.Day , .Month , .Year], fromDate: downloadFromDate)
            let dateString = String("\(dateComponents.year)-\(Int(dateComponents.month)-1)-\(dateComponents.day)")
            var date = dateString.componentsSeparatedByString("-")
            
            if date[0].characters.count < 2
            {
                let newMonth = "0" + date[0]
                date[0] = newMonth
            }
            
            if date[1].characters.count < 2
            {
                let newDay = "0" + date[1]
                date[1] = newDay
            }
            
            urls.append("http://ichart.finance.yahoo.com/table.csv?s=\(stockName)&a=\(date[1])&b=\(date[2])&c=\(date[0])&g=d&ignore=.csv")
            
        }
        else if histData.count < 3
        {
            let dateString = String("\(utcComponents!.year)-\(Int(utcComponents!.month)-1)-\(utcComponents!.day)")
            var date = dateString.componentsSeparatedByString("-")
            
            if date[0].characters.count < 2
            {
                let newMonth = "0" + date[0]
                date[0] = newMonth
            }
            
            if date[1].characters.count < 2
            {
                let newDay = "0" + date[1]
                date[1] = newDay
            }
            
            urls.append("http://ichart.finance.yahoo.com/table.csv?s=\(stockName)&a=\(date[1])&b=\(date[2])&c=\(date[0])&g=d&ignore=.csv")
        }
    }
    return urls
}