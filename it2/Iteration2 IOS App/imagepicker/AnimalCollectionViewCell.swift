//
//  AnimalCollectionViewCell.swift
//  imagepicker
//
//  Created by 唐茂宁 on 4/4/19.
//  Copyright © 2019 Sara Robinson. All rights reserved.
//
//  Reuseable cllection view cell of animal icons on the top of the map.

import UIKit
import Alamofire
import AlamofireImage
class AnimalCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var number: UILabel!
    
    @IBOutlet weak var animalIconImageView: UIImageView!
    
    let imageCache = AutoPurgingImageCache()
    
    
    /// Initialize the cell
    override func layoutSubviews() {
        super.layoutSubviews()
        self.animalIconImageView.layoutIfNeeded()
        self.animalIconImageView.backgroundColor = UIColor.black
        self.animalIconImageView.layer.borderWidth = 1
        self.animalIconImageView.layer.masksToBounds = false
        self.animalIconImageView.layer.borderColor = UIColor.black.cgColor
        self.animalIconImageView.layer.cornerRadius = self.animalIconImageView.frame.size.width/2
        self.animalIconImageView.clipsToBounds = true
    }
    
    /// Inform the collection view the cell is selected or not.
    override var isSelected: Bool{
        didSet{
            if self.isSelected
            {
                UIView.animate(withDuration: 0.2) {
                   self.animalIconImageView.layer.opacity = 0.4
                }
            }
            else
            {
                self.animalIconImageView.layer.opacity = 1
            }
        }
    }
    
}
