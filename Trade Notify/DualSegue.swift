//
//  DualUnwindSegue.swift
//  Trade Notify
//
//  Created by Aaron Stein on 5/28/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import Foundation
import UIKit

class DualSegue: UIStoryboardSegue {
    override func perform() {
        guard let nav = sourceViewController.navigationController
            else { return }
        
        // Remove current view controller from navigation stack before segue
        let viewControllers = nav.viewControllers.filter { $0 != sourceViewController }
        
        // Add destination to view controllers and perform segue
        nav.setViewControllers(viewControllers + [destinationViewController], animated: true)
    }
}