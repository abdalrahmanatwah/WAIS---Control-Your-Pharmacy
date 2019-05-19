//
//  Lable_Design.swift
//  Essam Atwah
//
//  Created by abdalrahman essam  on 1/21/18.
//  Copyright © 2018 MACBOOK. All rights reserved.
//

import UIKit

@IBDesignable
class Lable_Design: UILabel {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
}
