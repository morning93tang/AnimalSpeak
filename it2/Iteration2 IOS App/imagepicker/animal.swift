//
//  animal.swift
//  imagepicker
//
//  Created by 唐茂宁 on 8/4/19.
//  Copyright © 2019 Sara Robinson. All rights reserved.
//

import UIKit

/// NSObject reperesent animals in searching list
class animal: NSObject {
    let name: String
    let element: Element
    
    /// Class of an animal
    ///
    /// - Mammal: Only return mammal
    /// - Birds: Only return birds
    /// - Reptile: Only return reptile
    /// - All: present all animals
    enum Element: String {
        case Mammal
        case Birds
        case Reptile
        case All
    }
    
    /// Initializer
    ///
    /// - Parameters:
    ///   - name: (Required fild) Animal's name
    ///   - element: (required fild) Animal's class
    init(name: String, element: Element) {
        self.name = name
        self.element = element
        super.init()
    }
}
