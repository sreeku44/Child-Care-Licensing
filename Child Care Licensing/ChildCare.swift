//
//  ChildCare.swift
//  Child Care Licensing
//
//  Created by Sreekala Santhakumari on 5/19/18.
//  Copyright © 2018 Spotlight LLC. All rights reserved.
//

import Foundation

class Childcare{
    
    var name : String
  
    var coordinates : [Double]
        
    init(name: String, coordinates : Double)
    {
        
       self.name = name
        self.coordinates = [coordinates]
    }
}

