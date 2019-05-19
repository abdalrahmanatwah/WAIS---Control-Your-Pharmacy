//
//  Selling.swift
//  Essam Atwah
//
//  Created by abdalrahman essam on 3/23/19.
//  Copyright © 2019 MACBOOK. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class Selling: UIViewController , UITextFieldDelegate , UITableViewDataSource , UITableViewDelegate {
   
    //MARK: - IBOutlet and variable
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var sell_Outlet: Button_Design!
    @IBOutlet weak var t_b_names: UITableView!
    @IBOutlet weak var box_strip_outlet: UISegmentedControl!
    @IBOutlet weak var numberOfAmount: UILabel!
    @IBOutlet weak var totalPrice: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    
    
    var player = AVAudioPlayer()
    let Alert = alertOrginal()
    
    
    private static var number_Items_will_sell : Float = 1.0 // The amount
    private var DrugsSearching = [Drug]()
    private var OrgnailViewHeight : CGFloat = 0
    
    var drug : Drug!{
        didSet{}// The drug which will selected
    }
    
    //MARK: - view Did Load

    override func viewDidLoad() {
        super.viewDidLoad()
        ad.fetchDataFromCOD() // load all the data from coredata
        
        name.delegate = self // to allow to knowing if the user start writing or not
        t_b_names.isHidden = true // hide the tableview before the user write anything
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }

    //MARK: - when the user touches the screen
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
        if(self.view.frame.origin.y != OrgnailViewHeight){
            self.view.frame.origin.y += 50 // back the Screen to Orignal size
        }
    }
    //MARK: - Edit Keyboard
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= 50 // Scroll the Screen up
            }
        }
    }
    //MARK: -  Name_Action

    @IBAction func Name_Action(_ sender: Any) {
        guard let TheTextInTextfeild = name.text?.capitalized.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) , TheTextInTextfeild != "" else {return}
           
        // if the user start writing, we will start searching for The drug which he wanted
        self.DrugsSearching.removeAll()// be sure the array don't have value from pervious search
        t_b_names.reloadData()
        t_b_names.isHidden = false // appear the tableVeiw becuse the user start writing
        
        for O in All_Drugs.Dru {
            if let TheNameForDrugWhichSearchingFor = O.name?.contains(TheTextInTextfeild){
                if(TheNameForDrugWhichSearchingFor){
                    self.DrugsSearching.append(O)
                    t_b_names.reloadData()
                }
            }
        }
        
    }
    
    //MARK: - Choose box or strip

    @IBAction func box_strip(_ sender: UISegmentedControl) {
        switch box_strip_outlet.selectedSegmentIndex {
        case 0:
             calcTheTotalCost() // update the price on the Screen
        case 1:
             calcTheTotalCost() 
        default:
             calcTheTotalCost()
        }
    }
    
    //MARK: - plus one or minc

    @IBAction func Add_minc(_ sender: UIStepper) {
        numberOfAmount.text = String(Int(sender.value)) // update the amount on the screen
        Selling.number_Items_will_sell = Float(sender.value)// update the amount on Our Code
        calcTheTotalCost() // update the price on the Screen
    }
    
    //MARK: - Sell Button

    @IBAction func sell_Action(_ sender: Any) {
        if (drug != nil){ // to be sure the drug selected
            
            if let cost = totalPrice.text { // if we can take the total price from screen
                
                let AmountInPharm = ceil(drug.amount*Float(drug.iteminbox)) // The number of Strips from this drug
                let b_s = box_strip_outlet.selectedSegmentIndex // The user will it Boxs or strips
                let n =  Selling.number_Items_will_sell // The Number of box_strip which the user will Sell it
                
                // to check the amount which the user will sell is avaiable at the pharm
                if ((drug.amount < n && b_s == 0) || (AmountInPharm < n && b_s == 1)){
                    // This amount isn't avaiable at the pharm
                    guard let NAme = drug.name else {return}
                    Alert.CancelAlert(view: self, title: "The \(NAme) is NOT Available", message: "There is no Drugs with this amount.\nPleace Check the Amount again")
                    
                }else {
                    // the amount is avaiable on the pharm
                    if ((drug.amount == n && b_s == 0) || (AmountInPharm == n && b_s == 1)){
                        // if the amount which the user wanna sell it Equal To The amount on the pharm
                        // Put it on the Needs Table
                        self.drug.need_buy = true
                    }
                    
                    if(b_s == 0){
                        // If the user will sell by BOX
                        self.drug.amount -= n // Delete this amount from The Orgnail Drug
                    }else{
                        // If the user will sell by Strip
                        let AmountOfStrips : Float = n / Float(self.drug.iteminbox) // calc the amount by strips
                        self.drug.amount -= AmountOfStrips // Delete this amount from The Orgnail Drug
                        if(self.drug.amount < 0.000000001 ){self.drug.amount = 0.0}//To be sure the amount will = 0
                    }
                    // Save this Selling on Coredata
                    let DrugWillBeSold = Sold_drug(context: Context)
                    DrugWillBeSold.money = Double(cost)!
                    DrugWillBeSold.data = GetTheCurrentTime()
                    self.drug.addToSales(DrugWillBeSold)
                    // play the audio which mean the drug is Sold
                    self.playAudio()
                
                    self.emptyTheTextsField() // Return all the screen to the default
                    saveInCoreData() // Save on Coredata
                }
            }
        }
    }
    
    //MARK: - back button
    @IBAction func back(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    
    
    
    //MARK: - UITableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DrugsSearching.count
    }
    //MARK: - UITableView delegate
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = t_b_names.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = DrugsSearching[indexPath.row].name
        return cell
    }
    //MARK: - UITableView did select
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        t_b_names.isHidden = true // close the TableView
        drug = DrugsSearching[indexPath.row]// Select the Drug and pass the Drug
        name.text = drug.name// Update the Name on the Screen
        
        calcTheTotalCost()// Update the Price on the Screen
        DrugsSearching.removeAll() // be sure the array don't have value with next search
        
        // if the user select the drug by name and he wanna see it in the Many_Selling
        //        if (!Many_Selling.DrugsWillSell.contains(drug)){
        //            Many_Selling.DrugsWillSell.append(drug)
        //        }
    }
    
    
    
    //MARK: - Calclate The Total Cost

    func calcTheTotalCost(){
        if (drug != nil){
            if (box_strip_outlet.selectedSegmentIndex == 0){
                // if the user will sell by boxs
                totalPrice.text = String(describing: Float(drug.price) * Selling.number_Items_will_sell) // update the Price on The Screen
            }else{
                // if the user will sell by strips
                let itemInBox = Float(drug.iteminbox)
                totalPrice.text = String((Float(drug.price) / itemInBox) * Selling.number_Items_will_sell) // update the Price on The Screen
            }
        }
    }
   
    //MARK: - Rutern All The Screen To the default

    func emptyTheTextsField(){
        name.text = ""
        totalPrice.text = "0.0"
        numberOfAmount.text = "1"
        drug = nil
        EnterData.Bar_code = ""
        Selling.number_Items_will_sell = 1.0
        self.stepper.value = 1.0
    }
    //MARK: - Text Feild Editing
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        t_b_names.isHidden = true// hide the tableview when textField Did End Editing
    }
    
    //MARK: - Play the audio
    
    func playAudio() {
        guard let audioPath = getAudioFileURL(NameTheSong : "Correct Answer Sound Effect") else {
            print("Audio File Not found")
            return
        }
        playSound(audioPath: audioPath)
    }
    
    func getAudioFileURL(NameTheSong : String) -> URL? {
        return Bundle.main.url(forResource: NameTheSong, withExtension: ".mp3")
    }
    
    func playSound(audioPath: URL) {
        do {
            player = try AVAudioPlayer(contentsOf: audioPath)
            let audioSession = AVAudioSession.sharedInstance()
            do{
                try!audioSession.setCategory(AVAudioSessionCategoryPlayback, with: AVAudioSessionCategoryOptions.interruptSpokenAudioAndMixWithOthers) //Causes audio from other sessions to be ducked (reduced in volume) while audio from this session plays
                try!audioSession.setActive(true)

            }
            UIApplication.shared.beginReceivingRemoteControlEvents()

            player.play()
        } catch {
            print("error: \(error.localizedDescription)")
        }
    }
}









//MARK: - View Will Appear
// if u will allow to user to take the drug by bar code from nameing search
//
//    override func viewWillAppear(_ animated: Bool) {
//
//
//        var NotFoundTheDrug = true
//        if (Selling.bar_Code != ""){
//            for Each_Drug in All_Drugs.Dru {
//                if (Selling.bar_Code == Each_Drug.bar_code){
//                    NotFoundTheDrug = false
//                    drug = Each_Drug
//                    if let nameOfDrug = Each_Drug.name {
//                        name.text = nameOfDrug
//                        totalPrice.text = String(Each_Drug.price)
//                    }
//                    break
//                }
//            }
//            if (NotFoundTheDrug){
//                Alert.CancelAlert(view: self, title: "Not Found", message: "Please add this drug from Enter Drugs View or try searching by name")
//            }
//        }
//    }

//MARK: - bar_code_button

//    @IBAction func bar_code_action(_ sender: UIBarButtonItem) {
//        let ve  = self.storyboard?.instantiateViewController(withIdentifier: "Enter_Bar_Code") as! Enter_Bar_Code
//        ve.viewCon = "Selling"
//        self.present(ve, animated: true, completion: nil)
//    }

