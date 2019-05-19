//
//  About_Report.swift
//  Essam Atwah
//
//  Created by abdalrahman essam on 4/29/19.
//  Copyright © 2019 MACBOOK. All rights reserved.
//

import UIKit
import Firebase

class About_Report: UIViewController {
    
    //MARK: - IBOutlet and variable
    
    @IBOutlet weak var text_View: UITextView!
    @IBOutlet weak var send_outLet: UIButton!
    
    let alert = alertOrginal()
    
    // Zreo meaning About , one meaning report
    var about_report : Int!
    private var OrgnailViewHeight : CGFloat = 0 // The height for the Orgnail view

    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        text_View.layer.cornerRadius = 8
        perpareTheView()
    }
    
    
    
    //MARK: - when the user touches the screen
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
        if(self.view.frame.origin.y < OrgnailViewHeight){
            self.view.frame.origin.y += 50 // back the Screen to Orignal size
        }
    }
    //MARK: - keyboardWillShow
    @objc func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= 50 // Scroll the Screen up
            }
        }
    }
    //MARK: - send_Action
    @IBAction func send_Action(_ sender: UIButton) {
        if Reachability.isConnectedToNetwork() {
            // upload his problem on firebase
            guard let problem = text_View.text , problem != "" else {return}
            // the user phone to view it on firebase to this person and contect him
            let UserNumber = Let_Started.current_User.number_phone
            let ref = Database.database().reference().child("Problems").childByAutoId()
            ref.setValue(["user_number" : UserNumber , "Problem" : problem])
            
            // create alert
            let alert = UIAlertController(title: "Thanks Sir", message:"Now, You Helped us To improve Our Services .\nWe will conract", preferredStyle: .actionSheet)
            // alert action
            alert.addAction(UIAlertAction(title: "Thanks", style: .destructive, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
            }))
            // present the alert
            present(alert, animated: true, completion: nil)
        }else{
            error_handle(view: self, error : nil, hint: 1)
        }
    }
    
    //MARK: - back UIBarButtonItem
    @IBAction func back(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - perpareTheView
    func perpareTheView(){
        if (about_report == 0){
            // About
            send_outLet.isHidden = true
            text_View.isEditable = false
            text_View.text = "About us"
        }else if (about_report == 1){
            // Report for a problem
            send_outLet.isHidden = false
            text_View.isEditable = true
        }
    }
    
}
