//
//  SecondaryAnimalDetailViewController.swift
//  imagepicker
//
//  Created by 唐茂宁 on 7/4/19.
//  Copyright © 2019 Sara Robinson. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation
import GooglePlaces
import GoogleMaps
import SwiftyJSON

/// Modify from the detail view cotroller
class SecondaryAnimalDetailViewController: UIViewController,GMSMapViewDelegate {
    open class MyServerTrustPolicyManager: ServerTrustPolicyManager{
        open override func serverTrustPolicy(forHost host: String) -> ServerTrustPolicy? {
            return ServerTrustPolicy.disableEvaluation
        }
    }
    
    let sessaionManager = SessionManager(delegate: SessionDelegate(), serverTrustPolicyManager:MyServerTrustPolicyManager(policies:["https://118.139.67.137:8443":.disableEvaluation]))
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var animalImgaeView: UIImageView!
    @IBOutlet weak var tittleLabel: UILabel!
    @IBOutlet weak var descriptionTextBox: UITextView!
    var animalName = ""
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playIcon: UIImageView!
    var player: AVPlayer?
    var audioPlayer:AVAudioPlayer!
    var locationManager = CLLocationManager()
    private var heatmapLayer: GMUHeatmapTileLayer!
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 5.0
    var image: UIImage?
    private var gradientColors = [UIColor.blue, UIColor.red]
    private var gradientStartPoints = [0.2, 1.0] as [NSNumber]
    @IBAction func playSoundInstance(_ sender: Any) {
        if audioPlayer.isPlaying {
            self.audioPlayer.stop()
            self.audioPlayer.currentTime = 0
            self.playIcon.isHighlighted = false
        }else{
            self.audioPlayer.play()
            self.playIcon.isHighlighted = true
        }
    }
    
    override func viewDidLoad() {
        self.playButton.isHidden = true
        self.playIcon.isHidden = true
        self.playButton.layer.cornerRadius = 5
        self.playButton.clipsToBounds = true
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        placesClient = GMSPlacesClient.shared()
        self.activityIndicator.isHidden = false
        self.activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        self.activityIndicator.color = UIColor.black
        self.activityIndicator.startAnimating()
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        mapView = GMSMapView.map(withFrame: emptyView.bounds, camera: camera)
        mapView.delegate = self
        //mapView.settings.myLocationButton = true
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
        descriptionTextBox.layer.cornerRadius = 5
        descriptionTextBox.layer.borderColor = UIColor.gray.cgColor
        descriptionTextBox.layer.borderWidth = 0.5
        descriptionTextBox.clipsToBounds = true
        if UIApplication.shared.statusBarOrientation.isLandscape {
            let height = UIScreen.main.bounds.size.height
            self.scrollView.setContentOffset(CGPoint(x: 0, y: height), animated: true)
        }
        self.tittleLabel.text = self.animalName
        let translator = APIWoker()
        var params = ROGoogleTranslateParams()
        params.text = self.animalName
        translator.getDetail(params: params){ (detailResult) in
            if detailResult.animalType.count > 1 {
                DispatchQueue.main.async {
                    self.descriptionTextBox.text = detailResult.distribution
                    Alamofire.request(detailResult.imageURL).responseImage { response in
                        debugPrint(response)
                        debugPrint(response.result)
                        if let image = response.result.value {
                            self.animalImgaeView.contentMode = .scaleAspectFill
                            self.animalImgaeView.image = image
                            self.activityIndicator.stopAnimating()
                            self.activityIndicator.isHidden = true
                            self.gerResultData()
                            super.viewDidLoad()
                        }
                    }
                }
            }
            else{
                translator.getimage(params: params){ (detailResult) in
                    if detailResult.count > 1 {
                        DispatchQueue.main.async {
                            Alamofire.request(detailResult).responseImage { response in
                                debugPrint(response)
                                debugPrint(response.result)
                                if let image = response.result.value {
                                    self.animalImgaeView.contentMode = .scaleAspectFill
                                    self.animalImgaeView.image = image
                                    self.activityIndicator.stopAnimating()
                                    self.activityIndicator.isHidden = true
                                    self.gerResultData()
                                    self.descriptionTextBox.text = "Sorry,we currently do not have any detail imfromation about this animal."
                                    super.viewDidLoad()
                                }
                            }
                        }
                    }
                }
            }
        }
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
        
        }}
        
    
    /// Get animal deteail form server
    func gerResultData() {
        self.loadSound(animalName: self.animalName)
        heatmapLayer.map = nil
        let name = self.animalName
        let worker = APIWoker()
        worker.sendRequestToServer(methodId: 2,request: ["animals":[name]]){ (result) in
            DispatchQueue.global().async {
                if result != nil{
                    self.updateMap(result: result!)
                }
            }
            
        }
        
        
        
    }
    
    /// Initialize the AVplayer with the audio file
    ///
    /// - Parameter url: Full path to the file
    func playUsingAVPlayer(url: URL) {
        player = AVPlayer(url: url)
        player?.play()
    }
    
    /// Initialize the AVplayer with the audio file
    ///
    /// - Parameter url: Full path to the file
    func playRemoteFile(url:String) {
        guard let url = URL(string: url) else {
            print("Invalid URL")
            return
        }
        playUsingAVPlayer(url:url)
    }
    
    /// Load the audio file from server user file name
    ///
    /// - Parameter animalName: animalName
    func loadSound(animalName:String){
        self.playIcon.isHidden = true
        self.playButton.isHidden = true
        self.audioPlayer = nil
        let strWithNoSpace = animalName.replacingOccurrences(of: " ", with: "%20")
        let audioFileName = strWithNoSpace as NSString
        
        //path extension will consist of the type of file it is, m4a or mp4
        let pathExtension = audioFileName.pathExtension
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            // the name of the file here I kept is yourFileName with appended extension
            documentsURL.appendPathComponent("yourFileName."+pathExtension)
            return (documentsURL, [.removePreviousFile])
        }
        Alamofire.download("http://35.201.22.21:8081/getVoice?id=\(strWithNoSpace)", to: destination).response { response in
            
            if let localURL = response.destinationURL {
                
                print(localURL)
                do {
                    print(localURL.absoluteURL)
                    self.audioPlayer = try AVAudioPlayer(contentsOf:localURL.absoluteURL )//(URL:NSURL(string:urlString))
                    //                    guard let player = self.audioPlayer else { return }
                    self.audioPlayer.prepareToPlay()
                    self.playButton.isHidden = false
                    self.playIcon.isHidden = false
                    
                } catch let error {
                    print(error.localizedDescription)
                }
                //self.preparePlayer(urlString:localURL.absoluteString,filrExtension:"wav")
                
            } else {
            }
            
        }
    }
    
}

extension SecondaryAnimalDetailViewController: CLLocationManagerDelegate {
    
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
            mapView.animate(to: camera)
        }
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
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
