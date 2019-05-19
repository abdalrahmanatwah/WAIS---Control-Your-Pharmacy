import UIKit
import CoreData
import AVFoundation
import Firebase

class EnterData : UIViewController , UITextFieldDelegate , UITableViewDelegate , UITableViewDataSource {
    
    //MARK: - IB Outlet

    @IBOutlet weak var typeOut: UISegmentedControl!
    @IBOutlet weak var Name: UITextField!
    @IBOutlet weak var Price: UITextField!
    @IBOutlet weak var ItemInBox: UITextField!
    @IBOutlet weak var Amount: UITextField!
    @IBOutlet weak var addOutlet: Button_Design!
    @IBOutlet weak var filteredTable: UITableView!//The TableView for names for filtered Drugs Names
    @IBOutlet weak var saveImage: UIImageView! // the image will appear when the user save any drug
    @IBOutlet weak var barCodebuttonOutlet: UIBarButtonItem!
    
    var timer = Timer()
    var player = AVAudioPlayer()
    let alert = alertOrginal()
    
    private var OrgnailViewHeight : CGFloat = 0 // The height for the Orgnail view
    private var filteredDrugsNamesArray = [String]() // an array for drugs names which filtered when the user writeing
    public static var flagCheckBarCode = false // Check the user take the bar code or not, this varible control the add button if it true the button will enable.
    public static var Bar_code = "" // When the user take the bar code the "bar code" save in it.
    public static var type = "1" // The type for the drug
    
    
    override func viewWillAppear(_ animated: Bool) {
        let read = ReadNameOFDrugs_Firebase()
        read.readData()
    }
    
