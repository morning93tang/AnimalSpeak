//
//  AnimalDetailViewController.swift
//  imagepicker
//
//  Created by 唐茂宁 on 2/4/19.
//  Copyright © 2019 Sara Robinson. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class AnimalDetailViewController: UIViewController, ResultDetailDelegate {
    var derailResult = DetailResult()
    //@IBOutlet weak var photoImageView: UIImageView!
    //@IBOutlet weak var nameLabel: UILabel!
    //@IBOutlet weak var iconImageView: UIImageView!
    //@IBOutlet weak var descriptionTextView: UITextView!
    //@IBOutlet weak var mapView: MKMapView!
    ///Animal will be set when a animal marker is selected in the map.
    //var currentAnimal: Animal?

    


    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var phtotImageView: UIImageView!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var nameLabe: UILabel!
    
    override func viewDidLoad() {
        self.view.layoutIfNeeded()
        self.phtotImageView.contentMode = .scaleAspectFill
        self.phtotImageView.clipsToBounds = true
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.layer.borderWidth = 2
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
        
        
        super.viewDidLoad()
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if size.width > 479 {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: size.height), animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func gerResultData(detailResut: DetailResult) {
        self.derailResult = detailResut
        //DispatchQueue.main.async {
        //UIDevice.current.identifierForVendor?.uuidString
            self.nameLabe.text = self.derailResult.displayTitle
            self.descriptionTextView.text = self.derailResult.distribution
            self.iconImageView.contentMode = .scaleAspectFill
            self.iconImageView.image = self.derailResult.image!
            Alamofire.request(self.derailResult.imageURL).responseImage { response in
                debugPrint(response)
                print(response.request)
                print(response.response)
                debugPrint(response.result)
                
                if let image = response.result.value {
                    self.phtotImageView.contentMode = .scaleAspectFill
                    self.phtotImageView.image = image
                }
                
            }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ImageRecSegue"
        {
            if let destination = segue.destination as? ViewController {
                destination.delegate = self
            }
        }
    }
    
    
}
