//
//  SetupCharts.swift
//  Trade Notify
//
//  Created by Aaron Stein on 5/20/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import UIKit
import Charts
import RealmSwift

func setPerfChart(chartView: LineChartView)
{
    
    let formatter = NSDateFormatter()
    formatter.dateFormat = "M/d/yy"
    
    let greenColor = UIColor(red: 43/255, green: 255/255, blue: 133/255, alpha: 1)
    let histPerf = getUserPerformance()
    let portVal = histPerf.value
    let nsDates = histPerf.dates
    let numberFormatter = NSNumberFormatter()
    var data: [ChartDataEntry] = []
    var dates = [String]()
    var chartDataSet = LineChartDataSet()
    var chartData = LineChartData()
   
    for i in (0 ..< portVal.count).reverse()
    {
        let val = ChartDataEntry(value: portVal[i], xIndex: portVal.count - i)
        data.append(val)
        dates.append(formatter.stringFromDate(nsDates[i]))
    }
    
    numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
    numberFormatter.maximumFractionDigits = 2
    numberFormatter.minimumFractionDigits = 2
    
    chartDataSet = LineChartDataSet(yVals: data, label: "")
    chartDataSet.lineWidth = 0.6
    chartDataSet.drawCircleHoleEnabled = false
    chartDataSet.drawCirclesEnabled = false
    chartDataSet.drawHorizontalHighlightIndicatorEnabled = false
    chartDataSet.colors = [greenColor]
    
    chartData = LineChartData(xVals: dates, dataSet: chartDataSet)
    chartData.setValueFont(UIFont(name: "Avenir", size: 5))
    chartData.setDrawValues(false)
    
    if portVal.count > 1
    {
        chartView.data = chartData
    }
    
    chartView.descriptionText = ""
    chartView.drawGridBackgroundEnabled = false
    chartView.rightAxis.drawAxisLineEnabled = false
    chartView.noDataText = "Trade stocks to track your performance!"
    chartView.backgroundColor = UIColor(red: 9/255, green: 18/255, blue: 19/255, alpha: 1)
    chartView.xAxis.labelPosition = .Bottom
    chartView.leftAxis.labelTextColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    chartView.xAxis.labelTextColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    chartView.borderColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    chartView.legend.maxSizePercent = 0
    chartView.legend.formSize = 0
    chartView.autoScaleMinMaxEnabled = true
    chartView.drawBordersEnabled = false
    chartView.leftAxis.enabled = false
    chartView.xAxis.drawLabelsEnabled = false
    chartView.rightAxis.granularityEnabled = true
    chartView.rightAxis.granularity = 1
    chartView.setVisibleXRangeMinimum(5)
    chartView.doubleTapToZoomEnabled = true
    chartView.xAxis.drawGridLinesEnabled = false
    chartView.rightAxis.drawGridLinesEnabled = false
    chartView.dragDecelerationEnabled = false
    chartView.drawMarkers = false
    chartView.highlightOnlyTouchEnabled = true
    chartView.highlightPerTapEnabled = false
    chartView._longPressGestureRecognizer.minimumPressDuration = 0.1
}

