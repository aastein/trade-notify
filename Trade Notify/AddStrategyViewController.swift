//
//  AddStrategyViewController.swift
//  Trade Notify
//
//  Created by Aaron Stein on 3/26/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import UIKit
import RealmSwift

class AddStrategyViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {

    //MARK: Properties
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var kText: UITextField!
    @IBOutlet weak var dText: UITextField!
    @IBOutlet weak var stochLengthText: UITextField!
    @IBOutlet weak var stochMinText: UITextField!
    @IBOutlet weak var stochMaxText: UITextField!
    @IBOutlet weak var rsiLengthText: UITextField!
    @IBOutlet weak var rsiMinText: UITextField!
    @IBOutlet weak var rsiMaxText: UITextField!
    @IBOutlet weak var cciLengthText: UITextField!
    @IBOutlet weak var cciMinText: UITextField!
    @IBOutlet weak var cciMaxText: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var addStratScrollView: UIScrollView!
    
    var oldName = String("")
    var strat: Strat?
    var labelName = "Default"
    var priceUpdater = UpdatePriceSession()
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameText.delegate = self
        kText.delegate = self
        dText.delegate = self
        stochLengthText.delegate = self
        stochMinText.delegate = self
        stochMaxText.delegate = self
        rsiLengthText.delegate = self
        rsiMaxText.delegate = self
        rsiMinText.delegate = self
        cciLengthText.delegate = self
        cciMaxText.delegate = self
        cciMinText.delegate = self
        saveButton.enabled = false
        label.text = labelName
        addStratScrollView.showsVerticalScrollIndicator = false
        
        if labelName == "Edit Strategy" {
            nameText.text = strat!.name
            kText.text = String(strat!.k)
            dText.text = String(strat!.d)
            stochLengthText.text = String(strat!.stochLength)
            stochMinText.text = String(strat!.stochMin)
            stochMaxText.text = String(strat!.stochMax)
            rsiLengthText.text = String(strat!.rsiLength)
            rsiMaxText.text = String(strat!.rsiMax)
            rsiMinText.text = String(strat!.rsiMin)
            cciLengthText.text = String(strat!.cciLength)
            cciMaxText.text = String(strat!.cciMax)
            cciMinText.text = String(strat!.cciMin)
            oldName = nameText.text!
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboad.
        textField.resignFirstResponder()
        return true
    }

    func filterInt(text: String) -> String {
        
        let intInverseSet = NSCharacterSet(charactersInString:"0123456789").invertedSet
        let components = text.componentsSeparatedByCharactersInSet(intInverseSet)
        let filtered = components.joinWithSeparator("")
        return filtered
        
    }
    
    func filterDouble(text: String) -> String {
        
        let doubleInverseSet = NSCharacterSet(charactersInString:"0123456789.-").invertedSet
        var decimals = Int()
        let components = text.componentsSeparatedByCharactersInSet(doubleInverseSet)
        var filtered = components.joinWithSeparator("")
        var parseString = filtered
        for _ in 0..<parseString.characters.count {
            if let index = parseString.lowercaseString.characters.indexOf(".") {
                let prefix = parseString.substringToIndex(index)
                let advancer = (prefix.characters.count)+1
                let range = parseString.startIndex.advancedBy(advancer)..<parseString.endIndex
                parseString = parseString.substringWithRange(Range<String.Index>(range))
                decimals += 1
            }
        }
        if decimals > 0 {
            for _ in 0..<((decimals)-1) {
                if let index = filtered.lowercaseString.characters.indexOf(".") {
                    filtered.removeAtIndex(index)
                }
            }
            let index = filtered.lowercaseString.characters.indexOf(".")
            let prefix = filtered.substringToIndex(index!)
            let advancer = (prefix.characters.count)
            let range = filtered.startIndex.advancedBy(advancer)..<filtered.endIndex
            if filtered.substringWithRange(Range<String.Index>(range)) == (".") {
                filtered.removeAtIndex(index!)
            }
        }
       return filtered
    }

    func textFieldDidEndEditing(textField: UITextField) {
        checkValidStrategyName()
        let k = kText.text ?? ""
        let d = dText.text ?? ""
        let stochLength = stochLengthText.text ?? ""
        let stochMin = stochMinText.text ?? ""
        let stochMax = stochMaxText.text ?? ""
        let rsiLength = rsiLengthText.text ?? ""
        let rsiMin = rsiMinText.text ?? ""
        let rsiMax = rsiMaxText.text ?? ""
        let cciLenth = cciLengthText.text ?? ""
        let cciMin = cciMinText.text ?? ""
        let cciMax = cciMaxText.text ?? ""
        if textField.accessibilityIdentifier == "StratK" {
            kText.text = filterInt(k)
        } else if textField.accessibilityIdentifier == "StratD" {
            dText.text = filterInt(d)
        } else if textField.accessibilityIdentifier == "StratStochLength" {
            stochLengthText.text = filterInt(stochLength)
        } else if textField.accessibilityIdentifier == "StratStochMin" {
            stochMinText.text = filterDouble(stochMin)
        } else if textField.accessibilityIdentifier == "StratStochMax" {
            stochMaxText.text = filterDouble(stochMax)
        } else if textField.accessibilityIdentifier == "StratRSILength" {
            rsiLengthText.text = filterInt(rsiLength)
        } else if textField.accessibilityIdentifier == "StratRSIMin" {
           rsiMinText.text = filterDouble(rsiMin)
        } else if textField.accessibilityIdentifier == "StratRSIMax" {
            rsiMaxText.text = filterDouble(rsiMax)
        } else if textField.accessibilityIdentifier == "StratCCILength" {
            cciLengthText.text = filterInt(cciLenth)
        } else if textField.accessibilityIdentifier == "StratCCIMin" {
            cciMinText.text = filterDouble(cciMin)
        } else if textField.accessibilityIdentifier == "StratCCIMax" {
            cciMaxText.text = filterDouble(cciMax)
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        saveButton.enabled = false
    }
    
    func checkValidStrategyName () {
        let nametext = nameText.text ?? ""
        let k = kText.text ?? ""
        let d = dText.text ?? ""
        let stochLength = stochLengthText.text ?? ""
        let stochMin = stochMinText.text ?? ""
        let stochMax = stochMaxText.text ?? ""
        let rsiLength = rsiLengthText.text ?? ""
        let rsiMin = rsiMinText.text ?? ""
        let rsiMax = rsiMaxText.text ?? ""
        let cciLenth = cciLengthText.text ?? ""
        let cciMin = cciMinText.text ?? ""
        let cciMax = cciMaxText.text ?? ""
        if !nametext.isEmpty && !k.isEmpty && !d.isEmpty &&  !stochLength.isEmpty && !stochMin.isEmpty && !stochMax.isEmpty && !rsiLength.isEmpty && !rsiMin.isEmpty && !rsiMax.isEmpty && !cciLenth.isEmpty && !cciMin.isEmpty && !cciMax.isEmpty{
            saveButton.enabled = true
        }
    }

    // MARK: Navigation
    @IBAction func strategyCancelButton(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }
}

































