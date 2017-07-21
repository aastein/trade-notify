//
//  StrategiesViewController.swift
//  Trade Notify
//
//  Created by Aaron Stein on 3/26/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import UIKit
import RealmSwift
import Charts

class StrategiesViewController: UIViewController, ChartViewDelegate
{
    
    var priceUpdater = UpdatePriceSession()
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var selectedPriceLabel: UILabel!
    @IBOutlet weak var histPortValChart: LineChartView!
    @IBOutlet weak var sharpeValue: UILabel!
    @IBOutlet weak var returnPerTradeValue: UILabel!
    @IBOutlet weak var daysPerTradeValue: UILabel!
    @IBOutlet weak var stocksInPortfolioValue: UILabel!
    @IBOutlet weak var totalTradesValue: UILabel!
    @IBOutlet weak var avgPercentProfitableValue: UILabel!
    @IBOutlet weak var avgTradesPerStock: UILabel!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle
    {
        return UIStatusBarStyle.LightContent
    }
    
    func setPerformanceLabels()
    {
        let tradeVals = getTotalTrades(nil)
        let numStocks = getStock(nil)?.filter("hasData = true")
        if tradeVals.avg > 0 && numStocks!.count > 0
        {
            stocksInPortfolioValue.text = String(numStocks!.count)
            sharpeValue.text = String(format:"%.2f", getSharpeRatio(nil)*100) + "%"
            returnPerTradeValue.text = String(format:"%.2f", getAvgReturn(nil)*100) + "%"
            daysPerTradeValue.text = String(format:"%.2f", getAvgDaysPerTrade(nil))
            avgPercentProfitableValue.text = String(format:"%.2f", getAvgPercentProfitable(nil)*100) + "%"
            totalTradesValue.text = String(Int(round(tradeVals.total)))
            avgTradesPerStock.text = String(Int(round(tradeVals.avg)))
        }
    }
    
    func setupChart()
    {
        var period = Int(0)
      //  var days = Double(0)
        var value = Double(0)
        
        selectedDateLabel.textColor = UIColor(white: 1, alpha: 1)
        selectedPriceLabel.textColor = UIColor(white: 1, alpha: 1)
        histPortValChart.delegate = self
        setStrategyChart(histPortValChart)
        histPortValChart.notifyDataSetChanged()
        histPortValChart.zoomIn()
        histPortValChart.zoomOut()
        
        period = (histPortValChart.data?.dataSets[0].entryCount)!
   //     days = Double(period) + (( Double(period) / 5 ) * 2)
        value = histPortValChart.data?.dataSets[0].entryForXIndex(period)!.valueForKey("value") as! Double
        
        selectedDateLabel.text = "In one year..."
        selectedPriceLabel.text = String(format:"%.2f", value) + "%"
    }
    
    // MARK: viewDidLoad
    override func viewDidLoad()
    {
        setPerformanceLabels()
        setupChart()
    }
    
    
    override func viewWillAppear(animated: Bool)
    {
        histPortValChart.notifyDataSetChanged()
        histPortValChart.zoomIn()
        histPortValChart.zoomOut()
    }
    
    
    override func didReceiveMemoryWarning()
    {
            super.didReceiveMemoryWarning()
    }
    
    
    func chartDoubleTapped(chartView: ChartViewBase, location: CGPoint)
    {
        for _ in 0 ..< 10
        {
            histPortValChart.zoomOut()
        }
        chartView.notifyDataSetChanged()
    }
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight)
    {
        let selectedValue = histPortValChart.data?.dataSets[0].entryForXIndex(entry.xIndex)!.valueForKey("value") as! Double
        selectedPriceLabel.text = String(format:"%.2f", selectedValue) + "%"
        selectedDateLabel.text = histPortValChart.getXValue(entry.xIndex)
    }
    
    func chartPanEnded(chartView: ChartViewBase)
    {
        let period = histPortValChart.data?.dataSets[0].entryCount
    //    let days = Double(period!) + (( Double(period!) / 5 ) * 2)
        let value = histPortValChart.data?.dataSets[0].entryForXIndex(period!)!.valueForKey("value") as! Double
        
        selectedDateLabel.text = "In one year..."
        selectedPriceLabel.text = String(format:"%.2f", value) + "%"
        histPortValChart.highlightValue(nil)
    }

    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "StratToMain"
        {
            let mainMenu = segue.destinationViewController as! MainMenuViewController
            mainMenu.freshStart = false
            mainMenu.priceUpdater = priceUpdater
        }
    }
}
