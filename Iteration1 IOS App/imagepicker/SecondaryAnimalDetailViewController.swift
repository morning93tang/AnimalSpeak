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

class SecondaryAnimalDetailViewController: UIViewController,GMSMapViewDelegate {
    
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
    private var gradientColors = [UIColor.blue, UIColor.red]
    private var gradientStartPoints = [0.2, 1.0] as? [NSNumber]
    @IBAction func playSoundInstance(_ sender: Any) {
        self.audioPlayer.play()
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
        mapView.settings.myLocationButton = true
        mapView.settings.zoomGestures = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        heatmapLayer = GMUHeatmapTileLayer()
        heatmapLayer.map = mapView
        heatmapLayer.radius = 40
        heatmapLayer.opacity = 0.6
        heatmapLayer.gradient = GMUGradient(colors: gradientColors,startPoints: gradientStartPoints!,colorMapSize: 256)
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
        let translator = ROGoogleTranslate()
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
    
    func gerResultData() {
        self.loadSound(animalName: self.animalName)
        heatmapLayer.map = nil
        let name = self.animalName
        var listToAdd = [GMUWeightedLatLng]()
        self.sendRequestToServer(methodId: 2,request: ["animals":[name]]){ (result) in
            if result != nil{
                print(result)
                if let list = result!["response"] as? String{
                    print(list)
                    if let data = list.data(using: .utf8) {
                        if let json = try? JSON(data: data) {
                            for latlong in json.arrayValue {
                                let lat = latlong[0].doubleValue.roundTo(places: 4)
                                let lng = latlong[1].doubleValue.roundTo(places: 4)
                                let coords = GMUWeightedLatLng(coordinate: CLLocationCoordinate2DMake(lat , lng ), intensity: 700.0)
                                listToAdd.append(coords)
                            }
                            print(listToAdd)
                            DispatchQueue.main.async {
                                self.heatmapLayer.weightedData = listToAdd
                                //self.addHeatmap()
                                self.heatmapLayer.map = self.mapView
                            }
                            
                        }
                    }
                }
            }
            
        }
        
    }
    
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
                
                print("fuck no")
            }
            
        }
    }
    
    func sendRequestToServer(methodId:Int,request:NSDictionary, callback:@escaping (_ :NSDictionary?) -> ()){
        let url: String = "http://35.201.22.21:8081//restapi/ios"
        var jsonString = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: request, options: .prettyPrinted)
            jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        }catch{
            print(error.localizedDescription)
        }
        let parameters = [
            "methodId":methodId,
            "postData":jsonString
            
            ] as [String : Any]
        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
            //                    var statusCode = response.response?.statusCode
            //                    print(statusCode)
            switch response.result {
            case .success:
                if let alamoError = response.result.error {
                    let alamoCode = alamoError._code
                    let statusCode = (response.response?.statusCode)!
                    print(alamoCode)
                    print(statusCode)
                } else { //no errors
                    let statusCode = (response.response?.statusCode)! //example : 200print(value)
                    print(statusCode)
                    if let value = response.result.value {
                        let responseDict = value as? NSDictionary
                        //                                if let resultValue = responseDict!["response"] as? String
                        //                                {
                        //                                    print(resultValue)
                        callback(responseDict)
                        //                                }
                    }
                }
            case .failure(let error):
                print(error)
            }
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
            
            /*if mapView.isHidden {
             mapView.isHidden = false
             mapView.camera = camera
             } else {*/
            mapView.animate(to: camera)
        }
        //}
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
