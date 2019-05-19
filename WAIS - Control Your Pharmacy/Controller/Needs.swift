
//
//  Needs_Table.swift
//  Essam Atwah
//
//  Created by abdalrahman essam on 4/14/19.
//  Copyright © 2019 MACBOOK. All rights reserved.
//

import UIKit

class Needs: UIViewController , UITableViewDelegate , UITableViewDataSource {
    
    @IBOutlet weak var table_View: UITableView!

    var RefreshControl : UIRefreshControl!

    // Take the name an the index for each drug here. We will use the index when The user add a new amount
    static var DrugsWantToBuy = [DrugsNeed_NotSold_Model]()
    
    
    
    //MARK: - view Will Appear
    
    override func viewWillAppear(_ animated: Bool) {
        table_View.reloadData()
        GetTheNeedsTable()// Get The Needs Table from All drugs
        table_View.reloadData()
    }
    
    //MARK: - view Did Load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        RefreshControl = UIRefreshControl()
        RefreshControl.addTarget(self, action: #selector(self.Refresh), for: UIControlEvents.valueChanged)
        table_View.addSubview(RefreshControl)
        self.navigationController?.hidesBarsOnSwipe = true

        GetTheNeedsTable()
    }
    
   
    //MARK: - Refresh
    
    @objc func Refresh(){
        GetTheNeedsTable()
        table_View.reloadData()
        RefreshControl.endRefreshing()
    }
    
    
    //MARK: - Get The Needs Table
    
    func GetTheNeedsTable(){
        // checking on all drugs on varabile need_Buy
        if (All_Drugs.Dru.count != 0 ){ // because sometimes the array wasn't انيشليزيشن
            Needs.DrugsWantToBuy.removeAll() // be sure the array don't have value from pervious search
            for i in 0...All_Drugs.Dru.count-1 {
                if(All_Drugs.Dru[i].need_buy){
                    let CurrentDrug = DrugsNeed_NotSold_Model(name : All_Drugs.Dru[i].name! , index : i)
                    Needs.DrugsWantToBuy.append(CurrentDrug)
                }
            }
            
        }
        // sort the need table ASC
        Needs.DrugsWantToBuy = Needs.DrugsWantToBuy.sorted { (D1, D2) -> Bool in
            return (D2.name! > D1.name!)
        }
    }
    
   
    //MARK: - UI Table View Data Surces
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Needs.DrugsWantToBuy.count
    }
    
    //MARK: -  UI Table View Delegate
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = Needs.DrugsWantToBuy[indexPath.row].name!
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //MARK: - add amount to this drug
        let alert = UIAlertController(title: "How Many Boxs Will Darg Into Your Pharamcy?", message: "Enter a number of Boxs !!!", preferredStyle: .alert)
        // create textfield to take number of boxs will add
        
        alert.addTextField { (text1) in
            text1.keyboardType = .numberPad
            text1.textAlignment = .center
            text1.placeholder = "Write an INTGER number of boxs will add"
            text1.font = UIFont(name: "Acme-Regular", size: 15)
        }
        
        alert.addAction(UIAlertAction(title: "Add", style: .cancel, handler: { (d) in
            guard let Index1 = Needs.DrugsWantToBuy[indexPath.row].index else {
                return
            }
            let drug = All_Drugs.Dru[Index1]

            if let AmountWillAdd = alert.textFields![0].text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines){
                
                var checkIfAllNumberISCorrect = true // the user enter an Engilsh number or Not
                // To check if the user enter an Engilsh number or not
                for Each_char in AmountWillAdd {
                    if (!(Each_char >= "0" && Each_char <= "9")){
                        checkIfAllNumberISCorrect = false
                    }
                }
                
                // The number must be Intager
                if let AmonuntInt = Int(AmountWillAdd) , AmonuntInt != 0  && checkIfAllNumberISCorrect {
                    let Amount_Float_After_be_Int = Float(AmonuntInt) // because The Amount is float , it can has a strips
            
                    drug.amount += Amount_Float_After_be_Int // add it on the orgnail Drug
                    drug.need_buy = false //delete it from Needs Salles Table
                    
                    saveInCoreData()// Save the new amount in Codedata
            
                    self.table_View.reloadData() // To delete it from Needs Table
                }else{
                    let vc = alertOrginal()
                    vc.CancelAlert(view: self, title: "Error", message: "Plaese, Enter A Correct Number !!!")
                }
            }
            
        }))
        alert.addAction(UIAlertAction(title: "cancel", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}


