//
//  Button_Design.swift
//  Lklas
//
//  Created by abdalrahman essam on 11/17/18.
//  Copyright © 2018 abdalrahman essam. All rights reserved.
//

import UIKit
@IBDesignable
class Button_Design: UIButton {

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
