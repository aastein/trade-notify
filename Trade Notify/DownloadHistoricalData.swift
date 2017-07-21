//
//  DownloadHistoricalData.swift
//  Trade Notify
//
//  Created by Aaron Stein on 4/4/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import UIKit

class DownloadHistoricalData {
    
    var histData = [HistDataPoint]()
    var stocks = [Stock]()
    let stockName = "CNAT"
    let urlString = "http://ichart.finance.yahoo.com/table.csv?s=" + stockName
        
        
    
    
    
    
    
    
    
    
    /*
    var downloadsSession: NSURLSession = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: downloadsSession, delegateQueue: nil)
        return session
    }()

    
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        do {
            let Data = try String(contentsOfURL: location, encoding: NSUTF8StringEncoding)
            let delimiter: Character = ","
            print(Data)
            print(delimiter)
            
        } catch {
            print(error)
        }
    }

    func startDownload(stock: Stock) {
        if let urlString = stock.url, url =  NSURL(string: urlString) {
            
            let download = Download(url: urlString)
            download.downloadTask = downloadsSession.downloadTaskWithURL(url)
            download.downloadTask!.resume()
            
        }
        
    }
    
    func getHistData(stocks: [Stock]) {
        
        //download stock latest prices
        for i in 0..<(stocks.count) {
            let stockName = stocks[i].name
            stocks[i].url = String("http://finance.yahoo.com/d/quotes.csv?s=\(stockName)&f=ps")
            startDownload(stocks[i])
        }
    }
    
    getHistData(stocks)
 */
    
    

}


