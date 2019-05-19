//
//  Account_App_Setting.swift
//  WAIS - Control Your Pharmacy
//
//  Created by abdalrahman essam on 5/2/19.
//  Copyright © 2019 MACBOOK. All rights reserved.
//

import UIKit
import Firebase

class Account_App_Setting: UIViewController , UITableViewDelegate , UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let setting = [
        ["Name"  , "Number Phone"],
        ["Delete The Salles every Month" , "Save My Salles Online"]
    ]
    let sections = [" "," "]

    //MARK: - UITableView

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return setting[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sections[section]
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell?
        
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "account_Info")// set the cell
            if cell == nil {
                // if we can't set the cell set it again
                cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "account_Info")
            }
        
            if indexPath.row == 0 {
                cell!.textLabel?.text = "Name"
                cell!.textLabel?.font = UIFont(name: "Acme-Regular", size: 17)
                cell!.detailTextLabel!.text = Let_Started.current_User.name
            } else {
                cell!.textLabel?.text = "Number Phone"
                cell!.textLabel?.font = UIFont(name: "Acme-Regular", size: 17)
                cell!.detailTextLabel!.text = Let_Started.current_User.number_phone
            }
            
        } else if indexPath.section == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "App Setting")
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "App Setting")
            }
            
            if indexPath.row == 0 {
                let switchButton = UISwitch()
                switchButton.addTarget(self, action: #selector(self.Delete(_:)), for: UIControlEvents.valueChanged)
                if let Delete = Let_Started.current_User.DeleteMonthly {
                    switchButton.isOn = Delete
                }
                cell!.accessoryView = switchButton
                cell!.textLabel?.text = "Delete The Salles every day"
            } else {
                let switchButton = UISwitch()
                switchButton.addTarget(self, action: #selector(self.SaveMySallesOnline(_:)), for: UIControlEvents.valueChanged)
                if let save = Let_Started.current_User.saveOnline {
                    switchButton.isOn = save
                }
                cell!.accessoryView = switchButton
                cell!.textLabel?.text = "Save My Salles Online"
            }
        }
        return cell!
    }
    
    //MARK: - Delete
    //DeleteSallesMonthly
    @objc func Delete(_ switchButton: UISwitch!) {
        if Reachability.isConnectedToNetwork(){
            // when the user change the value for those items
            if (switchButton.isOn){
                Salles.DeleteSallesMonthly = true
            }else{
                Salles.DeleteSallesMonthly = false
            }
            guard let uid = Let_Started.current_User.uid else {
                return
            }
            // upload the value to firebase
            let ref = Database.database().reference().child("Users").child(uid).child("DeleteMonthly")
            ref.setValue(switchButton.isOn)
        }else{
            error_handle(view: self, error : nil, hint: 1)
        }
        
    }
    //MARK: - SaveMySallesOnline
    @objc func SaveMySallesOnline(_ switchButton: UISwitch!) {
        if Reachability.isConnectedToNetwork(){
            // when the user change the value for those items
            if (switchButton.isOn){
                Salles.SaveSalles = true
            }else{
                Salles.SaveSalles = false
            }
            guard let uid = Let_Started.current_User.uid else {
                return
            }
            // upload the value to firebase
            let ref = Database.database().reference().child("Users").child(uid).child("SaveSalles")
            ref.setValue(switchButton.isOn)
        }else{
            error_handle(view: self, error : nil, hint: 1)
        }
    }
    
    //MARK: - back UIBarButtonItem
    @IBAction func back(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
}

