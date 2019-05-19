//
//  ReadNameOFDrugs_Firebase.swift
//  Essam Atwah
//
//  Created by abdalrahman essam on 3/10/19.
//  Copyright © 2019 MACBOOK. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CoreData
//9859
class ReadNameOFDrugs_Firebase : NSObject {
    public static var Drugs = [String]() // names of drugs from firebase database
    
    func readData(){
        if (ReadNameOFDrugs_Firebase.Drugs.count != 9859){
            let ref = Database.database().reference()
            ref.child("mid").observe(.childAdded, with: { (snapshot) in
                //print(snapshot)
                if let NameDrug = snapshot.value as? String {
                    ReadNameOFDrugs_Firebase.Drugs.append(NameDrug.capitalized)
                }
            }) { (error) in
                print("Error Ya Wla")
                print(error.localizedDescription)
            }
            ReadNameOFDrugs_Firebase.Drugs.sort()
            print("ALLAH ALKBER")
        }
    }
}
