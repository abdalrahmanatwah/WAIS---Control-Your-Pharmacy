//
//  Alert.swift
//  Essam Atwah
//
//  Created by abdalrahman essam on 4/10/19.
//  Copyright © 2019 MACBOOK. All rights reserved.
//

import UIKit

class alertOrginal : NSObject {
    func CancelAlert(view : UIViewController , title : String , message : String){
        // create alert
        let alert = UIAlertController(title: title, message:message, preferredStyle: .alert)
        // alert action
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        // present the alert
        view.present(alert, animated: true, completion: nil)
    }    
}
