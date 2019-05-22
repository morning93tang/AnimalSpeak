//
//  AnimalViewController.swift
//  imagepicker
//
//  Created by 唐茂宁 on 2/4/19.
//  Copyright © 2019 Sara Robinson. All rights reserved.
//

import UIKit

class AnimalViewController: UIViewController {
    
    var derailResult = DetailResult()
    //@IBOutlet weak var photoImageView: UIImageView!
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var photoImageView: UIImageView!
    //@IBOutlet weak var nameLabel: UILabel!
    //@IBOutlet weak var iconImageView: UIImageView!
    //@IBOutlet weak var descriptionTextView: UITextView!
    //@IBOutlet weak var mapView: MKMapView!
    ///Animal will be set when a animal marker is selected in the map.
    //var currentAnimal: Animal?
    @IBOutlet weak var scrollView: UIScrollView!
    
    

    override func viewDidLoad() {
        

        self.view.layoutIfNeeded()
        self.photoImageView.contentMode = .scaleAspectFill
        self.photoImageView.clipsToBounds = true
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.layer.borderWidth = 1
        iconImageView.layer.cornerRadius = 5
        iconImageView.layer.backgroundColor = UIColor.white.cgColor
        iconImageView.layer.borderColor = UIColor.gray.cgColor
        iconImageView.layer.shadowColor = UIColor.black.cgColor
        iconImageView.clipsToBounds = true
        descriptionTextView.layer.cornerRadius = 5
        descriptionTextView.layer.borderColor = UIColor.gray.cgColor
        descriptionTextView.layer.borderWidth = 0.5
        descriptionTextView.clipsToBounds = true
        if UIApplication.shared.statusBarOrientation.isLandscape {
            let height = UIScreen.main.bounds.size.height
            self.scrollView.setContentOffset(CGPoint(x: 0, y: height), animated: true)
        }
        self.nameLabel.text = "derailResult.displayTitle"
        self.descriptionTextView.text = "derailResult.distribution"
        super.viewDidLoad()
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if size.width > 479 {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: size.height), animated: true)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
