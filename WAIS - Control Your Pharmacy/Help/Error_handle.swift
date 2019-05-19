//
//  Error_handle.swift
//  Essam Atwah
//
//  Created by abdalrahman essam on 4/28/19.
//  Copyright © 2019 MACBOOK. All rights reserved.
//

import UIKit

// hint number 1 : The internet Is Not Work



func error_handle(view : UIViewController , error : Error?  , hint : Int = 0){
    
    var message = "Error on The phone. Please restart the app"
    var title = "Error"
    
    let alert = alertOrginal()
    
    if (hint != 0){
        switch hint {
            case 1 :
                title = "The Internet Is Not Work"
                message = "Please, Check your connection"
                break
            default:
                break
        }
        
    }else if (error != nil){
         if error?.localizedDescription == "The password is invalid or the user does not have a password." {
            message = "Write a correct Password"
        } else if error?.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred."{
            message = "The Internet connection is not work"
        }else if error?.localizedDescription == "The SMS verification code used to create the phone auth credential is invalid. Please resend the verification code SMS and be sure to use the verification code provided by the user."{
            message = "This verification code is not correct. Be sure you wrote a correct number"
        }
    }
    
    
    alert.CancelAlert(view: view, title: title, message: message)
    
}
