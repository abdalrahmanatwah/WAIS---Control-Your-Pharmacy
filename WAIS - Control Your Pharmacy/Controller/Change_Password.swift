//
//  Change_Password.swift
//  WAIS - Control Your Pharmacy
//
//  Created by abdalrahman essam on 5/5/19.
//  Copyright © 2019 MACBOOK. All rights reserved.
//

import UIKit
import Firebase

class Change_Password: UIViewController {
    /*
    To change his password the user must write the corrent password after he wrote it check the password if it correct, Allow to him to write a new password and repeat it one more time
    */
    
    //MARK: - IBOutlet and variable
    @IBOutlet weak var password_1: UITextField!
    @IBOutlet weak var password_2: UITextField!
    @IBOutlet weak var cahngeOutlet: UIButton!

    let alert = alertOrginal()
    
    private let old_Password : String = Let_Started.current_User.password // The corrent password
    private let uid : String = Let_Started.current_User.uid // The user Id
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        password_1.placeholder = "Please, Write the current password"
        password_2.text = ""
        password_2.isHidden = true // close the password_2 until the user write the correct password
        cahngeOutlet.setTitle("Verify", for: .normal)
        
    }
    //MARK: - back bar item button

    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    //MARK: - changeButton

    @IBAction func changeButton(_ sender: Any) {
        
        guard let ThePasswordFromUser : String = password_1.text?.trimmingCharacters(in: .newlines) else {return}
        guard let ThePasswordFromUser_2 : String = password_2.text?.trimmingCharacters(in: .newlines) else {return}

        if (ThePasswordFromUser == old_Password && ThePasswordFromUser_2 == ""){
            // check the password which the user write is the correct password
            password_2.isHidden = false // view the password_2
            
            password_1.placeholder = "Please, Write a New password"
            password_2.placeholder = "The password must be more than 7 Character"
           
            password_1.text = ""
            cahngeOutlet.setTitle("Change", for: .normal)
            self.loadViewIfNeeded()
            // if the password 2 opened and the user wrote in it.
        }else if (ThePasswordFromUser_2 != ""){
            // check the password more than 7
            if (Int(ThePasswordFromUser.count) >= 7 && Int(ThePasswordFromUser_2.count) >= 7){
                
                if (ThePasswordFromUser == ThePasswordFromUser_2 ){
                    
                    if (Reachability.isConnectedToNetwork()){
                        // upload the new password to firebase database
                        let ref = Database.database().reference().child("Users").child(uid).child("Password")
                        ref.setValue(ThePasswordFromUser)
                        Let_Started.current_User.password = ThePasswordFromUser// updata the password in the current_User
                        alert.CancelAlert(view: self, title: "Successful", message: "Your password changed")
                    }else{
                        error_handle(view: self, error : nil, hint: 1)
                    }
                    
                }else{
                    alert.CancelAlert(view: self, title: "Invalid Password", message: "The password is not match")
                }
                
            }else{
                alert.CancelAlert(view: self, title: "Invalid Password", message: "The password must be equal or more than 7 Character")
            }
        }else{
            alert.CancelAlert(view: self, title: "Invalid Password", message: "The password is not match")
        }
    }
    
}
