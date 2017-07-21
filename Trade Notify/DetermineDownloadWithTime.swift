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

func shouldDownloadQuote(stock: String?) -> Bool {
    
    let stock = getStock(stock!)
    let utc = getUTC().components
    let lastUpdated = stock![0].upated
    
    if utc?.weekday < 2 || utc?.weekday > 5
    { // weekend
        
        print("\(stock![0].name) LAST UPDATED:", lastUpdated)
        
    } else
    { //weekday
        
    }
    
    
    
    
    return true
    
}

func getUTC() -> (components: NSDateComponents?, calendar: NSCalendar?) {
    
    let date = NSDate()
    
    if let utcCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    {
        if let utcTimeZone = NSTimeZone(abbreviation: "UTC")
        {
            
            utcCalendar.timeZone = utcTimeZone
            
            let utcDateComponents = utcCalendar.components([.Minute, .Hour, .Weekday,.Day , .Month , .Year], fromDate: date)
            
            // Create string of form "yyyy-mm-dd hh:mm:ss"
            print("getUTC@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
            print( NSString(format: "%04u-%02u-%02u %02u:%02u:%02u",
                                             UInt(utcDateComponents.year),
                                             UInt(utcDateComponents.month),
                                             UInt(utcDateComponents.day),
                                             UInt(utcDateComponents.hour),
                                             UInt(utcDateComponents.minute),
                                             UInt(utcDateComponents.second)))
            return (utcDateComponents, utcCalendar)
        }
    }
    
    return (nil, nil)
}