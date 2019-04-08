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


class AnimalDetailViewController: UIViewController, ResultDetailDelegate,GMSMapViewDelegate {
    var audioPlayer:AVAudioPlayer!
    var derailResult = DetailResult()
    var locationManager = CLLocationManager()
    private var heatmapLayer: GMUHeatmapTileLayer!
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 5.0
    private var gradientColors = [UIColor.blue, UIColor.red]
    private var gradientStartPoints = [0.2, 1.0] as [NSNumber]
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var emptyView: UIView!
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var playIcon: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var phtotImageView: UIImageView!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var nameLabe: UILabel!
    var player: AVPlayer?

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
//        if UIApplication.shared.statusBarOrientation.isLandscape {
//            let height = UIScreen.main.bounds.size.height
//            self.scrollView.setContentOffset(CGPoint(x: 0, y: height), animated: true)
//        }
//        let originalString = "http://35.201.22.21:8081/getVoice id=Red Fox"
//        let escapedString =  Foundation.URL(string: originalString)
//        Alamofire.request("http://35.201.22.21:8081/getVoice?id=Red Fox",method:.get, encoding: URLEncoding.default).response { response in
//            print(response)
//        }
        
//        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//
//        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)
//
//        if FileManager().fileExists(atPath: destinationUrl.path)
//        {
//            completion(destinationUrl.path, nil)
//        }
        
//        ROGoogleTranslate.loadFileAsync(url: escapedString!){
//            (completion:String?,error:Error?)  in
//                print(completion)
//                self.preparePlayer(urlString:completion!,filrExtension:"wav")
//                let url = URL(fileURLWithPath: completion!)
//                self.playUsingAVPlayer(url: url)

//
//        }
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
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        self.phtotImageView.alpha = 0.5
        self.phtotImageView.image = nil
        self.derailResult = detailResut
        //DispatchQueue.main.async {
        //UIDevice.current.identifierForVendor?.uuidString
            self.nameLabe.text = self.derailResult.displayTitle
            self.descriptionTextView.text = self.derailResult.distribution
            self.iconImageView.contentMode = .scaleAspectFill
            self.iconImageView.image = self.derailResult.image!
            Alamofire.request(self.derailResult.imageURL).responseImage { response in
                debugPrint(response)
                debugPrint(response.result)
                if let image = response.result.value {
                    self.phtotImageView.contentMode = .scaleAspectFill
                    self.phtotImageView.image = image
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.phtotImageView.alpha = 1
                }
//                let sender = ROGoogleTranslate()
//                sender.sendRequestToServer(methodId: 8, request: ["animal":self.derailResult.displayTitle],callback: { result in
//                    if let urlString = result!["response"] as? String {
//                        let pathExtention = String(urlString.suffix(3))
//                        print(pathExtention)
//                        self.playRemoteFile(url:urlString)
//                    }
//
//                })
//
            }
        self.loadSound(animalName: derailResult.displayTitle)
        heatmapLayer.map = nil
        let name = self.derailResult.displayTitle
        var listToAdd = [GMUWeightedLatLng]()
        self.sendRequestToServer(methodId: 2,request: ["animals":[name]]){ (result) in
            if result != nil{
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ImageRecSegue"
        {
            if let destination = segue.destination as? ViewController {
                destination.delegate = self
            }
        }
    }
    
//    func play(url:NSURL) {
//        print("playing \(url)")
//
//        do {
//            self.player = try AVAudioPlayer(contentsOf: url as URL)
//            player.prepareToPlay()
//            player.volume = 1.0
//            player.play()
//        } catch let error as NSError {
//            //self.player = nil
//            print(error.localizedDescription)
//        } catch {
//            print("AVAudioPlayer init failed")
//        }
//
//    }
    
    
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
        let url: String = "http://35.201.22.21:8081/restapi/ios"
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
    
    

    
//    func preparePlayer(urlString:String,filrExtension:String){
//        
//        do {
////            audioPlayer = try AVAudioPlayer(contentsOf: )//(URL:NSURL(string:urlString))
//            guard let player = audioPlayer else { return }
//            player.prepareToPlay()
//            player.play()
//            
//        } catch let error {
//            print(error.localizedDescription)
//        }
//
//    }
    
//    func downloadFile(URLstring:String) {
//
//        if let audioUrl = URL(string: URLstring) {
//
//            // then lets create your document folder url
//            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//
//            // lets create your destination file url
//            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
//            print(destinationUrl)
//
//            // to check if it exists before downloading it
//            if FileManager.default.fileExists(atPath: destinationUrl.path) {
//                print("The file already exists at path")
//
//                // if the file doesn't exist
//            } else {
//
//                // you can use NSURLSession.sharedSession to download the data asynchronously
//                URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) -> Void in
//                    guard let location = location, error == nil else { return }
//                    do {
//                        // after downloading your file you need to move it to your destination url
//                        try FileManager.default.moveItem(at: location, to: destinationUrl)
//                        print("File moved to documents folder")
//                    } catch let error as NSError {
//                        print(error.localizedDescription)
//                    }
//                }).resume()
//            }
//        }
//
//    }
//
//    func playdownload(URLstring:String) {
//
//        if let audioUrl = URL(string: URLstring) {
//
//            // then lets create your document folder url
//            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//
//            // lets create your destination file url
//            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
//
//            //let url = Bundle.main.url(forResource: destinationUrl, withExtension: "mp3")!
//
//            do {
//                audioPlayer = try AVAudioPlayer(contentsOf: destinationUrl)
//                guard let player = audioPlayer else { return }
//                player.prepareToPlay()
//                player.play()
//            } catch let error {
//                print(error.localizedDescription)
//            }
//        }
//
//    }
//
    
}


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
    
    
    
    
