//
//  TextField_Design.swift
//  Essam Atwah
//
//  Created by MACBOOK on 8/26/17.
//  Copyright © 2017 MACBOOK. All rights reserved.
//

import UIKit

@IBDesignable
class TextField_Design: UITextField {
    
       @IBInspectable var cornerRadius: CGFloat = 0 {
            didSet {
                self.layer.cornerRadius = cornerRadius
            }
        }
        
        @IBInspectable var borderWidth: CGFloat = 0 {
            didSet {
                self.layer.borderWidth = borderWidth
            }
        }
        @IBInspectable var borderColor: UIColor = UIColor.clear {
            didSet {
                self.layer.borderColor = borderColor.cgColor
            }
        }
}
