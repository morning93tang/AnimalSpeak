//
//  AutoCompletViewController.swift
//  imagepicker
//
//  Created by 唐茂宁 on 11/5/19.
//  Copyright © 2019 Sara Robinson. All rights reserved.
//


import UIKit

protocol searchLoctionDelegated {
    func getLoaction(coordinate:CLLocationCoordinate2D) }
class AutoCompleteVC: UIViewController {
    
//    @IBOutlet var lblName:UILabel!
//    @IBOutlet var lblAddress:UILabel!
//    @IBOutlet var lblLatitude:UILabel!
//    @IBOutlet var lblLongitude:UILabel!
//    @IBOutlet var indicatorView:UIActivityIndicatorView!
//    
//    @IBOutlet var viewContainer:UIView!
//    var delegate : searchLoctionDelegated?
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        self.getAutocompletePicker()
//        
//    }
////    func getAutocompletePicker() {
////        let autocompleteController = GMSAutocompleteViewController()
////        autocompleteController.delegate = self
////        present(autocompleteController, animated: true, completion: nil)
////    }
//    @IBAction func refresh(sender: UIButton)
//    {
//        self.viewContainer.isHidden = true
//        self.getAutocompletePicker()
//    }
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//    }
    
}
//extension AutoCompleteVC: GMSAutocompleteViewControllerDelegate {
//
//    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
//        if delegate != nil {
//            delegate?.getLoaction(coordinate: place.coordinate)
//            dismiss(animated: true, completion: nil)
//        }
//        self.viewContainer.isHidden = false
//        self.indicatorView.isHidden = true
//        self.lblName.text = place.name
//        self.lblAddress.text = place.formattedAddress?.components(separatedBy: ", ")
//            .joined(separator: "\n")
//        self.lblLatitude.text = String(place.coordinate.latitude)
//        self.lblLongitude.text = String(place.coordinate.longitude)
//        dismiss(animated: true, completion: nil)
//    }
//
//    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
//        self.viewContainer.isHidden = true
//
//        print("Error: ", error.localizedDescription)
//    }
//
//    // User canceled the operation.
//    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
//        dismiss(animated: true, completion: nil)
//        self.viewContainer.isHidden = true
//        self.indicatorView.isHidden = true
//    }
//
//    // Turn the network activity indicator on and off again.
//    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//    }
//
//    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = false
//    }
//
//}
//
