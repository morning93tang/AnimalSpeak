//
//  CheclistItemsTableViewCell.swift
//  imagepicker
//
//  Created by 唐茂宁 on 23/4/19.
//  Copyright © 2019 Sara Robinson. All rights reserved.
//

import UIKit

class CheclistItemsTableViewCell: UITableViewCell {

    @IBOutlet weak var tickboxImageView: UIImageView!
    @IBOutlet weak var tittleLabel: UILabel!
    @IBOutlet weak var checkListImage: UIImageView!
    @IBOutlet weak var backgroundCardView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
//         Initialization code
        self.backgroundCardView.backgroundColor = UIColor(red: 212/255.0, green: 213/255.0, blue: 212/255.0, alpha: 1.0)
        self.contentView.backgroundColor = UIColor(red: 49/255.0, green: 156/255.0, blue: 138/255.0, alpha: 1.0)
        self.backgroundCardView.layer.cornerRadius = 5.0
        self.backgroundCardView.layer.masksToBounds = false
        self.backgroundCardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.6).cgColor
        self.backgroundCardView.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.backgroundCardView.layer.shadowOpacity = 0.8
        self.checkListImage.layer.cornerRadius = 5.0
        self.checkListImage.contentMode = .scaleAspectFill
        self.checkListImage.clipsToBounds = true
        
        //self.checkListProgress.transform = checkListProgress.transform.scaledBy(x: 1, y: 8)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            self.backgroundCardView.shake()
        } else {
            self.backgroundCardView.alpha = 1
        }
    }

}
