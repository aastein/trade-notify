//
//  Downloader.swift
//  Trade Notify
//
//  Created by Aaron Stein on 3/29/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import UIKit
import RealmSwift

class Download: NSObject {

    var url: String
    var downloadTask: NSURLSessionDownloadTask?
    
    init(url: String) {
        self.url = url
    }
    
}


public class UpdatePriceSession {
    
    var downloadManager = DownloadManager()
    var quoteTimerStarted = false
    var histTimerStarted = false
    var quoteTimer: dispatch_source_t!
    var histTimer: dispatch_source_t!
    
    @objc public func downloadQuotes(stockName: String?)
    {
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue,
        {
            if stockName != nil {
                let urlStrings = ["http://download.finance.yahoo.com/d/quotes.csv?s=\(stockName!)&f=l1sabc1p2ogh"]
                let urls = urlStrings.map { NSURL(string: $0)! }
                print("DOWNLOADING Quote by \(urlStrings[0])")
                for url in urls
                {
                    self.downloadManager.addDownload(url)
                }
            } else {
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
                            self.downloadManager.addDownload(url)
                        }
                    }
                }
            }
        })
    }
    
    @objc public func downloadHistData(stockName: String?)
    {
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue,
        {
            var stocks: Results<Stock>?
            if stockName != nil {
                stocks = getStock(stockName!)
            } else {
                stocks = getStock(nil)
            }
            let urlStrings = setHistDataUrl(stocks!)
            let urls = urlStrings.map { NSURL(string: $0)! }
            for url in urls
            {
                self.downloadManager.addDownload(url)
            }
        })
    }
    
    public func startHistTimer ()
    {
        if histTimerStarted == false
        {
            histTimerStarted = true
            
            let queue = dispatch_queue_create("com.domain.app.timer", nil)
            histTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)
            dispatch_source_set_timer(histTimer, DISPATCH_TIME_NOW, 360 * NSEC_PER_SEC, 1 * NSEC_PER_SEC) // every 10 seconds, with leeway of 1 second
            dispatch_source_set_event_handler(histTimer) {
                self.downloadHistData(nil)
            }
            dispatch_resume(histTimer)
        }

    }
    
    public func startQuoteTimer ()
    {
        if quoteTimerStarted == false
        {
            quoteTimerStarted = true
            
            let queue = dispatch_queue_create("com.domain.app.timer", nil)
            quoteTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)
            dispatch_source_set_timer(quoteTimer, DISPATCH_TIME_NOW, 20 * NSEC_PER_SEC, 1 * NSEC_PER_SEC) // every 10 seconds, with leeway of 1 second
            dispatch_source_set_event_handler(quoteTimer) {
                self.downloadQuotes(nil)
            }
            dispatch_resume(quoteTimer)
        }
    }
    
    public func stopHistTimer ()
    {
        dispatch_source_cancel(histTimer)
        histTimer = nil
    }

    public func stopQuoteTimer ()
    {
        dispatch_source_cancel(quoteTimer)
        quoteTimer = nil
        
    }
}








