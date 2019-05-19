//
//  user.swift
//  WAIS - Control Your Pharmacy
//
//  Created by abdalrahman essam on 4/30/19.
//  Copyright © 2019 MACBOOK. All rights reserved.
//

import UIKit

class user {
    var name : String!
    var number_phone : String!
    var password : String!
    var uid : String!
    var saveOnline : Bool!
    var DeleteMonthly : Bool!

    init(name : String , number : String , password : String , uid : String , saveOnline : Bool , DeleteMonthly : Bool) {
        self.name = name
        self.number_phone = number
        self.password = password
        self.uid = uid
        self.saveOnline = saveOnline
        self.DeleteMonthly = DeleteMonthly
    }
    
    init() {}
}
