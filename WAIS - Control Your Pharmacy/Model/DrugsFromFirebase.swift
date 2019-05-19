//
//  DrugsFromFirebase.swift
//  WAIS - Control Your Pharmacy
//
//  Created by abdalrahman essam on 5/8/19.
//  Copyright © 2019 MACBOOK. All rights reserved.
//

import UIKit

class DrugsFb {
    var name : String!
    var bar_code : String!
    var price : Double!
    var item_in_box : Int32!
    
    init(name : String , price : Double , bar_code : String , item_in_box : Int32) {
        self.name = name
        self.price = price
        self.bar_code = bar_code
        self.item_in_box = item_in_box
    }
    
    init() {}
}
