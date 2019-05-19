//
//  Many_Selling.swift
//  Essam Atwah
//
//  Created by abdalrahman essam on 4/10/19.
//  Copyright © 2019 MACBOOK. All rights reserved.
//

import UIKit
import AVFoundation

class Many_Selling: UIViewController , UITableViewDelegate , UITableViewDataSource {

    //MARK: - IBOutlet and variable
    @IBOutlet weak var table_View: UITableView!
    @IBOutlet weak var totalPrice: Lable_Design!

    
    var RefreshControl : UIRefreshControl!
    var player = AVAudioPlayer()
    var timer = Timer()
    let Alert = alertOrginal()

    
    private var itemWillNotsell = [DrugsNeed_NotSold_Model]() // The Drugs which the user wanna sell amount is not avaiable on the pharm
    public static var DrugsWillSell = [Drug]() // The Drugs will sell insha allah hahahahah (بالصلاةُ علي النبي)

    //MARK: - viewWillAppear

    override func viewWillAppear(_ animated: Bool) {
        table_View.reloadData()
        calc_the_total_price()// update the price on the screen
    }
    //MARK: -viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        totalPrice.layer.cornerRadius = 10
        totalPrice.text = "0.0 LE"
        
        RefreshControl = UIRefreshControl()
        RefreshControl.addTarget(self, action: #selector(self.Refresh), for: UIControlEvents.valueChanged)
        table_View.addSubview(RefreshControl)
        
        timer = Timer.scheduledTimer(timeInterval: 0.1 , target: self, selector: #selector(timerAction), userInfo: nil, repeats: true) // update the price every seceond
    }
    
    
    //MARK: - timer Action
    @objc func timerAction() {
       calc_the_total_price()
    }
    //MARK: - Refresh the table view

    @objc func Refresh(){
        table_View.reloadData()
        // if there is no drugs in the array tell the User that
        if (Many_Selling.DrugsWillSell.count == 0){
            Alert.CancelAlert(view: self, title: "Not Found", message: "Add Items to Sell it by bar code")
        }
        
        table_View.reloadData()
        RefreshControl.endRefreshing()
    }
  
    
    //MARK: - play Audio
    
    @objc func playAudio() {
        guard let audioPath = getAudioFileURL() else {
            print("Audio File Not found")
            return
        }
        playSound(audioPath: audioPath)
    }
    
    @objc func getAudioFileURL() -> URL? {
        let song = "Correct Answer Sound Effect"
        return Bundle.main.url(forResource: song, withExtension: ".mp3")
    }
    
    @objc func playSound(audioPath: URL) {
        do {
            player = try AVAudioPlayer(contentsOf: audioPath)
            let audioSession = AVAudioSession.sharedInstance()
            do{
                try!audioSession.setCategory(AVAudioSessionCategoryPlayback, with: AVAudioSessionCategoryOptions.interruptSpokenAudioAndMixWithOthers) //Causes audio from other sessions to be ducked (reduced in volume) while audio from this session plays
                try!audioSession.setActive(true)
            }
            UIApplication.shared.beginReceivingRemoteControlEvents()
            player.volume = 0.4
            player.play()
        } catch {
            print("error: \(error.localizedDescription)")
        }
    }
    
    //MARK: -  Buttons
  
    @IBAction func Sell_All(_ sender: UIButton) {
        SellAll()
    }
    

    @IBAction func go_to_bar_code(_ sender: UIBarButtonItem) {
        let vc  = self.storyboard?.instantiateViewController(withIdentifier: "Enter_Bar_Code") as! Enter_Bar_Code
        let navController = UINavigationController(rootViewController: vc)
        vc.viewCon = "Many_Selling"
        self.present(navController, animated: true, completion: nil)
    }

    @IBAction func back(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    
    
    
    
    
    //MARK: - UITableView DataSurces

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (Many_Selling.DrugsWillSell == nil){ // sometimes the array didn't happen to it انشيليزيشين
            return 0
        }else{
            return Many_Selling.DrugsWillSell.count
        }
    }
    //MARK: - UITableView editing

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Many_Selling.DrugsWillSell.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    //MARK: - UITableView delegate

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table_View.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Drugs_Will_Sell
        
        let drug1 = Many_Selling.DrugsWillSell[indexPath.row]
        // to update the value on the stepper and update the price
        if let Amount = cell.amount.text {
            cell.stepper.value = Double(Amount)!
            cell.price.text = String(drug1.price * cell.stepper.value)
        }else {
            cell.amount.text = "1"
            cell.price.text = String(drug1.price)
        }
        
        cell.name.text = drug1.name
        cell.drug = drug1
        
        return cell
    }
    
