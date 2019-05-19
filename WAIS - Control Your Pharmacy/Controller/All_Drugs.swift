//
//  All_Drugs.swift
//  Essam Atwah
//
//  Created by MACBOOK on 7/25/17.
//  Copyright © 2017 MACBOOK. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class All_Drugs: UITableViewController , UISearchResultsUpdating {

    //MARK: - IBOutlet and variable
    var RefreshControl : UIRefreshControl!
    var search : UISearchController!
    var re = UITableViewController()
    
    
    public static var Dru = [Drug]() // The main Array fr all drugs
    public static var DrugSold = [Sold_drug]() // The main Array for salles for each drug
    private var NameSearchBar = [Drug]()// The Array for the Drugs which searching for
    
    
    //MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        view.endEditing(true)
        ad.fetchDataFromCOD() // upload all drugs from CoreData
        sortDrugs()// Sort the Drugs by count of salles
        tableView.reloadData()
        LoginVC.Users.removeAll()// remove all users we don't need them now
    }
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        //init searching tableView
        re.tableView.delegate = self
        re.tableView.dataSource = self
        re.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell2")
        // hide the status when the user scroll down
        self.navigationController?.hidesBarsOnSwipe = true
        // perpare the search screen
        search = UISearchController(searchResultsController: self.re)
        tableView.tableHeaderView = search.searchBar
        search.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        search.searchResultsUpdater = self
        // RefreshControl
        RefreshControl = UIRefreshControl()
        RefreshControl.addTarget(self, action: #selector(self.Refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(RefreshControl)
        // calendar Day Did Change
        NotificationCenter.default.addObserver(self, selector:#selector(calendarDayDidChange), name:.NSCalendarDayChanged, object:nil)
    }
    
    // When the day change
    @objc func calendarDayDidChange(){
        // upload the drugs which the user added and the internet wasn't work
        for drug in All_Drugs.Dru {
            // check if the drug in firebase database or in Core data database
            let TheDrugInFirebase = Let_Started.DrugsComplete.contains(where: { (DrugComplete) -> Bool in
                return ((drug.name == DrugComplete.name) && (drug.bar_code == DrugComplete.bar_code))
            })
            // upload the drug to database firebase
            if (!TheDrugInFirebase && Reachability.isConnectedToNetwork()){
                uploadTheNewDrugsToFirebase(drug: drug)
            }
        }
    }
    
    //MARK: - Refresh
    @objc func Refresh(){
        ad.fetchDataFromCOD()
        tableView.reloadData()
        sortDrugs()
        RefreshControl.endRefreshing()
    }
    
    //MARK: - UITableView DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  (tableView == self.tableView){
            return All_Drugs.Dru.count
        }else{
            return self.NameSearchBar.count
        }
    }
    
    //MARK: - UITableView delegate
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (tableView == self.tableView){
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            // sometimes there is some items with 0 Price and empty name
            if (All_Drugs.Dru[indexPath.row].name != "" && All_Drugs.Dru[indexPath.row].price != 0)
            {
                cell.textLabel?.text = All_Drugs.Dru[indexPath.row].name // The drug name
                cell.detailTextLabel?.text = "Price : \(String(All_Drugs.Dru[indexPath.row].price))" // The drug price
            }else{
                Context.delete(All_Drugs.Dru[indexPath.row])
                All_Drugs.Dru.remove(at: indexPath.row)
                tableView.reloadData()
            }
            return cell
        }else{
            // another cell to search bar and make it like the orgnail one with fonts and colors
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell2")
            
            cell.textLabel?.text = self.NameSearchBar[indexPath.row].name
            cell.textLabel?.textColor = UIColor(red: 0, green: 93/255, blue: 158/255, alpha: 1)
            cell.textLabel?.font = UIFont(name: "Acme-Regular", size: 20)
            
            
            cell.detailTextLabel?.text = "Price : \(String(NameSearchBar[indexPath.row].price))"
            cell.detailTextLabel?.textColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
            cell.detailTextLabel?.font = UIFont(name: "System", size: 12.0)
            return cell
        }
    }
    
    //MARK: - UITableView editing
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Context.delete(All_Drugs.Dru[indexPath.row])
            All_Drugs.Dru.remove(at: indexPath.row)
            ad.saveContext()
            tableView.reloadData()
        }
    }
    
    //MARK: - segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "each_drug" {
            let VC = segue.destination as! each_Drug
            VC.drug = sender as? Drug // pass the drug to Each_Drug
        }
    }
    
    //MARK: - UITableView did select
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.reloadData()
        let drug = All_Drugs.Dru[indexPath.row] // pass the drug to Each_Drug
        performSegue(withIdentifier: "each_drug", sender: drug)
        let vc  = self.storyboard?.instantiateViewController(withIdentifier: "each_Drug") as! each_Drug
        present(vc, animated: true, completion: nil)
    }
    
    //MARK: - UITableView cell hight
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    //MARK: - update Search Results
    func updateSearchResults(for searchController: UISearchController) {
        // if I can take the text on Search bar
        if let TheTextInSearchBar = self.search.searchBar.text?.capitalized.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) {
            
            self.NameSearchBar.removeAll()// be sure the array don't have value from pervious search
            // Searching for the drugs
            for O in All_Drugs.Dru {
                if let a = O.name?.contains(TheTextInSearchBar){
                    if(a){self.NameSearchBar.append(O)}
                }
            }
            self.re.tableView.reloadData()
        }
        self.re.tableView.reloadData()
    }
    
   
    //MARK: - sorting Drugs by salles count
    func sortDrugs(){
        All_Drugs.Dru.sort{ (d1,d2) -> Bool in
            if let CountOfSalles1 : Int = d1.sales?.count  , let CountOfSalles2 : Int = d2.sales?.count  {
                return (CountOfSalles1) > (CountOfSalles2)
            }
            return true
        }
    }
    
    //MARK: - upload the drugs to firebase database
    func uploadTheNewDrugsToFirebase(drug : Drug){
        let ref = Database.database().reference()
        guard let nameDrug : String = drug.name else {return}
        guard let priceDrug : Double = drug.price else {return}
        guard let iteminboxDrug : Int32 = drug.iteminbox else {return}
        guard let bar_codeDrug : String = drug.bar_code else {return}
        
        ref.child("Drugs").child(nameDrug).setValue(["bar code" : bar_codeDrug , "price" : priceDrug , "items in box" : iteminboxDrug ]) { (error, d) in
            if(error != nil){
                print("ERROR NAME ENTER DATA : \(String(describing: error?.localizedDescription))")
                error_handle(view: self, error: error!)
            }
        }
    }
}
