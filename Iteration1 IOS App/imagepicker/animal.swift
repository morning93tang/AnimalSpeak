//
//  animal.swift
//  imagepicker
//
//  Created by 唐茂宁 on 8/4/19.
//  Copyright © 2019 Sara Robinson. All rights reserved.
//

import UIKit

class animal: NSObject {
    let name: String
    //let image: UIImage?
    let element: Element
    
    enum Element: String {
        case Mammal
        case Birds
        case Reptile
        case All
    }
    
    init(name: String, element: Element) {
        self.name = name
        //self.image = UIImage(named: name)
        self.element = element
        super.init()
    }
}