    //MARK: - UITableView did select
    // To sell by select on any drug on the tableView
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Are you wanna Sell this drug?", message: "You will sell only this Drug", preferredStyle: .actionSheet)
        // The cell for this drug
        if let cell = table_View.cellForRow(at: indexPath) as? Drugs_Will_Sell {
            
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
                
                self.SellOne(index : indexPath.row  , drugCell : cell)
                Many_Selling.DrugsWillSell.remove(at: indexPath.row)
                self.table_View.reloadData()

            }))
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - UITableView cell hight
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

    
    
    
    
    
    //MARK: -  Sell One function
    
    func SellOne(index : Int , drugCell : Drugs_Will_Sell){
        guard let amountText = drugCell.amount.text else {return} // The amount will sell as string
        guard let amount = Float(amountText) else {return} // The amount will sell as float

        if (index  <= Many_Selling.DrugsWillSell.count-1 && index >= 0){ // check the index on the range or Not
            let drug = Many_Selling.DrugsWillSell[index]
            
            // the totel price in each cell
            if let cost = drugCell.price.text {
                
                let AmountOfStripsInPharm = ceil(drug.amount*Float(drug.iteminbox)) //All the amount of strips
                let b_s = drugCell.box_strip_outlet.selectedSegmentIndex // the segment index, Box = 0 , Strip = 1
                // to check the amount which the user will sell is avaiable at the pharm
                if((drug.amount < amount && b_s == 0) || (AmountOfStripsInPharm < amount && b_s == 1)){
                    // This amount isn't avaiable at the pharm
                    guard let NAme = drug.name else {return}
                    let message = "There is no Drugs with this amount.\nPleace Check the Amount again"

                    Alert.CancelAlert(view: self, title: "The \(NAme) is NOT Available", message: message)
                                       
                }else {
                    
                    // the amount is avaiable on the pharm
                    if ((drug.amount == amount && b_s == 0) || (AmountOfStripsInPharm == amount && b_s == 1)){
                        // if the amount which the user wanna sell it Equal To The amount on the pharm
                        // Put it on the Needs Table
                        drug.need_buy = true
                    }
                    
                    if(b_s == 0){
                        // If the user will sell by BOX
                        drug.amount -= amount // Delete this amount from The Orgnail Drug
                    }else{
                        // If the user will sell by Strip
                        let AmountOfStripsWillSell : Float = amount / Float(drug.iteminbox)// calc the amount by strips
                        drug.amount -= AmountOfStripsWillSell // Delete this amount from The Orgnail Drug
                        if (drug.amount < 0.00000000001){drug.amount = 0.0}//To be sure the amount will = 0
                    }
                    // Save this Selling on Coredata
                    let DrugWillBeSold = Sold_drug(context: Context)
                    DrugWillBeSold.money = Double(cost)!
                    DrugWillBeSold.data = GetTheCurrentTime()
                    drug.addToSales(DrugWillBeSold)
                    // play the audio which mean the drug is Sold
                    self.playAudio()
                    // Save on Coredata
                    saveInCoreData()
                }
            }
        }
    }
    
    // When I sell all drugs, I sell each element and check If the amount for each element allow to sell or not
    // If the amount is not allow I put The Names all the drugs didn't sell and view all on one Alert and The drug will still on the TableView.
    // If the amount is allow So Sell it and delete it from TableView.
    
    
    //MARK: -  Sell All function

    func SellAll(){
        var index1 = Many_Selling.DrugsWillSell.count-1 // The index for last element in the Array
        itemWillNotsell.removeAll() //  be sure the array don't have value from pervious search
        while(index1 >= 0){// if i didn't arrive to first element
            let indexPath = IndexPath(row: index1, section: 0)// The indexPath for a element by it index
            // The Cell for a element by it index
            if let cellZero = table_View.cellForRow(at: indexPath) as? Drugs_Will_Sell {
                
                let drug = Many_Selling.DrugsWillSell[index1]// The drug in the cell
                let AmountOfStripsInPharm = ceil(drug.amount*Float(drug.iteminbox))// All The strips in this drug
                let b_s = cellZero.box_strip_outlet.selectedSegmentIndex //  Segment Index, Box = 0, Strip = 1
                
                guard let amountText = cellZero.amount.text, amountText != "" else {return}// The amount Will sell
                guard let NAme = drug.name , NAme != "" else {return}// The name for the drug which will sell
                guard let CostText = cellZero.price.text , CostText != "" else {return}// The price for the drug which will sell
                guard let amountFloat = Float(amountText) else {return}

                
                // to check the amount which the user will sell is avaiable at the pharm
                if(((drug.amount < amountFloat && b_s == 0)  || (AmountOfStripsInPharm < amountFloat && b_s == 1))){
                    // This amount isn't avaiable at the pharm
                    // The explaintion in line number 218

                    let Item = DrugsNeed_NotSold_Model(name : drug.name! , index : index1)
                    itemWillNotsell.append(Item) // Append it name and it index to The Array 'itemWillNotsell'
                    
                }else{
                    
                    if let cost = Double(CostText){ // convert the Cost to double
                        // the amount is avaiable on the pharm
                        if ((drug.amount == amountFloat && b_s == 0) || (AmountOfStripsInPharm == amountFloat && b_s == 1)){
                            // if the amount which the user wanna sell it Equal To The amount on the pharm
                            // Put it on the Needs Table
                            drug.need_buy = true
                        }
                        
                        
                        if(b_s == 0){
                            // If the user will sell by BOX
                            drug.amount -= amountFloat // Delete this amount from The Orgnail Drug
                        }else{
                            // If the user will sell by Strip
                            let AmountOfStripsWillSell : Float = amountFloat / Float(drug.iteminbox)// calc the amount by strips
                            drug.amount -= AmountOfStripsWillSell // Delete this amount from The Orgnail Drug
                            if (drug.amount < 0.00000000001){drug.amount = 0.0}//To be sure the amount will = 0
                        }
                        
                        
                        let DrugWillBeSold = Sold_drug(context: Context)
                        DrugWillBeSold.money = cost
                        DrugWillBeSold.data = GetTheCurrentTime()
                        drug.addToSales(DrugWillBeSold)
                        saveInCoreData()
                    }
                }
            }
            
            index1 -= 1 // increment the index
        }
        
        alertForTheDrugsNotSolded()
        
        table_View.reloadData()
       
    }
    
    //MARK: - Alert For The Drugs Not Solded
    
    func alertForTheDrugsNotSolded(){
        var nameDrugsWillNotSell = [String]() // Names Drugs didnt sell
        
        var index2 : Int = 0 // ..
        while(index2 <= Many_Selling.DrugsWillSell.count-1 && !Many_Selling.DrugsWillSell.isEmpty ){
           
            //if the index is in 'itemWillNotsell' Tha't meaning this drug didn't sell
            var CheckIfTheItemSold = true
            for Se in itemWillNotsell {
                if (Se.index == index2){
                    CheckIfTheItemSold = false
                    break
                }
            }
            
            if (CheckIfTheItemSold){ // The drug Sold
                Many_Selling.DrugsWillSell.remove(at: index2)
                table_View.reloadData()
                self.playAudio()
                // we didn't incressing the index because It is deleteing from top So, When I delete element it index number 0, The element index number 1 will be index number 0. and also The drugs which will not sell, Will still on the tableView
                
            }else{// The drug didn't Sold
                nameDrugsWillNotSell.append(Many_Selling.DrugsWillSell[index2].name!)// add the name to the alert
                index2 += 1// incressing the index because this drug will still on the tableView, will not delete
            }
        }
        
        var message : String = ""// will contian the names of drugs didn't sold
        
        if (nameDrugsWillNotSell.count != 0){ // if there are drugs didn't sold
            for s in 0...nameDrugsWillNotSell.count-1 {
                message += "\(s+1) - " + nameDrugsWillNotSell[s] + "\n" // add the names to the message
            }
            let alert3 = UIAlertController(title: "The Amount For Those Drugs Is Not Available", message: message, preferredStyle: .actionSheet)
            alert3.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert3, animated: true, completion: nil)
        }
    }
    
    //MARK: - calc the total price function
    // update the price on the screen ever sec
    func calc_the_total_price(){
        
        var total = 0.0 // total cost by adding all prices for all drugs
        let Count = Many_Selling.DrugsWillSell.count // the number of drugs will sell
        
        if (Count != 0){
            // add all prices for the Drugs will sell
            for index in 0 ... Count {
                let indexPath = IndexPath(row: index, section: 0)
                if let cell = table_View.cellForRow(at: indexPath) as? Drugs_Will_Sell {
                    guard let PriceText = cell.price.text else {return}
                    if let PriceDouble = Double(PriceText){
                        total += PriceDouble
                    }
                }
            }
            
            let TotalPriceNow = totalPrice.text // total price Now
            
            let TotalPriceAfterCalc = String(total) + " LE"
            
            if (TotalPriceNow != TotalPriceAfterCalc){// Checking if the total price change or not
                totalPrice.text = TotalPriceAfterCalc // update the price on the screen
            }
            
        }else{
            // there is no drugs will sell
            totalPrice.text = "0.0 LE"
        }
    }
}
