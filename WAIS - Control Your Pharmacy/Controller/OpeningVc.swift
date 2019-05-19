//
//  OpeningVc.swift
//  WAIS - Control Your Pharmacy
//
//  Created by abdalrahman essam on 5/11/19.
//  Copyright © 2019 MACBOOK. All rights reserved.
//

import UIKit
import Firebase

class OpeningVc: UIViewController {
    //MARK: - IBOutlet and variable

    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    var timer = Timer()
    
    @IBOutlet weak var Back_Ground_image: UIImageView!
    
    //MARK: - IBOutlet and variable
    override func viewDidLoad() {
        super.viewDidLoad()
        Back_Ground_image.isHidden = false // to be sure the next screens don't view any thing
        //activity Indicator info
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        getTheUsers() // get the user from firebase
        timer = Timer.scheduledTimer(timeInterval: 3 , target: self, selector: #selector(timerAction), userInfo: nil, repeats: false)// after 3 sec go to login page
    }
    
    //MARK: - IBOutlet and variable
    @objc func timerAction(){
        Back_Ground_image.isHidden = true
        activityIndicator.stopAnimating()
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        let d = UIApplication.shared.delegate as! AppDelegate
        d.window?.rootViewController = vc // make the tab bar root View Controller
    }
    
    //MARK: - IBOutlet and variable
    func getTheUsers(){
        if (LoginVC.TheUsersGetted == 3 || LoginVC.TheUsersGetted == 0){
            
            let ref = Database.database().reference()
            
            ref.child("Users").observe(.childAdded , with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    if let Uid = snapshot.key as? String {
                        
                        let user1 = user(name : dictionary["Name"] as! String ,number : dictionary["Phone"]  as! String, password : dictionary["Password"] as! String , uid : Uid , saveOnline : dictionary["SaveSalles"] as! Bool , DeleteMonthly : dictionary["DeleteMonthly"] as! Bool)
                        
                        let theUserIsAddedBefore = LoginVC.Users.contains(where: { (user) -> Bool in
                            if (user.uid == Uid){
                                return true
                            }
                            return false
                        })
                        
                        if (!theUserIsAddedBefore){
                            LoginVC.Users.append(user1)
                        }
                        LoginVC.TheUsersGetted = 1
                    }
                }
            }) { (error) in
                print("Error Name Code_Password : \(error.localizedDescription)")
                LoginVC.TheUsersGetted = 0 // that's meaning there is an user didn't get his info.
            }
            print("GET THE USERS DONE")
        }
    }
}
