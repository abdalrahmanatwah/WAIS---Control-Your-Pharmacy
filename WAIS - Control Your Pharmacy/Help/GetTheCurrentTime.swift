//
//  GetTheCurrentTime.swift
//  Essam Atwah
//
//  Created by abdalrahman essam on 4/12/19.
//  Copyright © 2019 MACBOOK. All rights reserved.
//

import UIKit


public func GetTheCurrentTime() -> String {
    let currentDateTime = Date()
    let formatter = DateFormatter()
    formatter.timeStyle = .medium
    formatter.dateStyle = .medium
   
    return formatter.string(from: currentDateTime)
    
}



//public func getArrayChar(S : String) -> [Character]{
//    var array : [Character]!
//    for s in 0 ... S.count {
//        guard let i = S.index(S.startIndex, offsetBy: s) else {return}
//        
//        array.append(S[i])
//    }
//    return array
//}

