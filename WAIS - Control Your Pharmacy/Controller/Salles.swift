//
//  Salles.swift
//  Essam Atwah
//
//  Created by abdalrahman essam on 4/12/19.
//  Copyright © 2019 MACBOOK. All rights reserved.
//

import UIKit
import Firebase
import CoreData

class Salles: UIViewController , UITableViewDelegate , UITableViewDataSource {
   
    @IBOutlet weak var tableView: UITableView!

    var RefreshControl : UIRefreshControl!

    static var SallesItems = [SallesModel]()// name , price and date
    static var SaveSalles : Bool = true // save the all the salles on firebase
    static var DeleteSallesMonthly : Bool = false // Delete Salles Monthly

    //MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        GetTheSalles()
        SortTheSallesByDate()
        tableView.reloadData()
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        RefreshControl = UIRefreshControl()
        RefreshControl.addTarget(self, action: #selector(self.Refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(RefreshControl)
        
        self.navigationController?.hidesBarsOnSwipe = true // hide the status when the user scroll down
        
        NotificationCenter.default.addObserver(self, selector:#selector(calendarDayDidChange), name:.NSCalendarDayChanged, object:nil)
        
    }
    
    //MARK: - Refresh
    @objc func Refresh(){
        tableView.reloadData()
        GetTheSalles()
        SortTheSallesByDate()
        RefreshControl.endRefreshing()
    }
  
    @objc func calendarDayDidChange(){
        if Reachability.isConnectedToNetwork() {
            // save the salles for the day online
            if (Salles.SaveSalles){
                for dr in Salles.SallesItems {
                    SaveTheSallesEveryDay(drug: dr)
                }
            }
            // delete Salles in the first day in a month
            if (Salles.DeleteSallesMonthly){
                deleteSallesMonthly()
            }
        }else{
            error_handle(view: self, error: nil, hint: 1)
        }
    }
    
    //MARK: - UITableView DataSurces
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Salles.SallesItems.count
    }
    //MARK: - UITableView delegate
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if let money = Salles.SallesItems[indexPath.row].money {
            if let date = Salles.SallesItems[indexPath.row].date {
                cell.textLabel?.text = Salles.SallesItems[indexPath.row].name
                cell.detailTextLabel?.text = "Date : \(date)  ,  Money : \(money)"
            }
        }
        
        return cell
    }
    
    //MARK: - Get The Salles from each Drug
    
    func GetTheSalles(){
        Salles.SallesItems.removeAll()// be sure the array don't have value from pervious search
        
        for drug in All_Drugs.Dru {
            let salles = drug.sales?.allObjects as! [Sold_drug]// to get the salles as array
            // append on array 'SallesItems'
            for item in salles {
                guard let Name = drug.name else {return}
                guard let DataSelling = item.data else {return}
                
                let SoldDrug = SallesModel(name : Name , data : DataSelling , money : item.money)
                Salles.SallesItems.append(SoldDrug)
            }
        }
    }
    
    //MARK: - Sort The Salles By Date
    // To sort the salles in each drug by data and time
    func SortTheSallesByDate(){
        // ["Apr", "12,", "2019", "at", "3:32:09", "AM"]
        
        var Am_Pm = GetTheCurrentTime()// get the current Time
        Am_Pm = Am_Pm.components(separatedBy: " ")[5] // To get the The < am or pm >
        
        Salles.SallesItems.sort(by: { (d1, d2) -> Bool in
            if let date1 = d1.date , let date2 = d2.date {
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
    
    func SaveTheSallesEveryDay(drug : SallesModel){
        guard let name = drug.name else {return}
        guard let money = drug.money else {return}
        guard let date = drug.date else {return}
    
        let ref = Database.database().reference().child("Users").child("Salles").child(date)
        ref.setValue(["Name" : name , "Money" :  money])
    }
    
    
    
    
    func deleteSallesMonthly(){
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        
        let date = formatter.string(from: currentDateTime)
        // check if today is the first day in the month
        // ex. 1/4/2019
        if (date.first == "1"){
            date.dropFirst()
            if(date.first == "/"){
                
                let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Sold_drug")
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
                
                do {
                    try Context.execute(deleteRequest)
                    try Context.save()
                    Salles.SallesItems.removeAll()
                    tableView.reloadData()
                } catch {
                    print ("There was an error on deleteSallesMonthly ")
                }
                
            }
        }
    }
}

