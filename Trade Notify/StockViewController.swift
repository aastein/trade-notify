//
//  stockViewController.swift
//  Trade Notify
//
//  Created by Aaron Stein on 4/9/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import UIKit
import Charts
import RealmSwift

class StockViewController: UIViewController, ChartViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var stockLabel: UILabel!
    @IBOutlet weak var lastCloseValueLabel: UILabel!
    @IBOutlet weak var askValueLabel: UILabel!
    @IBOutlet weak var bidValueLabel: UILabel!
    @IBOutlet weak var changeValueLabel: UILabel!
    @IBOutlet weak var changePercentValueLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var priceChartView: CandleStickChartView!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var selectedPriceLabel: UILabel!
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var ppValueLabel: UILabel!
    @IBOutlet weak var trValueLabel: UILabel!
    @IBOutlet weak var trpValueLabel: UILabel!
    @IBOutlet weak var atValueLabel: UILabel!
    @IBOutlet weak var srValueLabel: UILabel!
    @IBOutlet weak var ttValueLabel: UILabel!
    @IBOutlet weak var performanceLabel: UILabel!
    @IBOutlet weak var ADPTValueLabel: UILabel!
    
    var stock: Stock!
    var strat: Strat?
    var index = NSIndexPath()
    var stockName = ""
    var sentBy = ""
    var labelName = ""
    var shares = Int(0)
    weak var AddAlertSaveAction: UIAlertAction?

    var getTimer = NSTimer()
    var setTimer = NSTimer()
    var lastTime = Double(0)
    var currentTime = Double(0)
    var labelColorTimer = NSTimer()
    var fastPan = false
    var lastSelectedClose = Double()
    var lastSelectedOpen = Double()
    var priceUpdater = UpdatePriceSession()

    var histData: Results<HistData>!
    var oscData: Results<OscData>!
    var openData = [Double]()
    var closeData = [Double]()
    var highData = [Double]()
    var lowData = [Double]()
    var kData = [Double]()
    var dData = [Double]()
    var rsiData = [Double]()
    var cciData = [Double]()
    
    let kColor = UIColor(red: 152/255, green: 115/255, blue: 255/255, alpha: 1)
    let dColor = UIColor(red: 255/255, green: 157/255, blue: 142/255, alpha: 1)
    let rsiColor = UIColor(red: 157/255, green: 255/255, blue: 142/255, alpha: 1)
    let cciColor = UIColor(red: 255/255, green: 157/255, blue: 142/255, alpha: 1)
    let decreasingColor = UIColor(red: 255/255, green: 160/255, blue: 142/255, alpha: 1)
    let increasingColor = UIColor(red: 43/255, green: 220/255, blue: 133/255, alpha: 1)
    let disabledColor = UIColor(red: 49/255, green: 255/255, blue: 155/255, alpha: 0.3)
    
    let rightAxisWidth = CGFloat(60)
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func setDisplayValues() -> Void
    {
        
        if stock.price > 0
        {
            lastCloseValueLabel.text =  String(format:"%.2f", stock.price)
        }
        
        if stock.ask > 0
        {
            askValueLabel.text = String(format:"%.2f", stock.ask)
        }
        
        if stock.bid > 0
        {
            bidValueLabel.text = String(format:"%.2f", stock.bid)
        }
        
        if stock.change > 0
        {
            changeValueLabel.text = String(format:"%.2f", stock.change)
        }
        
        if stock.pChange.characters.count > 0
        {
            changePercentValueLabel.text = stock.pChange + "%"
        }
        
    
    }
    
    func setStratMetricValues ()
    {
        let metrics = stock.strategy[0].metrics[0]
        ppValueLabel.text = String(format:"%.2f",metrics.percentProfitable * 100) + "%"
        trValueLabel.text = String(format:"%.2f",metrics.totalReturn)
        trpValueLabel.text = String(format:"%.2f",metrics.totalReturnPercent * 100) + "%"
        atValueLabel.text = String(format:"%.2f",metrics.avgTrade)
        srValueLabel.text = String(format:"%.2f",metrics.avgTradePercent * 100) + "%"   
        ttValueLabel.text = String(Int(metrics.totalTrades))
        ADPTValueLabel.text = String(Int(round(metrics.avgDaysPerTrade)))
    }
    
    func initBlankLabels () {
        ppValueLabel.text = ""
        trValueLabel.text = ""
        trpValueLabel.text = ""
        atValueLabel.text = ""
        srValueLabel.text = ""
        ttValueLabel.text = ""
        ADPTValueLabel.text = ""
        lastCloseValueLabel.text = ""
        askValueLabel.text = ""
        bidValueLabel.text = ""
        changeValueLabel.text = ""
        changePercentValueLabel.text = ""
        performanceLabel.text = ""
    }
    
    // MARK: viewDidLoad
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        initBlankLabels()
        
        print("a")
        strat = stock.strategy[0]
        stockName = stock.name
        print("b")
        
        priceChartView.delegate = self
        lineChartView.delegate = self
        
        priceChartView.identifier = "priceChartView"
        lineChartView.identifier = "lineChartView"
        
        selectedPriceLabel.text = nil
        selectedDateLabel.text = nil
        stockLabel.text = stock.name
        print("c")
        oscData = stock.oscData.sorted("date", ascending: true)
        histData = stock.histData.sorted("date", ascending: true)
        print("d")
        if stock.listID == "Watch List" { actionButton.setTitle("Bought", forState: UIControlState.Normal) }
        else if stock.listID == "Portfolio" { actionButton.setTitle("Sold", forState: UIControlState.Normal) }
        print("e")
        setDisplayValues()
        print("f")
        if strat != nil
        {
            setStratMetricValues()
        }
        print("setting up charts")
        setChart(priceChartView, histData: histData, oscData: oscData, rightAxisWidth: rightAxisWidth)
        setStockPerformanceChart(lineChartView, stockName: stockName)
        print("charts setup")
        priceChartView.notifyDataSetChanged()
        priceChartView.zoomIn()
        priceChartView.zoomOut()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        priceChartView.notifyDataSetChanged()
        setTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: #selector(StockViewController.setDisplayValues), userInfo: nil, repeats: true)
        labelColorTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(StockViewController.isFastPan), userInfo: nil, repeats: true)
    }
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        invalidateTimers()
    }
    
    func chartTranslated(chartView: ChartViewBase, dX: CGFloat, dY: CGFloat)
    {
        if chartView.identifier == "priceChartView"
        {
            let originalOscMatrix = lineChartView.viewPortHandler.touchMatrix
            var oscMatrix = CGAffineTransformMakeTranslation(dX, 0)
            oscMatrix = CGAffineTransformConcat(originalOscMatrix, oscMatrix)
            oscMatrix = lineChartView.viewPortHandler.refresh(newMatrix: oscMatrix, chart: lineChartView, invalidate: true)
        }
        else if chartView.identifier == "lineChartView"
        {
            let originalPriceMatrix = priceChartView.viewPortHandler.touchMatrix
            var priceMatrix = CGAffineTransformMakeTranslation(dX, 0)
            priceMatrix = CGAffineTransformConcat(originalPriceMatrix, priceMatrix)
            priceMatrix = priceChartView.viewPortHandler.refresh(newMatrix: priceMatrix, chart: priceChartView, invalidate: true)
        }
    }
    
    
    func chartScaled(chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat, location: CGPoint)
    {
        if chartView.identifier == "priceChartView"
        {
            var oscMatrix = CGAffineTransformMakeTranslation(location.x, location.y)
            oscMatrix = CGAffineTransformScale(oscMatrix, scaleX, 0)
            oscMatrix = CGAffineTransformTranslate(oscMatrix, -location.x, -location.y)
            oscMatrix = CGAffineTransformConcat(lineChartView.viewPortHandler.touchMatrix, oscMatrix)
            lineChartView.viewPortHandler.refresh(newMatrix: oscMatrix, chart: lineChartView, invalidate: true)
        }
        else if chartView.identifier == "lineChartView"
        {
            var priceMatrix = CGAffineTransformMakeTranslation(location.x, location.y)
            priceMatrix = CGAffineTransformScale(priceMatrix, scaleX, 0)
            priceMatrix = CGAffineTransformTranslate(priceMatrix, -location.x, -location.y)
            priceMatrix = CGAffineTransformConcat(priceChartView.viewPortHandler.touchMatrix, priceMatrix)
            priceChartView.viewPortHandler.refresh(newMatrix: priceMatrix, chart: priceChartView, invalidate: true)
        }
    }
    
    func chartDoubleTapped(chartView: ChartViewBase, location: CGPoint)
    {
        for _ in 0 ..< 10
        {
            priceChartView.zoomOut()
            lineChartView.zoomOut()
        }
        priceChartView.notifyDataSetChanged()
    }
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight)
    {
        var xIndex = entry.xIndex
        
        if  let date = priceChartView.getXValue(xIndex)
        {
            selectedDateLabel.text = date
        }
        else
        {
            xIndex -= 1
            selectedDateLabel.text = priceChartView.getXValue(xIndex)
        }
        
        let highlight = ChartHighlight(xIndex: xIndex, dataSetIndex: 0)
        
        chartView.highlightValue(highlight)
        priceChartView.highlightValue(highlight)
        lineChartView.highlightValue(highlight)
        
        let selectedPrice = priceChartView.data?.dataSets[0].entryForXIndex(xIndex)!.valueForKey("close") as! Double
        let close = ("$"+String(format:"%.2f", selectedPrice))
        let open = priceChartView.data?.dataSets[0].entryForXIndex(xIndex)!.valueForKey("open") as! Double
        let pChange = 100*(selectedPrice - open)/open
        var changeText = ""
        
        if pChange > 0
        {
            changeText = ("+"+String(format:"%.2f", pChange)+"%")
        }
        else
        {
            changeText = (String(format:"%.2f", pChange)+"%")
        }
        
        let percent = lineChartView.data?.dataSets[0].entryForIndex(xIndex)!.valueForKey("value") as! Double
        
        setLabelColor(selectedPrice, open: open)
        selectedPriceLabel.text = close + " (" + changeText + ")"
        lastTime = Double(CACurrentMediaTime())
        performanceLabel.text = String(format:"%.2f", percent) + "%"    
    }
    
    func setLabelColor (selectedPrice: Double, open: Double)
    {
        lastSelectedClose = selectedPrice
        lastSelectedOpen = open
        
        if !fastPan
        {
            if selectedPrice > open
            {
                selectedPriceLabel.textColor = increasingColor
            }
            else
            {
                selectedPriceLabel.textColor = decreasingColor
            }
        }
        else
        {
            selectedPriceLabel.textColor = NSUIColor(white: 255, alpha: 1)
        }
    }
    
    func isFastPan()
    {
        currentTime = Double(CACurrentMediaTime())
        let timeDiff = currentTime - lastTime
        if timeDiff > 0.2
        {
            fastPan = false
            setLabelColor(lastSelectedClose, open: lastSelectedOpen)
        }
        else
        {
            fastPan = true
        }
    }
    
    func chartPanEnded(chartView: ChartViewBase)
    {
        priceChartView.highlightValue(nil)
        lineChartView.highlightValue(nil)
        selectedDateLabel.text = nil
        selectedPriceLabel.text = nil
        performanceLabel.text = nil
    }

    func updateSaveStocklistID (listID: String)
    {
        stock.updateListID(listID)
    }
    
    @IBAction func actionButtonPressed(sender: AnyObject)
    {
        if stock.listID == "Watch List"
        {
            actionButton.userInteractionEnabled = false
            actionButton.tintColor = disabledColor
            updateSaveStocklistID("Portfolio")
            let portData = PortData(value: ["date": NSDate(), "value": stock.price, "shares": shares, "stock": stock, "action": "Buy"])
            portData.save()
        }
        else if stock.listID == "Portfolio"
        {
            actionButton.userInteractionEnabled = false
            actionButton.tintColor = disabledColor
            updateSaveStocklistID("Watch List")
            let portData = PortData(value: ["date": NSDate(), "value": stock.price, "shares": shares, "stock": stock, "action": "Sell"])
            portData.save()
        }
    }
    
    //MARK: Navigation
    @IBAction func backButtonPressed(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func canPerformUnwindSegueAction(action: Selector, fromViewController: UIViewController, withSender sender: AnyObject) -> Bool
    {
        if (self.respondsToSelector(action)){}
        return false;
    }
    
    func invalidateTimers ()
    {
        getTimer.invalidate()
        setTimer.invalidate()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        print("segueing", segue)
    }
}