func setStrategyChart(chartView: LineChartView)
{
    let formatter = NSDateFormatter()
    formatter.dateFormat = "M/d/yy"
    
    let greenColor = UIColor(red: 43/255, green: 255/255, blue: 133/255, alpha: 1)
    let histPerf = getHistPerformance(nil)
    let portVal = histPerf.value
    let nsDates = histPerf.dates
    let numberFormatter = NSNumberFormatter()
    var chartDataSet = LineChartDataSet()
    var chartData = LineChartData()
    var data: [ChartDataEntry] = []
    var dates = [String]()
    
    for i in (0 ..< portVal.count).reverse()
    {
        let val = ChartDataEntry(value: portVal[i], xIndex: portVal.count - i)
        data.append(val)
        dates.append(formatter.stringFromDate(nsDates[i]))
    }
    
    numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
    numberFormatter.maximumFractionDigits = 2
    numberFormatter.minimumFractionDigits = 2

    chartDataSet = LineChartDataSet(yVals: data, label: "")
    chartDataSet.lineWidth = 0.6
    chartDataSet.drawCircleHoleEnabled = false
    chartDataSet.drawCirclesEnabled = false
    chartDataSet.drawHorizontalHighlightIndicatorEnabled = false
    chartDataSet.colors = [greenColor]
    
    chartData = LineChartData(xVals: dates, dataSet: chartDataSet)
    chartData.setValueFont(UIFont(name: "Avenir", size: 5))
    chartData.setDrawValues(false)
    
    chartView.data = chartData
    chartView.pinchZoomEnabled = false
    chartView.doubleTapToZoomEnabled = false
    chartView.descriptionText = ""
    chartView.noDataText = "Data Not Loaded! :("
    chartView.drawGridBackgroundEnabled = false
    chartView.backgroundColor = UIColor(red: 9/255, green: 18/255, blue: 19/255, alpha: 1)
    chartView.xAxis.labelPosition = .Bottom
    chartView.leftAxis.labelTextColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    chartView.xAxis.labelTextColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    chartView.borderColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    chartView.legend.maxSizePercent = 0
    chartView.legend.formSize = 0
    chartView.autoScaleMinMaxEnabled = false
    chartView.drawBordersEnabled = false
    chartView.leftAxis.enabled = false
    chartView.xAxis.drawLabelsEnabled = false
    chartView.setVisibleXRangeMinimum(5)
    chartView.xAxis.drawGridLinesEnabled = false
    chartView.rightAxis.drawGridLinesEnabled = false
    chartView.rightAxis.drawAxisLineEnabled = false
    chartView.rightAxis.labelCount = 10
    chartView.rightAxis.drawLabelsEnabled = false
    chartView.dragDecelerationEnabled = false
    chartView.drawMarkers = false
    chartView.highlightOnlyTouchEnabled = true
    chartView.highlightPerTapEnabled = false
    chartView._longPressGestureRecognizer.minimumPressDuration = 0.1
    chartView.xAxis.drawAxisLineEnabled = true
}



func setStockPerformanceChart(chartView: LineChartView, stockName: String)
{
    let formatter = NSDateFormatter()
    formatter.dateFormat = "M/d/yy"
    
    let greenColor = UIColor(red: 43/255, green: 255/255, blue: 133/255, alpha: 1)
    let histPerf = getHistPerformance(stockName)
    let portVal = histPerf.value
    let nsDates = histPerf.dates
    let numberFormatter = NSNumberFormatter()
    var chartDataSet = LineChartDataSet()
    var chartData = LineChartData()
    var data: [ChartDataEntry] = []
    var dates = [String]()
    
    for i in (0 ..< portVal.count).reverse()
    {
        let val = ChartDataEntry(value: portVal[i], xIndex: portVal.count - i)
        data.append(val)
        dates.append(formatter.stringFromDate(nsDates[i]))
    }
    
    numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
    numberFormatter.maximumFractionDigits = 2
    numberFormatter.minimumFractionDigits = 2
    
    chartDataSet = LineChartDataSet(yVals: data, label: "")
    chartDataSet.lineWidth = 0.6
    chartDataSet.drawCircleHoleEnabled = false
    chartDataSet.drawCirclesEnabled = false
    chartDataSet.drawHorizontalHighlightIndicatorEnabled = false
    chartDataSet.colors = [greenColor]
    
    chartData = LineChartData(xVals: dates, dataSet: chartDataSet)
    chartData.setValueFont(UIFont(name: "Avenir", size: 5))
    chartData.setDrawValues(false)
    
    chartView.data = chartData
    chartView.pinchZoomEnabled = false
    chartView.doubleTapToZoomEnabled = false
    chartView.descriptionText = ""
    chartView.noDataText = "Data Not Loaded! :("
    chartView.drawGridBackgroundEnabled = false
    chartView.backgroundColor = UIColor(red: 9/255, green: 18/255, blue: 19/255, alpha: 1)
    chartView.xAxis.labelPosition = .Bottom
    chartView.leftAxis.labelTextColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    chartView.xAxis.labelTextColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    chartView.borderColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    chartView.legend.maxSizePercent = 0
    chartView.legend.formSize = 0
    chartView.autoScaleMinMaxEnabled = false
    chartView.drawBordersEnabled = false
    chartView.leftAxis.enabled = false
    chartView.xAxis.drawLabelsEnabled = false
    chartView.setVisibleXRangeMinimum(5)
    chartView.xAxis.drawGridLinesEnabled = false
    chartView.rightAxis.drawGridLinesEnabled = false
    chartView.rightAxis.drawAxisLineEnabled = false
    chartView.rightAxis.labelCount = 10
    chartView.rightAxis.drawLabelsEnabled = false
    chartView.dragDecelerationEnabled = false
    chartView.drawMarkers = false
    chartView.highlightOnlyTouchEnabled = true
    chartView.highlightPerTapEnabled = false
    chartView._longPressGestureRecognizer.minimumPressDuration = 0.1
    chartView.xAxis.drawAxisLineEnabled = true
}



