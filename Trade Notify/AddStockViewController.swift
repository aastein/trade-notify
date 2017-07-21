//
//  AddStockViewController.swift
//  Trade Notify
//
//  Created by Aaron Stein on 3/25/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import UIKit
import RealmSwift

class AddStockViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    @IBOutlet weak var stockNameTextField: UITextField!
    @IBOutlet weak var stockSaveButton: UIBarButtonItem!
    @IBOutlet weak var labelName: UILabel!
    
    var selectedStockName = String("")
    var stock = Stock()
    var label = "Default"
    var stockName = ""
    var listType = String("")
    var priceUpdater = UpdatePriceSession()
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    //MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelName.text = label
        stockNameTextField.delegate = self
        checkValidStockName()
    }
    
    override func viewDidAppear(animated: Bool) {
        stockNameTextField.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidStockName()
    }
    func textFieldDidBeginEditing(textField: UITextField) {
        stockSaveButton.enabled = false
    }
    func checkValidStockName () {
        //Disable the Save button if the text field is empty.
        let text = stockNameTextField.text ?? ""
        stockSaveButton.enabled = !text.isEmpty
    }
    
    // MARK: Navigation
    @IBAction func stockCancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // configure UserStockListViewController before it's presented.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if stockSaveButton === sender
        {
            stockName = stockNameTextField.text ?? ""
            if getStock(stockName)?.count == 0
            {
                priceUpdater.downloadQuotes(stockName)
                let stock = Stock(value: ["name" : stockName, "listID" : listType])
                stock.save()
                priceUpdater.downloadHistData(stockName)
            }

        }
    }
}






