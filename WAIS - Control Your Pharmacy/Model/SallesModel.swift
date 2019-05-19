//
//  SallesModel.swift
//  Essam Atwah
//
//  Created by abdalrahman essam on 4/14/19.
//  Copyright © 2019 MACBOOK. All rights reserved.
//

import UIKit
class SallesModel {
    var name : String?// The salles name
    var date : String? // The salles date
    var money : Double?// The salles money
    
    init(name : String , data : String , money  : Double) {
        self.name = name
        self.date = data
        self.money = money
    }
}
