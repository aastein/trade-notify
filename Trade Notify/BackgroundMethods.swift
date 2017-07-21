//
//  BackgroundMethods.swift
//  Trade Notify
//
//  Created by Aaron Stein on 6/5/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import UIKit
import RealmSwift


func downloadQuotesBackground()
{
    let downloadManager = DownloadManager()
    let stocks = getStock(nil)
    for i in (0..<(stocks!.count)).reverse()
    {
        let stockName = stocks![i].name
        let shouldDownload = shouldDownloadQuote(stockName)
        if shouldDownload {
            let urlStrings = ["http://download.finance.yahoo.com/d/quotes.csv?s=\(stockName)&f=l1sabc1p2ogh"]
            let urls = urlStrings.map { NSURL(string: $0)! }
            // print("DOWNLOADING Quote by \(urlStrings[0])")
            for url in urls
            {
                downloadManager.addDownload(url)
            }
        }
    }
    updateIndDataBackground()
}

func updateIndDataBackground()
{
    var stocks = getStock(nil)
    var sells = [String]()
    var buys = [String]()
    
    for i in 0 ..< (stocks?.count)!
    {
        stocks = getStock(nil)
        if stocks!.count > i && stocks![i].hasData == true
        {
            checkSetOscData(stocks![i].name)
            
        }
    }
    
    let newStock = getStock(nil)
    
    for stock in newStock!
    {
        if stock.status != stock.lastStatus
        {
            if stock.status == "Buy"
            {
                buys.append(stock.name)
            }
            else if stock.status == "Sell" && stock.listID == "Portfolio"
            {
                sells.append(stock.name)
            }
        }
    }
    
    if buys.count > 0 { scheduleLocalBuyNotification(buys) }
    if sells.count > 0 { scheduleLocalSellNotification(sells) }
}

func setupNotificationSettings()
{
    let notificationSettings: UIUserNotificationSettings! = UIApplication.sharedApplication().currentUserNotificationSettings()
   
    if (notificationSettings.types == UIUserNotificationType.None)
    {
        let notificationTypes: UIUserNotificationType = UIUserNotificationType.Alert
        
        let buyAction = UIMutableUserNotificationAction()
        buyAction.identifier = "buy"
        buyAction.title = "Buy"
        buyAction.activationMode = UIUserNotificationActivationMode.Foreground
        buyAction.destructive = false
        buyAction.authenticationRequired = true
    
        let sellAction = UIMutableUserNotificationAction()
        sellAction.identifier = "sell"
        sellAction.title = "Sell"
        sellAction.activationMode = UIUserNotificationActivationMode.Foreground
        sellAction.destructive = false
        sellAction.authenticationRequired = true
        
        let badStratAction = UIMutableUserNotificationAction()
        badStratAction.identifier = "badStrat"
        badStratAction.title = "Warning"
        badStratAction.activationMode = UIUserNotificationActivationMode.Foreground
        badStratAction.destructive = false
        badStratAction.authenticationRequired = true
    
        let buyArray = NSArray(objects: buyAction)
    
        let sellArray = NSArray(objects: buyAction)
        
        let badStratArray = NSArray(objects: badStratAction)
    
        let buyCatagory = UIMutableUserNotificationCategory()
        buyCatagory.identifier = "buyCategory"
        buyCatagory.setActions(buyArray as? [UIUserNotificationAction], forContext: UIUserNotificationActionContext.Default)
        buyCatagory.setActions(buyArray as? [UIUserNotificationAction], forContext: UIUserNotificationActionContext.Minimal)
    
        let sellCatagory = UIMutableUserNotificationCategory()
        sellCatagory.identifier = "sellCategory"
        sellCatagory.setActions(sellArray as? [UIUserNotificationAction], forContext: UIUserNotificationActionContext.Default)
        sellCatagory.setActions(sellArray as? [UIUserNotificationAction], forContext: UIUserNotificationActionContext.Minimal)
        
        let badStratCatagory = UIMutableUserNotificationCategory()
        badStratCatagory.identifier = "badStratCatagory"
        badStratCatagory.setActions(badStratArray as? [UIUserNotificationAction], forContext: UIUserNotificationActionContext.Default)
        badStratCatagory.setActions(badStratArray as? [UIUserNotificationAction], forContext: UIUserNotificationActionContext.Minimal)
        
        let categoriesForSettings = NSSet(objects: buyCatagory, sellCatagory, badStratCatagory)
        
        let newNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: categoriesForSettings as? Set<UIUserNotificationCategory>)
        
        UIApplication.sharedApplication().registerUserNotificationSettings(newNotificationSettings)
    }
}

func scheduleLocalBuyNotification(buys: [String])
{
    let allBuys = buys.joinWithSeparator(", ")
    let localNotification = UILocalNotification()
    localNotification.fireDate = NSDate()
    localNotification.alertBody = "Buy: " + allBuys
    localNotification.alertAction = "Buy"
    localNotification.category = "buyCatagory"
    UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
}

func scheduleLocalSellNotification(sells: [String])
{
    let allSells = sells.joinWithSeparator(", ")
    let localNotification = UILocalNotification()
    localNotification.fireDate = NSDate()
    localNotification.alertBody = "Sell: " + allSells
    localNotification.alertAction = "Sell"
    localNotification.category = "sellCatagory"
    UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
}

func scheduleLocalBadStratNotification(stockName: String)
{
    let localNotification = UILocalNotification()
    localNotification.fireDate = NSDate()
    localNotification.alertBody = "No good strategy for " + stockName
    localNotification.category = "badStratCatagory"
    UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
}
