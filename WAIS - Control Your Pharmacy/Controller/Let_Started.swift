import UIKit
import Firebase

class Let_Started: UIViewController {
    
    //MARK: - IBOutlet and variable 

    @IBOutlet weak var letStarted: Button_Design!
    
    var timer = Timer()

    static var current_User = user() // the current user Info
    static var DrugsComplete = [DrugsFb]() // the Drugs Complete
    var counter : Int = 3 // timer for load the data from firebasae

    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        getTheDrugs()
        
        // get the user index for old users
        if let UID = Auth.auth().currentUser?.uid {
            let info = getTheUserInfo(uid: UID)
            Code_Password.UserIndex = info.index
        }
        // set the user for old users
        if (Code_Password.UserIndex != -1){
            let USER = LoginVC.Users[Code_Password.UserIndex]
            Let_Started.current_User = user(name: USER.name, number: USER.number_phone, password: USER.password , uid : USER.uid, saveOnline : USER.saveOnline , DeleteMonthly : USER.DeleteMonthly)
        }
        
        letStarted.setTitle("It will start after \(counter)...", for: .normal)
        letStarted.isEnabled = false // Close the button untill the timer finish
        timer = Timer.scheduledTimer(timeInterval: 1 , target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        UIApplication.shared.statusBarStyle = .default// status bar black
    }
    
    //MARK: - timerAction

    @objc func timerAction() {
        if(counter > 0){
            letStarted.setTitle("It will start after \(counter)...", for: .normal)
            counter-=1
        }else if(counter == 0){
            counter-=1
            letStarted.setTitle("Let's Start", for: .normal)
            letStarted.isEnabled = true // make the button open after the timer finish
        }
    }
    
    //MARK: - go button action
    @IBAction func go(_ sender: UIButton){
        let story = UIStoryboard(name: "Main", bundle: nil)
        let vc = story.instantiateViewController(withIdentifier: "TabBar") as! UITabBarController
        let d = UIApplication.shared.delegate as! AppDelegate
        d.window?.rootViewController = vc // make the tab bar root View Controller
    }
   
    //MARK: - getTheUserInfo
    // check if this user new or old actully I can set the user old or new from code_passord view but to get the his index if he is old user
    func getTheUserInfo(uid : String) -> (New_Old : Bool,index : Int) {
        if (!LoginVC.Users.isEmpty){
            for i in 0...LoginVC.Users.count-1 {
                if(LoginVC.Users[i].uid == uid){
                    return (false,i)
                }
            }
        }
        return (true,-1)
    }
    
    //MARK: - getTheDrugs
    // Get The complete drugs from firebase database
    func getTheDrugs(){
        let ref = Database.database().reference().child("Drugs")
        ref.observe(.childAdded, with: { (snapshot) in
            if let name = snapshot.key as? String {
                if let TheDrug = snapshot.value as? [String : AnyObject] {
                    
                    let price = TheDrug["price"] as! Double
                    let itemINBox = TheDrug["items in box"] as! Int32
                    
                    let drug = DrugsFb()
                    
                    drug.name = name
                    drug.bar_code = TheDrug["bar code"] as? String
                    drug.price = price
                    drug.item_in_box = itemINBox
                    
                    Let_Started.DrugsComplete.append(drug)
                }
            }
            
        }) { (error) in
            print("ERROR LET'S_Started : \(error.localizedDescription)")
        }
    }
    
    
}

