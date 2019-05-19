//
//  each_Drug.swift
//  Essam Atwah
//
//  Created by abdalrahman essam on 3/21/19.
//  Copyright © 2019 MACBOOK. All rights reserved.
//

import UIKit

class each_Drug: UIViewController , UITableViewDelegate , UITableViewDataSource {
   
    //MARK: - IBOutlet and variable
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var Item_In_Box: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var back: UIBarButtonItem!

    var drug : Drug!{
        didSet{}
    }
    
    override func viewWillAppear(_ animated: Bool) {
        SortTheSallesByData() // sort The salles array
    }
    
    //MARK: - view Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        // To view the info for selected drug
        if let nameOpt = drug?.name {name.text = nameOpt}
        if let priceOpt = drug?.price {price.text = String(priceOpt)}
        if let amountOpt = drug?.amount {amount.text = String(amountOpt)}
        if let Item_In_BoxOpt = drug?.iteminbox {Item_In_Box.text = String(Item_In_BoxOpt)}
        if let typeOpt = drug?.type {type.text = typeOpt}
        
    }
    //MARK: - backAction
    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    //MARK: - add amount to this drug
    @IBAction func add_amount(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "How Many Boxs Will Add?", message: "Enter a number of Boxs !!!", preferredStyle: .alert)
        
        // create textfield to take number of boxs will add
        alert.addTextField { (text1) in
            text1.keyboardType = .numberPad
            text1.textAlignment = .center
            text1.placeholder = "Write an INTGER number of boxs"
            text1.font = UIFont(name: "Acme-Regular", size: 15)
        }
        
        alert.addAction(UIAlertAction(title: "Add", style: .cancel, handler: { (d) in
            if let AmountWillAdd = alert.textFields![0].text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines){
                
                var checkIfAllNumberISCorrect = true // the user enter an Engilsh number or Not
                // To check if the user enter an Engilsh number or not
                for Each_char in AmountWillAdd {
                    if (!(Each_char >= "0" && Each_char <= "9")){
                        checkIfAllNumberISCorrect = false
                    }
                }
                
                if (checkIfAllNumberISCorrect){
                    if let AmonuntInt = Int(AmountWillAdd) , AmonuntInt != 0 { // The number must be Intager
                        let Amount_Float_After_be_Int = Float(AmonuntInt)// because The Amount is float , it can has a strips
                        
                        self.drug.amount += Amount_Float_After_be_Int // add it on the orgnail Drug
                        self.drug.need_buy = false //delete it from Needs Salles Table
                        self.amount.text = String(self.drug.amount)// update the Amount on the screen
                        saveInCoreData()// Save the new amount in Codedata
                    }
                }else{
                    let vc = alertOrginal()
                    vc.CancelAlert(view: self, title: "Error", message: "Plaese, Enter A Correct Number !!!")
                }
            }
            
        }))
        alert.addAction(UIAlertAction(title: "cancel", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - UITableView DataSurces
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (All_Drugs.DrugSold == nil){
            return 0
        }else{
            return All_Drugs.DrugSold.count
        }
    }

    //MARK: - UITableView delegate

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "The cost is : \(String(All_Drugs.DrugSold[indexPath.row].money))"
        cell.detailTextLabel?.text = All_Drugs.DrugSold[indexPath.row].data
        return cell
    }
    
    
    // To sort the salles in each drug by data and time
    func SortTheSallesByData(){
        if drug != nil {
            // ["Apr", "12,", "2019", "at", "3:32:09", "AM"]

            var Am_Pm = GetTheCurrentTime()// get the current Time
            Am_Pm = Am_Pm.components(separatedBy: " ")[5] // To get the The < am or pm >
            
            All_Drugs.DrugSold = drug.sales?.allObjects as! [Sold_drug] // to get the salles for the drug
          
            All_Drugs.DrugSold.sort(by: { (d1, d2) -> Bool in
                if let date1 = d1.data , let date2 = d2.data {
                    // Apr 12, 2019 at 3:32:09 AM

                    // get a array from the time
                    var dataArray1 = date1.components(separatedBy: " ")
                    var dataArray2 = date2.components(separatedBy: " ")
                    
                    // check the DAY because sometimes the day can be one digit or Two
                    // this symbol ,  So, I must plus 1 on the counter That's why I compare by 2 not 1
                    // ex: "1," or "9," and also can be "14,"
                    // And I Will compare them So, they must has a same number of digits
                    
                    dataArray1[1] = dataArray1[1].count == 2 ? "0" + dataArray1[1] : dataArray1[1]
                    dataArray2[1] = dataArray2[1].count == 2 ? "0" + dataArray2[1] : dataArray2[1]
                    
                    // check the time because sometimes the time can be 7 digit or 8
                    // ex: "3:32:09" or "5:02:09," and also can be "12:32:09"
                    // And I Will compare them So, they must has a same number of digits
                    
                    dataArray1[4] = dataArray1[4].count == 7 ? "0" + dataArray1[4] : dataArray1[4]
                    dataArray2[4] = dataArray2[4].count == 7 ? "0" + dataArray2[4] : dataArray2[4]

                    // I will drop the symbol
                    // The day
                    let day1 = String(dataArray1[1].dropLast())
                    let day2 = String(dataArray2[1].dropLast())
                    // The time 3:32:09
                    let time1 = String(dataArray1[4])
                    let time2 = String(dataArray2[4])
                    // The am or pm
                    let Am_Pm_1 = String(dataArray1[5])
                    let Am_Pm_2 = String(dataArray2[5])
                    
                    // The sort will be
                    // at first by day
                    // at second by am or pm
                    // at third by time
                    
                    if (day1 != day2){
                        return day1 > day2
                        
                    }else if (Am_Pm_1 != Am_Pm_2){
                        return Am_Pm_1 > Am_Pm_2
                    }else{
                        return time1 > time2
                    }
                }else {
                    return false 
                }
            })
           
        }
    }
}
