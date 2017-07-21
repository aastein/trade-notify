//
//  DetermineDownloadWithTime.swift
//  Trade Notify
//
//  Created by Aaron Stein on 5/22/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import UIKit
import RealmSwift

//markts live at 13:30 UTC
//markets close at 20:00 UTC
//assume histData is published +2 hr after market closes
// UTC = 7h+PTC

// Returns Bool for should download quote data for a stock.
func shouldDownloadQuote(stock: String?) -> Bool {
    
    let stock = getStock(stock!)
    let components = getUTC().components
    let calendar = getUTC().calendar
    let nowDate = calendar?.dateFromComponents(components!)
    var lastUpdated = NSDate()
    
    if stock!.count > 0
    {
        lastUpdated = stock![0].upated
    }
    
    let diff = hourDiff(nowDate!, updated: lastUpdated, calendar: calendar!)
    //print("diff = ", diff)
    //print("weekday", components?.weekday)
    
    if diff > 4
    {
       // print("DL ALLOWS BECAUSE DIFF = \(diff)")
        return true
    }
    
    if components?.weekday > 1
    { //weekday
        if components?.hour >= 13 && components?.hour <= 22
        {
            if components?.hour == 13 && components?.minute < 30 {
             //   print("dl not allowed 1")
                return false
            }
            //print("DL ALLOWED BECAUSE COMPONENTS.HOUR = \(components?.hour)")
            return true
        } else
        {
           // print("dl not allowed 2")
            return false
        }
    }
   
    return false
}

// Returns how many days of indicator data needs to be calculated and if markets are live
func daysToCalculate(stockName: String) -> Int {
    
    var daysToCalc = Int(0)
    let stock = getStock(stockName)![0]
    let oscDataCount = stock.oscData.count
    let histDataCount = stock.histData.count

    if histDataCount < 1
    {
        return daysToCalc
    }
    
    if oscDataCount < 1
    {
        return histDataCount
    }
    
    daysToCalc = histDataCount - oscDataCount
    
    return daysToCalc
}

// Returns UTC Calendar and Components at current Date in Calendar
func getUTC() -> (components: NSDateComponents?, calendar: NSCalendar?)
{
    let date = NSDate()
    
    if let utcCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    {
        if let utcTimeZone = NSTimeZone(abbreviation: "UTC")
        {
            utcCalendar.timeZone = utcTimeZone
            let utcDateComponents = utcCalendar.components([.Minute, .Hour, .Weekday,.Day , .Month , .Year], fromDate: date)
            return (utcDateComponents, utcCalendar)
        }
    }
    return (nil, nil)
}

// Returns hour diss between today and updated.
func hourDiff (today: NSDate, updated: NSDate, calendar: NSCalendar) -> Int {
    
    var diff = 0
    
   // print("========hourDiffCalc=======")
   // print("from", updated)
   // print("to", today)
    
    diff = calendar.components(NSCalendarUnit.Hour, fromDate: updated, toDate: today, options: []).hour
    
    return diff
}

// Returns true is market is live, returns false is market is not live
func isMarketLive() -> Bool {
    
    let components = getUTC().components
    
    if components?.weekday < 2 || components?.weekday > 5
    { // weekend
        return false
    } else
    { //weekday
        if components?.hour >= 13 && components?.hour <= 22
        {
            if components?.hour == 13 && components?.minute < 30 {
                return false
            }
            return true
        } else
        {
            return false
        }
    }
}

func getLastTradeDate() -> NSDate {
    
    let utc = getUTC()
    let comp = utc.components!
    let cal = utc.calendar!
    comp.hour = 7
    comp.minute = 0
    comp.second = 0
    
    if comp.weekday == 1
    { // Sunday
        comp.day -= 2
        return cal.dateFromComponents(comp)!
    } else if comp.weekday == 2
    { // Monday
        comp.day -= 3
        return cal.dateFromComponents(comp)!
    } else
    { //Last trade date is previous day
        comp.day -= 1
        return cal.dateFromComponents(comp)!
    }
}

func isHoliday() -> Bool
{
    let cal = getUTC()
    let calendar = cal.calendar!
    let components = cal.components!
    
    if components.hour <= 7
    {
        components.day -= 1
    }
    
    components.hour -= 7

    let h1Month = 1
    let h1Day = 1
    let h2Month = 1
    let h2Day = 18
    let h3Month = 2
    let h3Day = 15
    let h4Month = 3
    let h4Day = 25
    let h5Month = 5
    let h5Day = 30
    let h6Month = 7
    let h6Day = 4
    let h7Month = 9
    let h7Day = 5
    let h8Month = 11
    let h8Day = 24
    let h9Month = 11
    let h9Day = 25
    let h10Month = 12
    let h10Day = 26
    
    let h1Components = components
    h1Components.month = h1Month
    h1Components.day = h1Day
    
    let h2Components = components
    h2Components.month = h2Month
    h2Components.day = h2Day
    
    let h3Components = components
    h3Components.month = h3Month
    h3Components.day = h3Day
    
    let h4Components = components
    h4Components.month = h4Month
    h4Components.day = h4Day
    
    let h5Components = components
    h5Components.month = h5Month
    h5Components.day = h5Day
    
    let h6Components = components
    h6Components.month = h6Month
    h6Components.day = h6Day
    
    let h7Components = components
    h7Components.month = h7Month
    h7Components.day = h7Day
    
    let h8Components = components
    h8Components.month = h8Month
    h8Components.day = h8Day
    
    let h9Components = components
    h9Components.month = h9Month
    h9Components.day = h9Day
    
    let h10Components = components
    h10Components.month = h10Month
    h10Components.day = h10Day
    
    let h1 = calendar.dateFromComponents(h1Components)
    let h2 = calendar.dateFromComponents(h2Components)
    let h3 = calendar.dateFromComponents(h3Components)
    let h4 = calendar.dateFromComponents(h4Components)
    let h5 = calendar.dateFromComponents(h5Components)
    let h6 = calendar.dateFromComponents(h6Components)
    let h7 = calendar.dateFromComponents(h8Components)
    let h8 = calendar.dateFromComponents(h8Components)
    let h9 = calendar.dateFromComponents(h9Components)
    let h10 = calendar.dateFromComponents(h10Components)
    
    //date/time in PTC
    let now = calendar.dateFromComponents(components)
    
    if ( now == h1 || now == h2 || now == h3 || now == h4 || now == h5 || now == h6 || now == h7 || now == h8 || now == h9 || now == h10 )
    {
        print("TODAY IS HOLIDAY", h5, now)
        return true
    }
    
    
    return false
}












