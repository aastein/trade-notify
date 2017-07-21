//
//  ViewController.swift
//  Trade Notify
//
//  Created by Aaron Stein on 3/25/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import UIKit
import RealmSwift
import Charts

class MainMenuViewController: UIViewController, ChartViewDelegate
{
    @IBOutlet weak var userPerfChart: LineChartView!
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var selectedPriceLabel: UILabel!
    @IBOutlet weak var buysButton: UIButton!
    @IBOutlet weak var sellsButton: UIButton!
    @IBOutlet weak var portfolioButton: UIButton!
    @IBOutlet weak var watchlistButton: UIButton!
    @IBOutlet weak var performanceButton: UIButton!
    @IBOutlet weak var notificationsButton: UIButton!

    var stockName = ""
    var updateIndTimer = NSTimer()
    var updateHistTimer = NSTimer()
    var saveTimer = NSTimer()
    var isCalculatingOsc = false
    var freshStart = true
    var stocks: Results<Stock>?
    var strats: Results<Strat>?
    var indUpdater = UpdateIndSession()
    var priceUpdater = UpdatePriceSession()
    var buttonColor = UIColor(red: 43/255, green: 255/255, blue: 133/255, alpha: 1)
    var normalColor = UIColor(red: 9/255, green: 18/255, blue: 19/255, alpha: 1)
    var highlightColor = UIColor(red: 4/255, green: 8/255, blue: 9/255, alpha: 1)
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle
    {
        return UIStatusBarStyle.LightContent
    }

    func setupChart()
    {
        selectedDateLabel.text = ""
        selectedPriceLabel.text = ""
        selectedDateLabel.textColor = UIColor(white: 1, alpha: 1)
        selectedPriceLabel.textColor = UIColor(white: 1, alpha: 1)
        userPerfChart.delegate = self
        setPerfChart(userPerfChart)
    }
    
    func startTimers()
    {
        indUpdater.startTimer()
        priceUpdater.downloadManager.queue.maxConcurrentOperationCount = 3
        priceUpdater.startQuoteTimer()
        priceUpdater.startHistTimer()
    }
    
