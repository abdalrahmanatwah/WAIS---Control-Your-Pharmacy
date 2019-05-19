//
//  Setting.swift
//  Essam Atwah
//
//  Created by abdalrahman essam on 4/27/19.
//  Copyright © 2019 MACBOOK. All rights reserved.
//

import UIKit
import Firebase

class Setting: UIViewController , UITableViewDelegate , UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    
    let alert = alertOrginal()
    
    var sa : [String] = ["Enter New Drugs", "Account Setting" , "Change Password" , "Report a Problem" , "About" , "Log Out"]
    var im : [String] = ["Enter", "Account" , "Reset" , "Report" , "About" , "Log"]
    
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sa.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = sa[indexPath.row]
        let image = UIImage(named: im[indexPath.row])!
        cell.imageView?.image = image
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.reloadData()
        
        switch indexPath.row {
        case 0:
            Enter_Data()
        case 1:
            Profile_InfoFunction()
        case 2:
            RestPassword()
        case 3:
            aboutORreport(index : 1) // report about problem
        case 4:
            aboutORreport(index : 0) // About us
        case 5:
            Log_Out()
        default:
            break
        }
        
    }
    
    func Profile_InfoFunction(){
        let vc  = self.storyboard?.instantiateViewController(withIdentifier: "Account_App_Setting") as! Account_App_Setting
        let navController = UINavigationController(rootViewController: vc)
        present(navController, animated: true, completion: nil)
    }
    
    func aboutORreport(index : Int){
        // index number Zreo meaning About , index number one meaning report
        let vc  = self.storyboard?.instantiateViewController(withIdentifier: "About_Report") as! About_Report
        let navController = UINavigationController(rootViewController: vc)
        vc.about_report = index
        present(navController, animated: true, completion: nil)
    }
    
    func Enter_Data(){
        let vc  = self.storyboard?.instantiateViewController(withIdentifier: "EnterData") as! EnterData
        let navController = UINavigationController(rootViewController: vc)
        present(navController, animated: true, completion: nil)
    }
    
    func Log_Out(){
        if Reachability.isConnectedToNetwork(){
            LoginVC.TheUsersGetted = 3
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
            window1.rootViewController = vc
            do{
                try? Auth.auth().signOut()
            }
        }else{
            error_handle(view: self, error : nil, hint: 1)
        }
    }
    
    func RestPassword(){
        let vc  = self.storyboard?.instantiateViewController(withIdentifier: "Change_Password") as! Change_Password
        let navController = UINavigationController(rootViewController: vc)
        present(navController, animated: true, completion: nil)
    }
}
