//
//  HistDataArrayClass.swift
//  Littlejohn
//
//  Created by Aaron Stein on 5/1/16.
//  Copyright © 2016 Aaron Stein. All rights reserved.
//

import UIKit

class HistDataArray {
    
    var histData: [HistDataPoint]?
    
    
    init?(histData: [HistDataPoint]?){
        
        self.histData = histData
        
    }
}
