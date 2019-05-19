//
//  Code_Password.swift
//  WAIS - Control Your Pharmacy
//
//  Created by abdalrahman essam on 4/30/19.
//  Copyright © 2019 MACBOOK. All rights reserved.
//

import UIKit
import Firebase
import IBAnimatable

class Code_Password: UIViewController , UITextFieldDelegate {
    
    //MARK: - IBOutlet and variable
    @IBOutlet weak var number_phone: UILabel!
    @IBOutlet weak var SMS_Password: UILabel!
    @IBOutlet weak var code_Name_OR_Old_Password: AnimatableTextField!
    @IBOutlet weak var verify_SetPassword: AnimatableButton!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var nv: UINavigationBar!
    @IBOutlet weak var backGroundImage: UIImageView!
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var timer = Timer()
    let alert = alertOrginal()
    
    
    static var UserNumberPhone : String = "" // The number phone To display it on Screen
    static var UserIndex : Int = -1 // The index for old user on USERS array
    static var TheUserNew : Bool = false // This user is new
    private var OrgnailViewHeight : CGFloat = 0 // The height for the Orgnail view
    private static var PASSWORD : String = "" // verify the Correct password with the password which the user write
    //MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        verify_SetPassword.isEnabled = true // Be sure the button open
        
        nv.setBackgroundImage(UIImage(), for: .default) // to give Navigation Bar the color for the orgnail background
        
        // perpare the activity Indicator
        activityIndicator.center = CGPoint(x: view.center.x, y: verify_SetPassword.center.y+200+verify_SetPassword.frame.height)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        view.addSubview(activityIndicator)
        
        OrgnailViewHeight = view.frame.origin.y // pass the height for the view to the varibale
        
        UIApplication.shared.statusBarStyle = .default // make the status bar black
        code_Name_OR_Old_Password.delegate = self // init textfeild

        // if the user is New user, We will take his Ver Code
        if (Code_Password.TheUserNew){
            code_Name_OR_Old_Password.keyboardType = .numberPad // Take Code
            code_Name_OR_Old_Password.isSecureTextEntry = false // tha't Ver Code
            code_Name_OR_Old_Password.placeholder = "Code"
            verify_SetPassword.setTitle("Verify", for: .normal) // set the button title Verify
            number_phone.text = Code_Password.UserNumberPhone // The Number phone for the user
            SMS_Password.text = "We have sent you an SMS with the code" // lable
        }else{
            // if the user is old user We will take his password
            code_Name_OR_Old_Password.keyboardType = .default
            let userName : String = LoginVC.Users[Code_Password.UserIndex].name
            let userpassword : String = LoginVC.Users[Code_Password.UserIndex].password

            number_phone.text = "Welcome back \(userName)"
            SMS_Password.text = "Where were you from long time? \n Enter your password"
            code_Name_OR_Old_Password.isSecureTextEntry = true // We will take his passwrod
            code_Name_OR_Old_Password.placeholder = "Password"
            verify_SetPassword.setTitle("Sign In", for: .normal)
            Code_Password.PASSWORD = userpassword // To check The password after the user write
        }
    }
    //MARK: - Sign _ In _ Action

    @objc func GoToNextScreenLet_Started() {
        hideAllThings()
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "Let_Started") as? Let_Started
        window1.rootViewController = vc
        verify_SetPassword.isEnabled = true // to enable it to if the user do logout and back to this screen again
        backGroundImage.isHidden = true
    }
    
    //MARK: - When the user touche the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
    }
    
    //MARK: - back button Action
    @IBAction func back_Action(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: - verify button action
    @IBAction func verify_SetPassword_Action(_ sender: Any) {
        
        view.endEditing(true)// close The keyboard
       
        // The Code or The password
        guard let C_P = code_Name_OR_Old_Password.text?.trimmingCharacters(in: .newlines) ,
            C_P != "" && !C_P.isEmpty else{return}
        // The user is new one
        if (Code_Password.TheUserNew){
            if Reachability.isConnectedToNetwork(){
                activityIndicator.startAnimating()
                UIApplication.shared.beginIgnoringInteractionEvents()
                CheckTheCode()// verify the code which he wrote
            }else{
                error_handle(view: self, error : nil, hint: 1)
            }
        }else{
            // The user is old one
            if(Code_Password.PASSWORD == C_P){
                // after 1.5 sec go to Let_Started ViewController
                activityIndicator.startAnimating()
                UIApplication.shared.beginIgnoringInteractionEvents()
                timer = Timer.scheduledTimer(timeInterval: 1.5 , target: self, selector: #selector(GoToNextScreenLet_Started), userInfo: nil, repeats: false)
            }else{
                if (Code_Password.PASSWORD.contains("💙")){
                    alert.CancelAlert(view: self, title: "Your Account is pending", message: "If you want to open your account Now Call this number \n +201007642764")
                }else{
                    alert.CancelAlert(view: self, title: "Invaild Password", message: "Please, Write the courrect password \nIf you forget the password call this number \n +201007642764")
                }
            }
        }
        UIApplication.shared.endIgnoringInteractionEvents()// Start receive interaction from screen
    }
    
    
    //MARK: - Check The Code Action
    func CheckTheCode(){
        // save the number on the local database
        let defaults = UserDefaults.standard
        let Id = defaults.string(forKey: "Verification_Id")!
        // Close the bar button
        backButton.isEnabled = false

        guard let code = code_Name_OR_Old_Password.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {return}
        // verfiy the code to this number by firebase credential
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: Id, verificationCode: code)
        Auth.auth().signInAndRetrieveData(with: credential) { (user, error) in
            if (user != nil){
                // if the code is correct go to User_Info
                self.hideAllThings()// hide the objects in the screen because it will be the main screen
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "User_Info") as? User_Info
                window1.rootViewController = vc
                self.backGroundImage.isHidden = true
            }else{
                self.activityIndicator.stopAnimating()
                self.loadViewIfNeeded()
                error_handle(view: self, error: error!)
                self.code_Name_OR_Old_Password.text = "" // delete any thing here because it's non correct
                self.backButton.isEnabled = true // open the BACK bar button
            }
        }
    }
    
    //MARK: - hide All Things
    // hide the objects in the screen because it will be the main screen
    func hideAllThings(){
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        number_phone.isHidden = true
        SMS_Password.isHidden = true
        code_Name_OR_Old_Password.isHidden = true
        verify_SetPassword.isHidden = true
        nv.isHidden = true
    }
}
