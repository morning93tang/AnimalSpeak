//
//  AnimalDetailViewController.swift
//  imagepicker
//
//  Created by 唐茂宁 on 2/4/19.
//  Copyright © 2019 Sara Robinson. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation
import GooglePlaces
import GoogleMaps
import SwiftyJSON
import CoreData


/// Class for displaying animal's detail imfomation
class AnimalDetailViewController: UIViewController, ResultDetailDelegate,GMSMapViewDelegate {
    private var managedObjectContext: NSManagedObjectContext
    var positionScroll:CGFloat = 0
    var audioPlayer:AVAudioPlayer!
    var derailResult = DetailResult()
    var locationManager = CLLocationManager()
    var frame = CGRect(x:0,y:0,width:0,height:0)
    var heatmapLayer: GMUHeatmapTileLayer!
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 5.0
    private var gradientColors = [UIColor.blue, UIColor.red]
    private var gradientStartPoints = [0.2, 1.0] as [NSNumber]
    
    @IBOutlet weak var similarityIndexLabel: UILabel!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var emptyView: UIView!
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var playIcon: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var phtotImageView: UIImageView!
    
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var nameLabe: UILabel!
    var player: AVPlayer?
    
    @IBAction func playSoundInstance(_ sender: Any) {
        self.audioPlayer.play()
    }
    