func setChart(priceChartView: CandleStickChartView, histData: Results<HistData>!, oscData: Results<OscData>!, rightAxisWidth: CGFloat) {
    
    let period = 253
    let formatter = NSDateFormatter()
    formatter.dateFormat = "M/d/yy"
    
    let numberFormatter = NSNumberFormatter()
    var data: [CandleChartDataEntry] = []
    var dates = [String]()
    var chartDataSet = CandleChartDataSet()
    var chartData = CandleChartData()
    
    if histData.count > period
    {
        for i in histData.count - period ..< histData.count
        {
            let high = histData[i].high
            let low = histData[i].low
            let open = histData[i].open
            let close = histData[i].close
            let date = histData[i].date
            var action = ""
            
            if i < oscData.count
            {
                action = oscData[i].status
            }
            
            let dataEntry = CandleChartDataEntry(xIndex: i - (histData.count - period), shadowH: high, shadowL: low, open: open, close: close, action: action )
            dates.append(formatter.stringFromDate(date))
            data.append(dataEntry)
        }
    }
    
    numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
    numberFormatter.maximumFractionDigits = 2
    numberFormatter.minimumFractionDigits = 2

    chartDataSet = CandleChartDataSet(yVals: data, label: "")
    chartDataSet.decreasingFilled = true
    chartDataSet.increasingFilled = false
    chartDataSet.decreasingColor = UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 0.5)
    chartDataSet.increasingColor = UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 0.5)
    chartDataSet.neutralColor = UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 0.5)
    chartDataSet.sellColor = UIColor(red: 255/255, green: 255/255, blue: 0/255, alpha: 1)
    chartDataSet.buyColor = UIColor(red: 0/255, green: 191/255, blue: 255/255, alpha: 1)
    chartDataSet.shadowColorSameAsCandle = true
    chartDataSet.drawHorizontalHighlightIndicatorEnabled = false
    
    chartData = CandleChartData(xVals: dates, dataSet: chartDataSet)
    chartData.setValueFont(UIFont(name: "Avenir", size: 5))
    chartData.setDrawValues(false)
    
    if histData.count > period
    {
        priceChartView.data = chartData
    }
    
    priceChartView.descriptionText = ""
    priceChartView.drawBordersEnabled = false
    priceChartView.drawGridBackgroundEnabled = false
    priceChartView.noDataText = "Data Not Loaded! :("
    priceChartView.backgroundColor = UIColor(red: 9/255, green: 18/255, blue: 19/255, alpha: 1)
    priceChartView.xAxis.labelPosition = .Bottom
    priceChartView.leftAxis.labelTextColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    priceChartView.xAxis.labelTextColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    priceChartView.borderColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    priceChartView.legend.maxSizePercent = 0
    priceChartView.legend.formSize = 0
    priceChartView.autoScaleMinMaxEnabled = true
    priceChartView.drawBordersEnabled = false
    priceChartView.leftAxis.enabled = false
    priceChartView.xAxis.drawLabelsEnabled = false
    priceChartView.setVisibleXRangeMinimum(5)
    priceChartView.doubleTapToZoomEnabled = true
    priceChartView.xAxis.drawGridLinesEnabled = false
    priceChartView.rightAxis.drawGridLinesEnabled = false
    priceChartView.dragDecelerationEnabled = false
    priceChartView.drawMarkers = false
    priceChartView.highlightOnlyTouchEnabled = true
    priceChartView.highlightPerTapEnabled = false
    priceChartView._longPressGestureRecognizer.minimumPressDuration = 0.1
    priceChartView.xAxis.drawAxisLineEnabled = false
    priceChartView.rightAxis.drawLabelsEnabled = false
    priceChartView.rightAxis.drawAxisLineEnabled = false
}


