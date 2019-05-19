//
//  DrugsNeedModel.swift
//  Essam Atwah
//
//  Created by abdalrahman essam on 4/14/19.
//  Copyright © 2019 MACBOOK. All rights reserved.
//

import UIKit

class DrugsNeed_NotSold_Model {
    var name : String?
    var index : Int? // index in all drugs
    
    init(name : String , index : Int) {
        self.name = name
        self.index = index
    }
}