    //MARK: - viewDidLoad and viewWillAppear
    override func viewDidLoad() {
        UIApplication.shared.statusBarStyle = .default
        
        Name.delegate = self // to be able to filtering
        filteredTable.isHidden = true // make it hidden because the Name textfiled empty
        OrgnailViewHeight = view.frame.origin.y // pass the height for the view to the varibale
        saveImage.isHidden = true // it only appear when the user add drug

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil) // when the keyboard open do this function
        
    }
    
    
    //MARK: - Helper Function
    @objc func appear_saveAction(){
        saveImage.isHidden = true // appear when the user add a drug
    }
    
    
    //MARK: - when the user touches the screen
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
        if(self.view.frame.origin.y < OrgnailViewHeight){
            self.view.frame.origin.y += 50 // back the Screen to Orignal size
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= 50 // Scroll the Screen up
            }
        }
    }
    
    //MARK: - play aduio
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
            player.volume = 0.3
            player.play()
        } catch {
            print("error: \(error.localizedDescription)")
        }
    }
    
    //MARK: - Go_To_Bar_Code button
    @IBAction func Go_To_Bar_Code(_ sender: Any) {
        let alert  = self.storyboard?.instantiateViewController(withIdentifier: "Enter_Bar_Code") as! Enter_Bar_Code
        let naalertontroller = UINavigationController(rootViewController: alert)
        alert.viewCon = "EnterData"
        self.present(naalertontroller, animated: true, completion: nil)
    }
    
    //MARK: - back UIBarButtonItem
    @IBAction func back(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - When the user start write in Name text filed
    @IBAction func Names(_ sender: Any) {
        if let DrugNameFromUser = Name.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) {
            if(DrugNameFromUser != ""){
                // get the Names of drugs from firebase
                filteredDrugsNamesArray = ReadNameOFDrugs_Firebase.Drugs.filter { $0.contains(DrugNameFromUser.capitalized) }
                
                self.filteredTable.isHidden = false // open the tableView
                filteredTable.reloadData()
            }else{
                // to be sure all the textfeild empty
                self.filteredTable.isHidden = true
                Price.text = ""
                ItemInBox.text = ""
                barCodebuttonOutlet.isEnabled = true
                EnterData.Bar_code = ""
                Amount.text = ""
            }
        }
    }
    //MARK: - ADD button

    @IBAction func ADD(_ sender: UIButton){
        
        if Reachability.isConnectedToNetwork() {
            addItemToDatabase()
        }else{
            error_handle(view: self, error : nil, hint: 1)
        }
        
        ad.fetchDataFromCOD()
    }
  
    
    //MARK: - seclect the type by segment control
    @IBAction func typeAction(_ sender: Any) {
        // To select the type of drug
        switch typeOut.selectedSegmentIndex {
        case 0:
            EnterData.type = "1"
        case 1:
            EnterData.type = "2"
        case 2:
            EnterData.type = "3"
        case 3:
            EnterData.type = "4"
        case 4:
            EnterData.type = "5"
        case 5:
            EnterData.type = "Other"
        default:
            EnterData.type = "1"
        }
    }
   
    
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        filteredTable.isHidden = true// when the user finished write close the TableView
    }
    
    //MARK: - When the user add a drug remove all the info and backing all the things to Orignal styel
    func emptyTheTextsField(){
        Name.text = ""
        Price.text = ""
        Amount.text = ""
        ItemInBox.text = ""
        EnterData.Bar_code = ""
        EnterData.type = "1"
        typeOut.selectedSegmentIndex = 0
        EnterData.flagCheckBarCode = false
    }
    
    
    //MARK: - Add To Core Data
    func addItemToDatabase(){
        // Take the date from user and delete any space and new line
        
        guard let nameEdited = Name.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) , nameEdited != "" else {alert.CancelAlert(view: self, title: "Invalid Value", message: "Please, Enter a correct name")
            Name.text = ""
            return
        }
        
        guard let priceEdited = Price.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) , let DoublepriceEdited = Double(priceEdited) , priceEdited != "" , priceEdited != "0" else {
            alert.CancelAlert(view: self, title: "Invalid Value", message: "Please, Enter a correct price")
            Price.text = ""
            return
        }
        
        guard let ItemInbox = ItemInBox.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) ,
              let iteminboxINT32 =  Int32(ItemInbox) , iteminboxINT32 != 0 ,  iteminboxINT32 < 50 , ItemInbox != "" , ItemInbox != "0" else {
                alert.CancelAlert(view: self, title: "Invalid Value", message: "The Item In Box Invalid")
                ItemInBox.text = ""
                return
        }
        
        guard let AmountEdited = Amount.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) ,
            let AmountFloat =  Float(AmountEdited) , AmountFloat < 1000 ,  AmountEdited != "" else {
                alert.CancelAlert(view: self, title: "Invalid Value", message: "Please, Enter a correct Amount")
                Amount.text = ""
                return
        }
        
        guard EnterData.type != "" else{
            alert.CancelAlert(view: self, title: "Invalid Value", message: "Please, Enter a correct Type")
            typeOut.selectedSegmentIndex = 0
            return
        }
        
        guard EnterData.Bar_code != "" else{
            alert.CancelAlert(view: self, title: "Invalid Value", message: "Please, Enter a correct Bar code")
            barCodebuttonOutlet.isEnabled = true
            return
        }
        
        // check if this drug added before or not
        var TheItemAlreadyIn = false
        for i in All_Drugs.Dru {
            if (i.name == nameEdited.capitalized || i.bar_code == EnterData.Bar_code){
                TheItemAlreadyIn = true
            }
        }
       
        if (!TheItemAlreadyIn){
            // if this drug is NEW
            let drug = Drug(context : Context)
            drug.name = nameEdited.capitalized
            drug.price = DoublepriceEdited
            drug.amount = AmountFloat
            drug.iteminbox = iteminboxINT32
            drug.type = EnterData.type
            drug.bar_code =  EnterData.Bar_code
            
            if (drug.amount != 0){
                drug.need_buy = false
            }else{
                drug.need_buy = true
            }
            
            // To check all the element append to core data or Not
            if(drug.name != nil && drug.price != nil && drug.iteminbox != nil && drug.amount != nil && drug.bar_code != nil && drug.need_buy != nil && drug.type != nil){

                saveInCoreData() // Save the data in CodeData
                playAudio() // Play the audio which meaning the drug append
                
                saveImage.isHidden = false // open the image which meaning the drug append
                timer = Timer.scheduledTimer(timeInterval: 2 , target: self, selector: #selector(appear_saveAction), userInfo: nil, repeats: false)// to open the image for 2 seconds
               
                if (Reachability.isConnectedToNetwork()){
                    uploadTheNewDrugsToFirebase(drug: drug) // upload the drug info to firebase
                }
                emptyTheTextsField()// empty all the objects
                
            }else {
                alert.CancelAlert(view: self, title: "Invalid Value", message: "Please, Try to save it one more time")// if it didn't save in coreData
            }
        }else{
            alert.CancelAlert(view: self, title: "Invalid Value", message: "This name or this bar code used before")// This item is alerdy added
        }
    }
    
    
    //MARK: - UI Table View

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredDrugsNamesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = filteredTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = filteredDrugsNamesArray[indexPath.row] // The names of filtered drugs
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        filteredTable.isHidden = true // hide the TableView
        Name.text = filteredDrugsNamesArray[indexPath.row] // Put the name for the seclected drug on the textfiled
        filteredDrugsNamesArray.removeAll() // be sure the array don't have value from pervious search
        
        let TheDrug = DrugsFb()
        guard let name = Name.text , name != "" else {return}
        
        // check if we have the info for the drug which the user select
        let AreWeHaveInfoThisDrug : Bool = Let_Started.DrugsComplete.contains { (item) -> Bool in
            if (item.name == name){
                // if you have it info take it to view it price and it bar code and it item in box
                TheDrug.price = item.price
                TheDrug.name = item.name
                TheDrug.bar_code = item.bar_code
                TheDrug.item_in_box = item.item_in_box
                return true
            }
            return false
        }
        
        if (AreWeHaveInfoThisDrug && TheDrug != nil){
            // if we have the drug info view it

            guard let price = TheDrug.price else {return}
            guard let itemINbox = TheDrug.item_in_box else {return}
            guard let bar = TheDrug.bar_code else {return}
            
            Price.text = String(price)
            ItemInBox.text = String(itemINbox)
            EnterData.Bar_code = bar
            // make The user can't edit it.
            Price.isEnabled = false
            ItemInBox.isEnabled = false
            barCodebuttonOutlet.isEnabled = false
        }else{
            
            Price.text = ""
            ItemInBox.text = ""
            Price.isEnabled = true
            ItemInBox.isEnabled = true
            barCodebuttonOutlet.isEnabled = true
        }
    }
    
    //MARK: - upload The New Drugs To Firebase
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