    required init?(coder aDecoder: NSCoder) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = (appDelegate?.persistentContainer.viewContext)!
        super.init(coder: aDecoder)!
    }
    
    /// Initializ the view
    override func viewDidLoad() {
        self.confirmButton.layer.cornerRadius = 8
        self.playButton.isHidden = true
        self.playIcon.isHidden = true
        self.playButton.layer.cornerRadius = 5
        self.playButton.clipsToBounds = true
        self.similarityIndexLabel.layer.cornerRadius = 5
        self.similarityIndexLabel.clipsToBounds = true
        //self.similarityIndexLabel.isHidden = true
//        scrollView.delegate = self
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        placesClient = GMSPlacesClient.shared()
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        mapView = GMSMapView.map(withFrame: emptyView.bounds, camera: camera)
        mapView.delegate = self
        mapView.settings.myLocationButton = true
        mapView.settings.zoomGestures = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        heatmapLayer = GMUHeatmapTileLayer()
        heatmapLayer.map = mapView
        heatmapLayer.radius = 40
        heatmapLayer.opacity = 0.6
        heatmapLayer.gradient = GMUGradient(colors: gradientColors,startPoints: gradientStartPoints,colorMapSize: 256)
        emptyView.addSubview(mapView)
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
        self.activityIndicator.isHidden = true
        self.phtotImageView.alpha = 1
        self.activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        self.activityIndicator.color = UIColor.black
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        self.phtotImageView.alpha = 0.5
        self.phtotImageView.image = nil
        self.nameLabe.text = self.derailResult.displayTitle
        self.descriptionTextView.text = self.derailResult.distribution
        self.iconImageView.contentMode = .scaleAspectFill
        self.iconImageView.image = self.derailResult.image
        self.similarityIndexLabel.text = "Similarity: \(self.derailResult.matchingIndex)%"
        Alamofire.request(self.derailResult.imageURL).responseImage { response in
            if let image = response.result.value {
                self.phtotImageView.contentMode = .scaleAspectFill
                self.phtotImageView.image = image
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.phtotImageView.alpha = 1
            }
        }
        self.loadSound(animalName: derailResult.displayTitle)
        heatmapLayer.map = nil
        let name = self.derailResult.displayTitle
        let worker = ROGoogleTranslate()
        worker.sendRequestToServer(methodId: 2,request: ["animals":[name]]){ (result) in
            DispatchQueue.global().async {
                if result != nil{
                    self.updateMap(result: result!)
                }
            }
        }
//        self.pageControl.isHidden = true
        super.viewDidLoad()
    }
    
    
    /// Adjust the view according to the screen size
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        if size.width > 479 {
//            self.scrollView.setContentOffset(CGPoint(x: 0, y: size.height), animated: true)
//        }
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// Get detailResult form segue.
    func gerResultData(detailResut: [DetailResult]) {
//        self.activityIndicator.isHidden = false
//        self.activityIndicator.startAnimating()
//        self.phtotImageView.alpha = 0.5
//        self.phtotImageView.image = nil
//        self.derailResult = detailResut
//        self.pageControl.layer.cornerRadius = 8.0
//        self.pageControl.numberOfPages = detailResut.count
//        //        self.pageControl.frame.width = self.pageControl.frame.width + CGFloat(4.0)
//        self.pageControl.isHidden = false
//        //DispatchQueue.main.async {
//        //UIDevice.current.identifierForVendor?.uuidString
//        self.nameLabe.text = self.derailResult[0].displayTitle
//        self.descriptionTextView.text = self.derailResult[0].distribution
//        self.iconImageView.contentMode = .scaleAspectFill
//        self.iconImageView.image = self.derailResult[0].image!
//        Alamofire.request(self.derailResult[0].imageURL).responseImage { response in
//            if let image = response.result.value {
//                self.phtotImageView.contentMode = .scaleAspectFill
//                self.phtotImageView.image = image
//                self.activityIndicator.stopAnimating()
//                self.activityIndicator.isHidden = true
//                self.phtotImageView.alpha = 1
//            }
//        }
//        self.loadSound(animalName: derailResult[0].displayTitle)
//        heatmapLayer.map = nil
//        let name = self.derailResult[0].displayTitle
//        let worker = ROGoogleTranslate()
//        worker.sendRequestToServer(methodId: 2,request: ["animals":[name]]){ (result) in
//            DispatchQueue.global().async {
//                if result != nil{
//                    self.updateMap(result: result!)
//                }
//            }
//        }
        
//        for index in 1..<detailResut.count{
//            frame.origin.x = UIScreen.main.bounds.width * CGFloat(index)
//            frame.size = self.activityIndicator.frame.size
//            let indicator = UIActivityIndicatorView(frame:frame)
//            indicator.style = UIActivityIndicatorView.Style.whiteLarge
//            indicator.color = UIColor.black
//            activityIndicator!.tag = index
//            activityIndicator!.startAnimating()
//            self.scrollView.addSubview(activityIndicator!)
//            //let photoImage = self.phtotImageView
//            frame.origin.x = UIScreen.main.bounds.width * CGFloat(index)
//            frame.size = self.phtotImageView.frame.size
//            let photoImage = UIImageView(frame:frame)
//            Alamofire.request(self.derailResult[index].imageURL).responseImage { response in
//                if let image = response.result.value {
//                    photoImage.contentMode = .scaleAspectFill
//                    photoImage.clipsToBounds = true
//                    photoImage.image = image
//                    //self.activityIndicator.stopAnimating()
//                    //self.activityIndicator.isHidden = true
//                    photoImage.alpha = 1
//                    self.scrollView.addSubview(photoImage)
//                }
//            }
//            
//            frame.origin.x = UIScreen.main.bounds.width * CGFloat(index)
//            frame.size = self.nameLabe.frame.size
//            let label = UILabel(frame:frame)
//            label.text = self.derailResult[index].displayTitle
//            self.scrollView.addSubview(label)
            
            
            
            
            
            //            self.nameLabe.text = self.derailResult[0].displayTitle
            //            self.descriptionTextView.text = self.derailResult[0].distribution
            //            self.iconImageView.contentMode = .scaleAspectFill
            //            self.iconImageView.image = self.derailResult[0].image!
            //            Alamofire.request(self.derailResult[0].imageURL).responseImage { response in
            //                if let image = response.result.value {
            //                    self.phtotImageView.contentMode = .scaleAspectFill
            //                    self.phtotImageView.image = image
            //                    self.activityIndicator.stopAnimating()
            //                    self.activityIndicator.isHidden = true
            //                    self.phtotImageView.alpha = 1
            //                }
            //            }
            //            self.loadSound(animalName: derailResult[0].displayTitle)
            //            heatmapLayer.map = nil
            //            let name = self.derailResult[0].displayTitle
            //            let worker = ROGoogleTranslate()
            //            worker.sendRequestToServer(methodId: 2,request: ["animals":[name]]){ (result) in
            //                DispatchQueue.global().async {
            //                    if result != nil{
            //                        self.updateMap(result: result!)
            //                    }
            //                }
            //            }
//        }
//        scrollView.contentSize = CGSize(width: (UIScreen.main.bounds.width * CGFloat(detailResut.count)), height: scrollView.contentSize.height)
//
        
    }
    @IBAction func confrimButtoAction(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let tabBar: UITabBarController = appDelegate.window!.rootViewController as! UITabBarController
        let thirdTab = tabBar.viewControllers![2] as! UINavigationController
        let checkListTableViewController = thirdTab.viewControllers.first as! CheckListViewController
        checkListTableViewController.image = self.iconImageView.image
        checkListTableViewController.updateData(animalName: self.nameLabe.text!)
        confirmButton.isEnabled = false
    }
    
    func updateMap(result:NSDictionary){
        var listToAdd = [GMUWeightedLatLng]()
        if let list = result["response"] as? String{
            if let data = list.data(using: .utf8) {
                if let json = try? JSON(data: data) {
                    for latlong in json.arrayValue {
                        let lat = latlong[0].doubleValue.roundTo(places: 4)
                        let lng = latlong[1].doubleValue.roundTo(places: 4)
                        let coords = GMUWeightedLatLng(coordinate: CLLocationCoordinate2DMake(lat , lng ), intensity: 700.0)
                        listToAdd.append(coords)
                    }
                    DispatchQueue.main.async {
                        self.heatmapLayer.weightedData = listToAdd
                        self.heatmapLayer.map = self.mapView
                    }
                    
                }
            }
        }
        
    }
    
    /// Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ImageRecSegue"
        {
            if let destination = segue.destination as? ViewController {
                destination.delegate = self
            }
        }
    }
    
    
    
    /// Play animal sounde
    ///
    /// - Parameter url: Full path to the file
    func playUsingAVPlayer(url: URL) {
        player = AVPlayer(url: url)
        player?.play()
    }
    
    func playRemoteFile(url:String) {
        guard let url = URL(string: url) else {
            print("Invalid URL")
            return
        }
        playUsingAVPlayer(url:url)
    }
    
    /// Load file from server
    ///
    /// - Parameter animalName: Name of the animal
    func loadSound(animalName:String){
        self.playIcon.isHidden = true
        self.playButton.isHidden = true
        self.audioPlayer = nil
        let strWithNoSpace = animalName.replacingOccurrences(of: " ", with: "%20")
        let audioFileName = strWithNoSpace as NSString
        let pathExtension = audioFileName.pathExtension
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent("yourFileName."+pathExtension)
            return (documentsURL, [.removePreviousFile])
        }
        Alamofire.download("http://35.201.22.21:8081/getVoice?id=\(strWithNoSpace)", to: destination).response { response in
            if let localURL = response.destinationURL {
                print(localURL)
                do {
                    print(localURL.absoluteURL)
                    self.audioPlayer = try AVAudioPlayer(contentsOf:localURL.absoluteURL )
                    self.audioPlayer.prepareToPlay()
                    self.playButton.isHidden = false
                    self.playIcon.isHidden = false
                } catch let error {
                    print(error.localizedDescription)
                }
            } else {
                
            }
            
        }
    }
    
}

// Core location manager for handeling user location.
extension AnimalDetailViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location:CLLocation = locations.last{
            if self.currentLocation == nil || location.coordinate.latitude != self.currentLocation!.coordinate.latitude{
                self.currentLocation = location
            }
            
            print("Location: \(location)")
            
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                                  longitude: location.coordinate.longitude,
                                                  zoom: zoomLevel)
            
            /*if mapView.isHidden {
             mapView.isHidden = false
             mapView.camera = camera
             } else {*/
            mapView.animate(to: camera)
        }
        //}
    }
    
    // Handle authorization for the location manager.
    private func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
            self.phtotImageView.alpha = 0.5
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
    
    
}

//extension AnimalDetailViewController : UIScrollViewDelegate{
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        positionScroll = self.scrollView.contentOffset.x
//    }
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if self.scrollView.contentOffset.x > self.positionScroll || self.scrollView.contentOffset.x < self.positionScroll{
//            self.scrollView.isPagingEnabled = true
//        }else{
//            self.scrollView.isPagingEnabled = false
//        }
//    }
//
////    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
////        let pageNumber = scrollView.contentOffset.x / UIScreen.main.bounds.width
////        print(pageNumber)
////        self.pageControl.currentPage = Int(pageNumber)
////    }
//}





