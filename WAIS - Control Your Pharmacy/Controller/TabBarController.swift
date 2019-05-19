//
//  TabBarController.swift
//  WAIS - Control Your Pharmacy
//
//  Created by abdalrahman essam on 5/12/19.
//  Copyright © 2019 MACBOOK. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.gray , NSAttributedStringKey.font : UIFont(name: "Acme-Regular", size: 11)!], for:.normal)
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor(red: 0, green: 128/255, blue: 1, alpha: 1) , NSAttributedStringKey.font : UIFont(name: "Acme-Regular", size: 11)!], for:.selected)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
