//
//  ActionListViewController.swift
//  Trade Notify
//
//  Created by Aaron Stein on 4/4/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import UIKit
import RealmSwift

class ActionListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var actionStockList: UITableView!
    @IBOutlet weak var actionListLabel: UILabel!
    @IBOutlet weak var changeListButton: UIBarButtonItem!
    
    var labelName = String("Default")
    var refreshTimer = NSTimer()
    var index = NSIndexPath()
    var stocks: Results<Stock>?
    var stock: Stock?
    let redColor = UIColor(red: 255/255, green: 100/255, blue: 50/255, alpha: 1)
    let greenColor = UIColor(red: 43/255, green: 255/255, blue: 133/255, alpha: 1)
    let goldColor = UIColor(red: 255/255, green: 215/255, blue: 0/255, alpha: 1)
    var priceUpdater = UpdatePriceSession()
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // MARK: TableView Stuff
    func numberOfSectionsInTableView(stockTableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(stockTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stocks!.count
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        stock = stocks![indexPath.row]
        index = indexPath
        return indexPath
    }
    
    func tableView(stockTableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        stockTableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // Set cell values
    func tableView(stockTableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = stockTableView.dequeueReusableCellWithIdentifier("actionCell")!
        let price = stocks![indexPath.row].price
        
        cell.detailTextLabel?.text = "$$.$$"
        cell.detailTextLabel?.textColor = goldColor
        cell.textLabel?.text = stocks![indexPath.row].name

        let label = String(format:"%.2f", price)
        
        if stocks![indexPath.row].listID == "Portfolio" && labelName == "Sells"
        {
            cell.textLabel?.textColor = redColor
        } else
        {
            cell.textLabel?.textColor = greenColor
        }
        
        if price > -1
        {
            cell.detailTextLabel?.text = label
            cell.detailTextLabel?.textColor = UIColor(white: 255, alpha: 1)
        }
        
        return cell
    }
    
    // MARK: viewDidLoad
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        actionListLabel.text = labelName
        
        if labelName == "Buys"
        {
            stocks = getStock(nil)?.filter("status = 'Buy'").sorted("score", ascending: false)
            changeListButton.title = "Sells"
            changeListButton.tintColor = redColor
        }
        else
        {
            changeListButton.title = "Buys"
            stocks = getStock(nil)?.filter("status = 'Sell'").sorted("name", ascending: false)
            changeListButton.tintColor = greenColor
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        refreshTable()
        refreshTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(ActionListViewController.refreshTable), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        refreshTimer.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func refreshTable () {
        actionStockList.reloadData()
    }
    
    // MARK: Navigation
    @IBAction func unwindToActionList(sender: UIStoryboardSegue) {
        print("updating row \(index.row) for stock \(stocks![index.row].name) lisID = \(stocks![index.row].listID)")
        actionStockList.reloadRowsAtIndexPaths([index], withRowAnimation: .Fade)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        refreshTimer.invalidate()       
        if segue.identifier == "selectStockSegue"
        {
            let navVC = segue.destinationViewController as! UINavigationController
            let StockVC = navVC.topViewController as! StockViewController
            StockVC.stock = stock
            StockVC.index = index
            StockVC.priceUpdater = priceUpdater
            StockVC.sentBy = "ActionView"
            StockVC.labelName = labelName
            
        }
        else if segue.identifier == "actionToMain"
        {
            let mainMenu = segue.destinationViewController as! MainMenuViewController
            mainMenu.freshStart = false
            mainMenu.priceUpdater = priceUpdater
        }
        else if segue.identifier == "changeList"
        {
            if changeListButton.title == "Buys"
            {
                let navVC = segue.destinationViewController as! UINavigationController
                let buyStockList = navVC.topViewController as! ActionListViewController
                buyStockList.labelName = "Buys"
                buyStockList.priceUpdater = priceUpdater
            }
            
            if changeListButton.title == "Sells"
            {
                let navVC = segue.destinationViewController as! UINavigationController
                let sellStockList = navVC.topViewController as! ActionListViewController
                sellStockList.labelName = "Sells"
                sellStockList.priceUpdater = priceUpdater   
            }
        }
    }
}

