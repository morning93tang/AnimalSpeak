//
//  AnimalCollectionViewCell.swift
//  imagepicker
//
//  Created by 唐茂宁 on 4/4/19.
//  Copyright © 2019 Sara Robinson. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
class AnimalCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var number: UILabel!

    @IBOutlet weak var animalIconImageView: UIImageView!
    
    let imageCache = AutoPurgingImageCache()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.animalIconImageView.layoutIfNeeded()
        self.animalIconImageView.layer.borderWidth = 1
        self.animalIconImageView.layer.masksToBounds = false
        self.animalIconImageView.layer.borderColor = UIColor.black.cgColor
        self.animalIconImageView.layer.cornerRadius = self.animalIconImageView.frame.size.width/2
        self.animalIconImageView.clipsToBounds = true
        self.contentView.contentMode = .scaleAspectFill
        
    }
    
    override var isSelected: Bool{
        didSet{
            if self.isSelected
            {
                self.animalIconImageView.layer.opacity = 0.5
            }
            else
            {
                 self.animalIconImageView.layer.opacity = 1
            }
        }
    }
    
}
