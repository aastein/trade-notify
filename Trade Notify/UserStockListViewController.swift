//
//  UserStockListViewController.swift
//  Trade Notify
//
//  Created by Aaron Stein on 3/25/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import UIKit
import RealmSwift

class UserStockListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate  {

    @IBOutlet weak var stockTableView: UITableView!
    @IBOutlet weak var stockListLabel: UILabel!
    
    var posShift = [Int]()
    var listIndexs = [Int]()
    var labelName = "Default"
    var selectedStockIndex = Int()
    var selectedStockName = String("")
    var refreshTimer = NSTimer()
    var isSaving = false
    var stocks: Results<Stock>?
    var priceUpdater = UpdatePriceSession()
    let redColor = UIColor(red: 255/255, green: 100/255, blue: 50/255, alpha: 1)
    let greenColor = UIColor(red: 43/255, green: 255/255, blue: 133/255, alpha: 1)
    let goldColor = UIColor(red: 255/255, green: 215/255, blue: 0/255, alpha: 1)
    let greyColor = UIColor(red: 135/255, green: 135/255, blue: 135/255, alpha: 1)
    override func preferredStatusBarStyle() -> UIStatusBarStyle
    {
        return UIStatusBarStyle.LightContent
    }

    func numberOfSectionsInTableView(stockTableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(stockTableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return stocks!.count
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath?
    {
        let index = indexPath.row
        selectedStockName = stocks![index].name
        return indexPath
    }

    func tableView(stockTableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        stockTableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(stockTableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = stockTableView.dequeueReusableCellWithIdentifier("stockCell")!
        
        if let userListCell = cell as? UserListCell
        {
            let price = stocks![indexPath.row].price
            let canEdit = stocks![indexPath.row].hasData
            let progress = stocks![indexPath.row].progress
            //let buyPrice = stocks![indexPath.row].buyPrice
            //let sellPrice = stocks![indexPath.row].sellPrice
            
            if progress < 1
            {
                userListCell.progressBar.hidden = false
                userListCell.progressBar.progressViewStyle = UIProgressViewStyle.Bar
                userListCell.progressBar.progress = progress + 0.05
                userListCell.userInteractionEnabled = false
            }
            else
            {
                userListCell.progressBar.hidden = true
                userListCell.userInteractionEnabled = true
            }
            
            if !canEdit
            {
                userListCell.selectionStyle = UITableViewCellSelectionStyle.None
                userListCell.stockLabel?.textColor = greyColor
            }
            else
            {
                userListCell.selectionStyle = UITableViewCellSelectionStyle.Blue
                userListCell.userInteractionEnabled = true
                userListCell.stockLabel?.textColor = greenColor
            }
            
            userListCell.priceLabel.text = "$$.$$"
            userListCell.priceLabel.textColor = greyColor
            userListCell.stockLabel.text = stocks![indexPath.row].name
            
            if stocks![indexPath.row].status == "Sell" && labelName == "Portfolio"
            {
                userListCell.stockLabel?.textColor = redColor
            }
            else  if stocks![indexPath.row].status == "Buy"
            {
                userListCell.stockLabel?.textColor = goldColor
            }
            if price > -1
            {
                //if sellPrice > 0
                //{
                     userListCell.priceLabel?.text = String(format:"%.2f", price)
                //}
                //else
                //{
                //    userListCell.priceLabel?.text = String(format:"%.2f", price)
                //}
               
                userListCell.priceLabel?.textColor = UIColor(white: 255, alpha: 1)
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete
        {
            let stockName = stocks![indexPath.row].name
            deleteOscData(stocks![indexPath.row])
            deleteHistData(stocks![indexPath.row])
            deleteStrat(stockName)
            deleteMetrics(stockName)
            deleteStock(stockName)
            print("Deleted stock \(stockName)")
                        stockTableView .deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // MARK: viewDidLoad
    override func viewDidLoad()
    {
        super.viewDidLoad()
        stockListLabel.text = labelName
        stocks = getStock(nil)?.filter("listID = '\(labelName)'").sorted("name", ascending: true)
    }

    override func viewWillAppear(animated: Bool) {
        refreshTable()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        refreshTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(UserStockListViewController.refreshTable), userInfo: nil, repeats: true)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func refreshTable ()
    {
        stockTableView.reloadData()
    }

    // MARK: Navigation
    // Add new stock name or updated exsiting stock
    @IBAction func unwindToStockList(sender: UIStoryboardSegue)
    {
        if sender.sourceViewController is AddStockViewController
        {
            let index = NSIndexPath(forRow: stocks!.count - 1 , inSection: 0)
            stockTableView.reloadData()
            stockTableView.reloadRowsAtIndexPaths([index], withRowAnimation: .Fade)
            selectedStockIndex = 0
            selectedStockName = ""
        }
    }
    
    @IBAction func stockToUserList(sender: UIStoryboardSegue)
    {}
    
    // Load data based on segue type.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        refreshTimer.invalidate()
        
        if segue.identifier == "AddStock"
        {
            let navVC = segue.destinationViewController as! UINavigationController
            let addStockVC = navVC.topViewController as! AddStockViewController
            addStockVC.label = "Add Stock"
            addStockVC.listType = stockListLabel.text!
            addStockVC.selectedStockName = selectedStockName
            addStockVC.priceUpdater = priceUpdater
        }
        else if segue.identifier == "userListToMain"
        {
            let mainMenu = segue.destinationViewController as! MainMenuViewController
            priceUpdater.downloadManager.cancelAll()
            mainMenu.priceUpdater = priceUpdater
        }
        else if segue.identifier == "userListToStock"
        {
            let navVC = segue.destinationViewController as! UINavigationController
            let StockVC = navVC.topViewController as! StockViewController
            StockVC.stock = getStock(selectedStockName)![0]
            StockVC.priceUpdater = priceUpdater
            StockVC.sentBy = "userList"
        }
    }
}


