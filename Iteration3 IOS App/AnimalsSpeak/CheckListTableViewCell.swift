//
//  CheckListTableViewCell.swift
//  imagepicker
//
//  Created by 唐茂宁 on 19/4/19.
//  Copyright © 2019 Sara Robinson. All rights reserved.
//

import UIKit

/// Reusable checklist table cell.
class CheckListTableViewCell: UITableViewCell {

    @IBOutlet weak var backgroundCardView: UIView!
    @IBOutlet weak var checkListImage: UIImageView!
    @IBOutlet weak var checkListProgress: UIProgressView!
    
    @IBOutlet weak var cheklistDetail: UILabel!
    @IBOutlet weak var checkListTittleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
        checkListProgress.layer.cornerRadius = 8
        checkListProgress.clipsToBounds = true
        checkListProgress.layer.sublayers![1].cornerRadius = 8
        checkListProgress.subviews[1].clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
//            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
//                self.backgroundCardView.alpha = 0.5
//            }, completion: { finished in
//                print("select")
//            })
            self.backgroundCardView.shake()
        } else {
            self.backgroundCardView.alpha = 1
        }

        
    }
    
    
}

public extension UIView {
    
    func shake(){
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 10, y: self.center.y))
        self.layer.add(animation, forKey: "position")
    }
}
