//
//  Login.swift
//  Lklas
//
//  Created by abdalrahman essam on 11/24/18.
//  Copyright © 2018 abdalrahman essam. All rights reserved.
//

import UIKit
import CountryPicker
import Firebase

class LoginVC : UIViewController , UITextFieldDelegate , CountryPickerDelegate {

    //MARK: - IBOutlet and variable
    @IBOutlet weak var number_phone: UITextField!//The number for the User
    @IBOutlet weak var sign_in: Button_Design!
    @IBOutlet weak var picker: CountryPicker!    // The country Picker

    
    var ref : DatabaseReference!
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    var timerGoToNextPage = Timer()
    var timerForInternet = Timer()// checker Internet
    var counterTheAlertAppear = 1 //counter The Alert "good press" Appear
    var InternetNotWork = UIView()// The internet not work View
    let alert = alertOrginal()
    
    public static var Users = [user]() // The main Array for all Users
    private var TheCodeCountry = "" // take the code because if the user write his number and the picker change don't delete his number
    private var OrgnailViewHeight : CGFloat = 0 // The height for the Orgnail view
    private static var internet : Bool = true // The internet is Work or Not
    public static var TheUsersGetted : Int = 3 // The variable has 3 value --> 0 : there is an error , 1 : get the users , 3 : The function get the user from firebase doesn't work

    
    //MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        getTheUsersFromFirebase()// if the user do log out and back to this view again
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        findYourCountryCode()// Find the Country Code
        // check if this user login before or not from this phone
        let defaults = UserDefaults.standard
        if let number = defaults.string(forKey: "Number") , number != "" {
            number_phone.text = number // get the number phone from local database and view it in textfeild
        }

