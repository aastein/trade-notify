//
//  ViewStrategyViewController.swift
//  Trade Notify
//
//  Created by Aaron Stein on 4/18/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import UIKit
import RealmSwift

class ViewStrategyViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var kLabel: UILabel!
    @IBOutlet weak var dLabel: UILabel!
    @IBOutlet weak var stochLengthLabel: UILabel!
    @IBOutlet weak var stochMinLabel: UILabel!
    @IBOutlet weak var stochMaxLabel: UILabel!
    @IBOutlet weak var rsiLengthLabel: UILabel!
    @IBOutlet weak var rsiMinLabel: UILabel!
    @IBOutlet weak var rsiMaxLabel: UILabel!
    @IBOutlet weak var cciLengthLabel: UILabel!
    @IBOutlet weak var cciMinLabel: UILabel!
    @IBOutlet weak var cciMaxLabel: UILabel!
    @IBOutlet weak var backButton: UIBarButtonItem!

    var strat: Strat!
    
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = strat.name
        kLabel.text = String(strat.k)
        dLabel.text = String(strat.d)
        stochLengthLabel.text = String(strat.stochLength)
        stochMinLabel.text = String(strat.stochMin)
        stochMaxLabel.text = String(strat.stochMax)
        rsiLengthLabel.text = String(strat.rsiLength)
        rsiMinLabel.text = String(strat.rsiMin)
        rsiMaxLabel.text = String(strat.rsiMax)
        cciLengthLabel.text = String(strat.cciLength)
        cciMinLabel.text = String(strat.cciMin)
        cciMaxLabel.text = String(strat.cciMax)
    }
}