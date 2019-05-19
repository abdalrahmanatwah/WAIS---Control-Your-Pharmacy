//
//  User_Info.swift
//  WAIS - Control Your Pharmacy
//
//  Created by abdalrahman essam on 5/1/19.
//  Copyright © 2019 MACBOOK. All rights reserved.
//

import UIKit
import Firebase
import IBAnimatable

class User_Info: UIViewController , UITextFieldDelegate {
    
    //MARK: - IBOutlet and variable
    @IBOutlet weak var your_info: UILabel!
    @IBOutlet weak var name: AnimatableTextField!
    @IBOutlet weak var password: AnimatableTextField!
    @IBOutlet weak var Re_password: AnimatableTextField!
    @IBOutlet weak var startOutlet: Button_Design!

    let alert = alertOrginal()
    
    private var OrgnailViewHeight : CGFloat = 0 // The height for the Orgnail view

    
    //MARK: - view Did Load

    override func viewDidLoad() {
        super.viewDidLoad()
        //startOutlet.isEnabled = false // close the button untill the user fill his info
        OrgnailViewHeight = view.frame.origin.y // pass the height for the view to the varibale
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil) // when the keyboard open do this function
        UIApplication.shared.statusBarStyle = .default // make the status bar black
        // init textfeild
        password.delegate = self
        Re_password.delegate = self
        // hide the re password untill the user write a correct password
        Re_password.isHidden = true

    }
    
    //MARK: - touches Began

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
        if(self.view.frame.origin.y < OrgnailViewHeight){
            self.view.frame.origin.y += 50 // back the Screen to Orignal size
        }
    }
    //MARK: - keyboard Will Show
    @objc func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= 50 // Scroll the Screen up
            }
        }
    }
    
    //MARK: - start action button
    @IBAction func start(_ sender: Any) {
        
        if Reachability.isConnectedToNetwork(){
            view.endEditing(true)// close the keyboard
            
            // take the values from textfeilds
            guard let Name = name.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                , Name != "" && !Name.isEmpty else {return}
            guard var Password = password.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                , Password != "" && !Password.isEmpty else {return}
            guard let Re_pass = Re_password.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                , Re_pass != "" && !Re_pass.isEmpty else {return}
            // check if the password matched
            if (Password == Re_pass){
                // save the user in firebase database
                if let currentUser = Auth.auth().currentUser {
                    let ref = Database.database().reference().child("Users")
                    
                    Let_Started.current_User = user(name: Name, number: Code_Password.UserNumberPhone, password: Password , uid : currentUser.uid , saveOnline : true , DeleteMonthly : true)
                    
                    Password = Password + "💙Zahra💙" + Password // to uncode the password 
                    
                    ref.child(currentUser.uid).setValue(
                        ["Name": Name , "Phone": Code_Password.UserNumberPhone , "Password": Password , "DeleteMonthly" : true , "SaveSalles" : true]
                        , withCompletionBlock: { (error, d) in
                            if(error != nil){
                                print("ERROR NAME USER_INFO : \(String(describing: error?.localizedDescription))")
                                error_handle(view: self, error : error)
                            }
                    })
                    
                    alert.CancelAlert(view: self, title: "Register Successful", message: "We will Call you to verify your password")
                    
                    // go the next screen
                    let sb = UIStoryboard(name: "Main", bundle: nil)
                    let vc = sb.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                    window1.rootViewController = vc
                }
                
            }else{
                // To make the user know the password is not match becasue the password is not appear, So he didn't know if the password match or not
                // See line 120 in this file
                alert.CancelAlert(view: self, title: "The Password Is Not Matched", message: "Please, Write the same password in password section and re-password section")
            }
        }else{
            error_handle(view: self, error : nil, hint: 1)
        }
    }
    
    //MARK: - Checking_Password button action
    @IBAction func Checking_Password(_ sender: Any) {
        guard let pass = password.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {return}
        // The password must be more than or equal 7
        if (Int(pass.count) >= 7){
            Re_password.isHidden = false
        }else{
            Re_password.isHidden = true
            Re_password.text = ""
        }
    }
    
    //MARK: - Checking_Re_Password button Action
    @IBAction func Checking_Re_Password(_ sender: Any) {
        guard let pass = password.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {return}
        guard let REpass = Re_password.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {return}
        if (REpass == pass){
            // I didn't use this function To make the user know the password is not match becasue the password is not appear, So he didn't know if the password match or not
            // when the password and re_password Equal open the button
            //startOutlet.isEnabled = true
        }
    }
   
}
