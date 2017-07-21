//
//  NotificationsViewController.swift
//  Trade Notify
//
//  Created by Aaron Stein on 4/16/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift

class NotificationsViewController: UIViewController {

    var downloadManager = DownloadManager()
    var priceUpdater = UpdatePriceSession()
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "notifToMain" {
            let mainMenu = segue.destinationViewController as! MainMenuViewController
            mainMenu.freshStart = false
            mainMenu.priceUpdater = priceUpdater    
        }
    }
}