    func setButtonStyles()
    {
        let borderWidth = CGFloat(0.3)
        let borderColor = UIColor.darkGrayColor().CGColor
        
        buysButton.layer.borderWidth = borderWidth
        buysButton.layer.borderColor = borderColor
        buysButton.backgroundColor = normalColor
        
        sellsButton.layer.borderWidth = borderWidth
        sellsButton.layer.borderColor = borderColor
        sellsButton.backgroundColor = normalColor
        
        portfolioButton.layer.borderWidth = borderWidth
        portfolioButton.layer.borderColor = borderColor
        portfolioButton.backgroundColor = normalColor
        
        watchlistButton.layer.borderWidth = borderWidth
        watchlistButton.layer.borderColor = borderColor
        watchlistButton.backgroundColor = normalColor
        
        performanceButton.layer.borderWidth = borderWidth
        performanceButton.layer.borderColor = borderColor
        performanceButton.backgroundColor = normalColor
        
        notificationsButton.layer.borderWidth = borderWidth
        notificationsButton.layer.borderColor = borderColor
        notificationsButton.backgroundColor = normalColor
        notificationsButton.setTitle(NSString(string: "\u{2699}\u{0000FE0E}") as String, forState: .Normal)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let stocks = getStock(nil)
        setupNotificationSettings()
        setupChart()
        startTimers()
        setButtonStyles()
    
        for stock in stocks!
        {
            let histData = stock.histData.sorted("date", ascending: false)
         
            if histData.count > 100 && !stock.hasData
            {
                let listID = stock.listID
                let stockName = stock.name
                deleteHistData(stock)
                deleteStock(stock.name)
                let newStock = Stock(value: ["name" : stockName, "listID" : listID])
                newStock.save()
                priceUpdater.downloadHistData(stockName)
           
            }
            else if (stock.listID != "Watch List"  && stock.listID != "Portfolio")
            {
                deleteStock(stock.name)
            }
        }
        
        if stocks!.count == 0
        {
        //    makeStockList(priceUpdater)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainMenuViewController.handleBuyNotification), name: "buyNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainMenuViewController.handleSellNotification), name: "sellNotification", object: nil)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        setButtonStyles()
        userPerfChart.notifyDataSetChanged()
        userPerfChart.zoomIn()
        userPerfChart.zoomOut()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func handleBuyNotification() {
        print("handling buy notification")
        //sendtobuylist
    }
    
    func handleSellNotification() {
        print("handlingSellNotification")
        //sendtoselllist
    }
    
    func chartDoubleTapped(chartView: ChartViewBase, location: CGPoint)
    {
        for _ in 0 ..< 10
        {
            userPerfChart.zoomOut()
        }
        chartView.notifyDataSetChanged()
    }
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight)
    {
        let selectedValue = userPerfChart.data?.dataSets[0].entryForXIndex(entry.xIndex)!.valueForKey("value") as! Double
        selectedPriceLabel.text = String(format:"%.2f", selectedValue) + "%"
        selectedDateLabel.text = userPerfChart.getXValue(entry.xIndex)
    }
    
    func chartPanEnded(chartView: ChartViewBase)
    {
        userPerfChart.highlightValue(nil)
        selectedDateLabel.text = nil
        selectedPriceLabel.text = nil
    }
    
    @IBAction func buysButtonPressed(sender: AnyObject) {
        buysButton.backgroundColor = highlightColor
    }
    
    @IBAction func buysButtonReleased(sender: AnyObject) {
        buysButton.backgroundColor = normalColor
    }
    
    @IBAction func sellsButtonPressed(sender: AnyObject) {
        sellsButton.backgroundColor = highlightColor
    }
    
    @IBAction func sellsButtonReleased(sender: AnyObject) {
        sellsButton.backgroundColor = normalColor
    }
    
    @IBAction func portfolioButtonPressed(sender: AnyObject) {
        portfolioButton.backgroundColor = highlightColor
    }
    
    @IBAction func portfolioButtonReleased(sender: AnyObject) {
        portfolioButton.backgroundColor = normalColor
    }
    
    @IBAction func watchlistButtonPressed(sender: AnyObject) {
        watchlistButton.backgroundColor = highlightColor
    }
    
    @IBAction func watchlistButtonReleased(sender: AnyObject) {
        watchlistButton.backgroundColor = normalColor
    }
    
    @IBAction func performanceButtonPressed(sender: AnyObject) {
        performanceButton.backgroundColor = highlightColor
    }
    
    @IBAction func performanceButtonReleased(sender: AnyObject) {
        performanceButton.backgroundColor = normalColor
    }
    
    @IBAction func notificationsButtonPressed(sender: AnyObject) {
        notificationsButton.backgroundColor = highlightColor
    }
    
    @IBAction func notificationsButtonReleased(sender: AnyObject) {
        notificationsButton.backgroundColor = normalColor
    }
    
    // MARK: Navigation
    @IBAction func unwindToMain(sender: UIStoryboardSegue) {}
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        saveTimer.invalidate()
        updateIndTimer.invalidate()
        updateHistTimer.invalidate()
        
        //load portfolio data
        if segue.identifier == "portfolioSegue"
        {
            let navVC = segue.destinationViewController as! UINavigationController
            let portfolioStockList = navVC.topViewController as! UserStockListViewController
            portfolioStockList.labelName = "Portfolio"
            portfolioStockList.priceUpdater = priceUpdater
        }
        //load watchlist data
        if segue.identifier == "watchListSegue"
        {
            let navVC = segue.destinationViewController as! UINavigationController
            let watchStockList = navVC.topViewController as! UserStockListViewController
            watchStockList.labelName = "Watch List"
            watchStockList.priceUpdater = priceUpdater
        }
        //load buy data
        if segue.identifier == "buyListSegue"
        {
            let navVC = segue.destinationViewController as! UINavigationController
            let buyStockList = navVC.topViewController as! ActionListViewController
            buyStockList.labelName = "Buys"
            buyStockList.priceUpdater = priceUpdater
        }
        // load sell data
        if segue.identifier == "sellListSegue"
        {
            let navVC = segue.destinationViewController as! UINavigationController
            let sellStockList = navVC.topViewController as! ActionListViewController
            sellStockList.labelName = "Sells"
            sellStockList.priceUpdater = priceUpdater
        }
        //pass stock data to strat view
        if segue.identifier == "MainToStrat"
        {
            let navVC = segue.destinationViewController as! UINavigationController
            let strategyList = navVC.topViewController as! StrategiesViewController
            strategyList.priceUpdater = priceUpdater
        }
        //pass stock data to notficaitons view
        if segue.identifier == "mainToNotif"
        {
            let navVC = segue.destinationViewController as! UINavigationController
            let notifView = navVC.topViewController as! NotificationsViewController
            notifView.priceUpdater = priceUpdater   
        }
    }
}