        UIApplication.shared.statusBarStyle = .default // to make the status Bar black color
        // perpare the Internet Not Work View
        InternetNotWork = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 20))
        InternetNotWork.backgroundColor = UIColor.black
        // create a lable Internet Not Word
        let TheInternetNotWork = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 15))
        TheInternetNotWork.text = "The Internet Connection Is Not Work"
        TheInternetNotWork.textColor = UIColor.white
        TheInternetNotWork.textAlignment = .center
        TheInternetNotWork.font = UIFont(name: "Acme-Regular", size: 16)
        InternetNotWork.addSubview(TheInternetNotWork)
        // Add InternetNotWork View to The orignal view
        view.addSubview(InternetNotWork)
        // hide it as defulte
        InternetNotWork.isHidden = true
        // perpare the timer Checker the Internet
        timerForInternet = Timer.scheduledTimer(timeInterval: 0.1 , target: self, selector: #selector(timerInternetAction), userInfo: nil, repeats: true)
        // perpare the activity Indicator
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        view.addSubview(activityIndicator)
        // The firebase database reference
        ref = Database.database().reference()
        // the Orgnail height for The Screen
        OrgnailViewHeight = view.frame.origin.y
        // do the function keyboardWillShow when the keyboard open
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow),  name: NSNotification.Name.UIKeyboardWillShow, object: nil)// Show and Hide the keyboard utill writing
        // init number_phone
        self.number_phone.delegate = self
        
        
    }
    
    //MARK: - when the user touches the screen
    
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
    //MARK: - timer Internet Action

    @objc func timerInternetAction(){
        if Reachability.isConnectedToNetwork(){
            UIApplication.shared.isStatusBarHidden = false
            InternetNotWork.isHidden = true
            LoginVC.internet = true
            self.view.layoutIfNeeded()
        }else{
            LoginVC.internet = false
            UIApplication.shared.isStatusBarHidden = true
            InternetNotWork.isHidden = false
            self.view.layoutIfNeeded()
        }
    }
    //MARK: - Go To Code_Password ViewController

    @objc func GoToCode_PasswordController() {
        // Go The Code_Password ViewController
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(withIdentifier: "Code_Password") as? Code_Password
        self.present(vc!, animated: true, completion: nil)
        activityIndicator.stopAnimating()
        // if the User Is New one
        if (Code_Password.TheUserNew){
            // send to him a Verification code to verify his number phone
            guard let number : String = number_phone.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) else {return}
            
            PhoneAuthProvider.provider().verifyPhoneNumber(number, uiDelegate: nil, completion: { (Verification_Id, error) in
                if (Verification_Id != nil){
                    let defaults = UserDefaults.standard
                    defaults.set(Verification_Id, forKey: "Verification_Id")
                    defaults.set(number, forKey: "Number")
                }else {
                    error_handle(view: self, error: error!)
                    if (error != nil){print("ERROR NAME2 : \(String(describing: error?.localizedDescription))")}
                }
            })
        }
        sign_in.isEnabled = true // to enable it to if the user do logout and back to this screen again
    }
    
    
    //MARK: - Sign _ In _ Action
    @IBAction func Sign_In_Action(_ sender: Any) {
        sign_in.isEnabled = false // to don't allow to user repeat this action as many times
    
        guard var number : String = number_phone.text?.trimmingCharacters(in:  NSCharacterSet.whitespacesAndNewlines) else {return}
        // check this number is vaild or not
        let TheNumberVaildOrNot = checkTheNumberPhoneVaild(number : number)
        // check the internet
        if (Reachability.isConnectedToNetwork()){
            // if the number is vaild
            if (TheNumberVaildOrNot){
                activityIndicator.startAnimating()
                
                view.endEditing(true)// close the keyboard
                // back the Screen to Orignal size
                if(self.view.frame.origin.y < OrgnailViewHeight){
                    self.view.frame.origin.y += 50
                }
                
                // To make the number save as +201007642764
                if(number.count == 11){
                    number.insert("2", at: number.startIndex)
                    number.insert("+", at: number.startIndex)
                }
                // if the app get the user from firebase
                if (LoginVC.TheUsersGetted == 1){
                    UIApplication.shared.beginIgnoringInteractionEvents()// don't receive any interaction now
                    // get the user info (his Index in Users array , New or Old , Number) and save it
                    let info = getTheUserInfo(UserNumberPhone: number)
                    Code_Password.UserIndex = info.index
                    Code_Password.TheUserNew = info.New_Old
                    Code_Password.UserNumberPhone = number
                    
                    timerGoToNextPage = Timer.scheduledTimer(timeInterval: 3 , target: self, selector: #selector(GoToCode_PasswordController), userInfo: nil, repeats: false)// Go to next page after 3 sec
                    
                    UIApplication.shared.endIgnoringInteractionEvents()// start receive interaction
                    
                }else if (LoginVC.TheUsersGetted == 0){ // if there is error
                    sign_in.isEnabled = true // open the button
                    
                    // make the alert  "Good press" only one time otherwies the internet is not work
                    if (counterTheAlertAppear > 0){
                        alert.CancelAlert(view : self , title : "Good press" , message : "But we want a stronger than this one?")
                        counterTheAlertAppear -= 1;
                    }else if (counterTheAlertAppear == 0){
                        error_handle(view: self, error : nil, hint: 1)
                        counterTheAlertAppear -= 1;
                    }
                    getTheUsersFromFirebase()// get the user because the users didn't getted
                    activityIndicator.stopAnimating() // stop the activity Indicator
                }
                
            }else{
                // if the number phone is invaild
                sign_in.isEnabled = true
                alert.CancelAlert(view : self , title : "The Phone Number is invalid" , message : "Please, Write a correct number phone")
            }
        }else{
            // if the internet is not work
            sign_in.isEnabled = true
            error_handle(view: self, error : nil, hint: 1)
        }
        
    }
    
    
   
    
    
    //MARK: - Picker View Country Code
    func findYourCountryCode(){
        //get corrent country
        let locale = Locale.current
        let code = (locale as NSLocale).object(forKey: NSLocale.Key.countryCode) as! String?
        //init Picker
        picker.countryPickerDelegate = self
        picker.showPhoneNumbers = true
       
        picker.setCountry(code!)
    }
    // if the user select any one in the picker
    func countryPhoneCodePicker(_ picker: CountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        
        guard let number = number_phone.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {return}
        // The code coutry : the perivse phone Code the user selected
        // save the number which the user write if he changes the phone code

        if (number == "" || number == TheCodeCountry || number.count <= TheCodeCountry.count){
            TheCodeCountry = phoneCode
            number_phone.text = phoneCode
        }else{
            // delete the phone code and get the number which the user write
            var TheNumberWithOutCode = ""
            for i in TheCodeCountry.count...number.count-1 {
                let index = number.index(number.startIndex, offsetBy: i)
                TheNumberWithOutCode.append(number[index])
            }
            if (TheNumberWithOutCode != ""){
                number_phone.text = "\(phoneCode)\(TheNumberWithOutCode)"
            }else{
                number_phone.text = phoneCode
            }
            TheCodeCountry = phoneCode
        }
    }
    
    // to add the country code to textview before the user start wirte his number
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (number_phone.text == "") {
            findYourCountryCode()
        }
    }
    // get the current user info from loginVC.User
    func getTheUserInfo(UserNumberPhone : String) -> (New_Old : Bool,index : Int) {
        if (!LoginVC.Users.isEmpty){
            for i in 0...LoginVC.Users.count-1 {
                if(LoginVC.Users[i].number_phone == UserNumberPhone){
                    return (false,i)
                }
            }
        }
        return (true,-1)
    }
    
    // check the number vaild or Not
    // formal 1 -  +2010 , +2015  , +2011 , +2012
    //        2 -  010   , 015    , 011   , 012
    func checkTheNumberPhoneVaild(number : String) -> Bool{
        var S = [Character]()
        
        if (number == "") {return false}
        for I in 0 ... number.count-1 {
            let i = number.index(number.startIndex, offsetBy: I)
            S.append(number[i])
        }

        if(S.count == 11 || S.count == 13 ){
            //+2010 , +2015  , +2011 , +2012
            if(S[0] == "+" && S[1] == "2" && S[2] == "0" && S[3] == "1"){
                if (S[4] == "0" || S[4] == "5" || S[4] == "1" || S[4] == "2" ){
                    return true
                }
            }else if (S[0] == "0" && S[1] == "1" ){
                // 010 , 015 , 011 , 012
                if (S[2] == "0" || S[2] == "5" || S[2] == "1" || S[2] == "2"){
                    return true
                }
            }
        }
        return false
    }
    // get the users from firebase database
    func getTheUsersFromFirebase(){
        if (LoginVC.TheUsersGetted == 3 || LoginVC.TheUsersGetted == 0){
            
            let ref = Database.database().reference()
            
            ref.child("Users").observe(.childAdded , with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    if let Uid = snapshot.key as? String {
                        
                        let user1 = user(name : dictionary["Name"] as! String ,number : dictionary["Phone"]  as! String, password : dictionary["Password"] as! String , uid : Uid , saveOnline : dictionary["SaveSalles"] as! Bool , DeleteMonthly : dictionary["DeleteMonthly"] as! Bool)
                        // check if the user already added
                        let theUserIsAddedBefore = LoginVC.Users.contains(where: { (user) -> Bool in
                            if (user.uid == Uid){
                                return true
                            }
                            return false
                        })
                        
                        if (!theUserIsAddedBefore){
                            LoginVC.Users.append(user1)
                        }
                        LoginVC.TheUsersGetted = 1 // The Users Getted
                    }
                }
            }) { (error) in
                print("Error Name Code_Password : \(error.localizedDescription)")
                error_handle(view: self, error: error)
                LoginVC.TheUsersGetted = 0 // that's meaning there is an user didn't get his info.
            }
            print("GET THE USERS DONE")
        }
    }
    
}


/// write an algrithm to change the country code without delete all the number

// let theme = CountryViewTheme(countryCodeTextColor: .white, countryNameTextColor: .white, rowBackgroundColor: .black, showFlagsBorder: true) //optional
// picker.theme = theme //optional
