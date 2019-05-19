//
//  Drugs_Will_Sell.swift
//  Essam Atwah
//
//  Created by abdalrahman essam on 4/11/19.
//  Copyright © 2019 MACBOOK. All rights reserved.
//

import UIKit

class Drugs_Will_Sell: UITableViewCell {

    var drug : Drug? // to pass the drug for each cell

    
    @IBOutlet weak var name: Lable_Design!
    @IBOutlet weak var amount: Lable_Design!
    @IBOutlet weak var price: Lable_Design!
    
    @IBOutlet weak var stepper: UIStepper!
    @IBAction func Plus_Minc(_ sender: UIStepper) {
        amount.text = String(Int(sender.value))// update the amount on the screen
        calcTheTotalCost()// update the price on the screen
    }
    
    @IBOutlet weak var box_strip_outlet: UISegmentedControl!
   
   
    func calcTheTotalCost(){
        if (drug != nil){
            if  let amountString = amount.text ,
                let amountInt = Int(amountString) ,
                let priceDouble = drug?.price {
                
                if (box_strip_outlet.selectedSegmentIndex == 0){
                    // if the user will sell by BOXS
                    price.text = String(describing: (priceDouble * Double(amountInt)) )
                }else{
                    // if the user will sell by Strips
                    if let itemInBox = drug?.iteminbox {
                        price.text = String( (priceDouble / Double(itemInBox)) * Double(amountInt))
                    }
                }
            }
        }
    }
    

    @IBAction func box_strip_action(_ sender: UISegmentedControl) {
        calcTheTotalCost()// update the price on the screen
    }

}
