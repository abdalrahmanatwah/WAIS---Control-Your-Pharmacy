//
//  SaveInCoreData.swift
//  Essam Atwah
//
//  Created by abdalrahman essam on 4/12/19.
//  Copyright © 2019 MACBOOK. All rights reserved.
//

import UIKit

func saveInCoreData(){
    do{
        ad.saveContext()
    }catch{
        print(error.localizedDescription)
        print("error in saveing the data in CoreData on add To Sales in Selling VC")
    }
}
