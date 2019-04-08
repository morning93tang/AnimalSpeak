//
//  MapViewController.swift
//  imagepicker
//
//  Created by 唐茂宁 on 28/3/19.
//  Copyright © 2019 Sara Robinson. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import Alamofire
import SwiftyJSON
import AlamofireImage

//

class MapViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,GMSMapViewDelegate,searchListDelegate{
    
    var showSearchResult = false
    var locationManager = CLLocationManager()
    private var heatmapLayer: GMUHeatmapTileLayer!
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 8.0
    var animalIcons = [String]()
    var searchAnima = true
    var currentSelectedIcon : IndexPath?
    let imageCache = AutoPurgingImageCache()
    var urlList = [String:String]()
    private var gradientColors = [UIColor.blue, UIColor.red]
    private var gradientStartPoints = [0.2, 1.0] as? [NSNumber]
    @IBOutlet weak var animalIconCollectionView: UICollectionView!
    
    @IBOutlet weak var searchInfroLabel: UILabel!
    
    @IBAction func refreshButton(_ sender: Any) {
        
    }
    
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var emptyView: UIView!
    
    @IBAction func filter(_ sender: Any) {
        //self.sendRequestToServer(methodId: 3,request: ["animals":["koala"]]){ (result) in
        
        //}
    }
    
    @IBAction func detailButton(_ sender: Any) {
        
        //self.performSegue(withIdentifier: "showDetail", sender: sender)
    }
    @IBOutlet weak var activityIndicatior: UIActivityIndicatorView!
    
    override func viewDidLoad() {

        self.detailButton.isEnabled = false
        animalIconCollectionView.delegate = self
        animalIconCollectionView .dataSource = self
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
        heatmapLayer.gradient = GMUGradient(colors: gradientColors,startPoints: gradientStartPoints!,colorMapSize: 256)
        emptyView.addSubview(mapView)
        detailButton.layer.shadowColor = UIColor.black.cgColor
        detailButton.layer.shadowOffset = CGSize(width: -1, height: -1)
        detailButton.layer.shadowRadius = 5
        detailButton.layer.shadowOpacity = 0.1
        animalIconCollectionView.layer.shadowColor = UIColor.black.cgColor
        animalIconCollectionView.layer.shadowOffset = CGSize(width: -1, height: -1)
        animalIconCollectionView.layer.shadowRadius = 5
        animalIconCollectionView.layer.shadowOpacity = 0.1
        self.activityIndicatior.isHidden = false
        self.activityIndicatior.style = UIActivityIndicatorView.Style.whiteLarge
        self.activityIndicatior.color = UIColor.black
        self.activityIndicatior.startAnimating()
        super.viewDidLoad()
        //        mapView.isHidden = true
    }
    
    func addHeatmap()  {
        var list = [GMUWeightedLatLng]()
        do {
            // Get the data: latitude/longitude positions of police stations.
            if let path = Bundle.main.url(forResource: "dfpolice_stations", withExtension: "json") {
                let data = try Data(contentsOf: path)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [[String: Any]] {
                    for item in object {
                        let lat = item["lat"]
                        let lng = item["lng"]
                        let coords = GMUWeightedLatLng(coordinate: CLLocationCoordinate2DMake(lat as! CLLocationDegrees, lng as! CLLocationDegrees), intensity: 1.0)
                        list.append(coords)
                    }
                } else {
                    print("Could not read the JSON.")
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        // Add the latlngs to the heatmap layer.
        print(list)
        heatmapLayer.weightedData = list
    }
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return animalIcons.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:AnimalCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "animalIconCell", for: indexPath) as! AnimalCollectionViewCell
        cell.number.text = self.animalIcons[indexPath.row]
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true
        cell.animalIconImageView.image = nil
        let name = cell.number.text!
        if self.urlList.count != 0 && self.animalIcons.count != 0{
            let urlRequest = URLRequest(url: URL(string: self.urlList[name]!)!)
            DispatchQueue.global().async {
                
                if let cachedAvatarImage = self.imageCache.image(for: urlRequest, withIdentifier: name)
                {
                    DispatchQueue.main.async {
                        cell.animalIconImageView.contentMode = .scaleAspectFill
                        cell.animalIconImageView.image = cachedAvatarImage
                    }
                }else{
                    Alamofire.request(urlRequest).responseImage { response in
                        debugPrint(response)
                        if let image = response.result.value {
                            cell.animalIconImageView.contentMode = .scaleAspectFill
                            cell.animalIconImageView.image = image
                            self.imageCache.add(image,for: urlRequest, withIdentifier: cell.number.text)
                        }
                    }
                    
                }
                
                
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let collection = self.animalIconCollectionView{
            let hight = collection.bounds.height
            let width = hight - 20
            return CGSize(width: width, height: width)
        }
        else{
            return CGSize(width: 0, height: 0)
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        self.detailButton.isEnabled = true
        self.activityIndicatior.isHidden = false
        if currentSelectedIcon != indexPath{
            self.currentSelectedIcon = indexPath
            if let cell = collectionView.cellForItem(at: indexPath) as! AnimalCollectionViewCell?{
                self.currentSelectedIcon = indexPath
                heatmapLayer.map = nil
                let name = cell.number.text!
                let lat = String(self.currentLocation!.coordinate.latitude)
                let lng = String(self.currentLocation!.coordinate.longitude)
                var listToAdd = [GMUWeightedLatLng]()
                
                if showSearchResult{
                    self.sendRequestToServer(methodId: 2,request: ["animals":[self.animalIcons[indexPath.row]]] ){ (result) in
                        if result != nil{
                            if let list = result!["response"] as? String{
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
                                            //self.addHeatmap()
                                            self.heatmapLayer.map = self.mapView
                                            self.activityIndicatior.isHidden = true
                                        }
                                        
                                    }
                                }
                            }
                        }
                        
                    }
                }else{
                    self.sendRequestToServer(methodId: 7,request: ["animal":name,"lat":lat,"lon":lng] ){ (result) in
                        if result != nil{
                            if let list = result!["response"] as? String{
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
                                            //self.addHeatmap()
                                            self.heatmapLayer.map = self.mapView
                                            self.activityIndicatior.isHidden = true
                                        }
                                        
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if CLLocationManager.authorizationStatus() == .denied{
            mapView.settings.myLocationButton = false
            let alertController = UIAlertController(title: "Unable to track your location", message: "Please check your location permission settings", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            assertionFailure("Segue had no identifier")
            return
        }
        if identifier == "detailAnimaSegue" {
            let destVC : SecondaryAnimalDetailViewController = segue.destination as! SecondaryAnimalDetailViewController
            if self.currentSelectedIcon != nil{
                destVC.animalName = self.animalIcons[self.currentSelectedIcon!.row]
            }
        }
        if identifier == "searchSegue"{
            let destVC : SearchViewController = segue.destination as! SearchViewController
            destVC.delegate = self
            
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
extension MapViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location:CLLocation = locations.last{
            if self.currentLocation == nil || location.coordinate.latitude != self.currentLocation!.coordinate.latitude{
                self.activityIndicatior.isHidden = false
                var iconlist = [String]()
                let userLocation = location.coordinate
                let lat = "\(userLocation.latitude)"
                let lng = "\(userLocation.longitude)"
                var params = ROGoogleTranslateParams()
                let translator = ROGoogleTranslate()
                self.sendRequestToServer(methodId: 6,request: ["lat":lat,"lon":lng]){ (result) in
                    if result != nil{
                        if let list = result!["response"] as? String{
                            if let data = list.data(using: .utf8) {
                                if let json = try? JSON(data: data) {
                                    for name in json.arrayValue {
                                        iconlist.append(name.stringValue)
                                    }
                                }
                            }
                            self.animalIcons = iconlist
                            for name in iconlist{
                                translator.apiKey = "AIzaSyCDS_M2Vf5qb4mwYsyM8vq_XuDkjCYYsF0"
                                params.text = name
                                translator.getimage(params: params) { (result) in
                                    self.urlList[name] = result
                                    if self.urlList.count == self.animalIcons.count{
                                        DispatchQueue.main.async {
                                            self.animalIconCollectionView.reloadData()
                                            self.activityIndicatior.isHidden = true
                                        }
                                    }
                                }
                            }
                            
                            
                        }
                    }
                }
                self.currentLocation = location
            }
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
                } else { //no errors
                    let statusCode = (response.response?.statusCode)! //example : 200print(value)
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
    
    func gerResultData(selctedanimalList: [animal]) {
        self.showSearchResult = true
        var queryList = [String]()
        for item in selctedanimalList{
            queryList.append(item.name)
            self.animalIcons = queryList
        }
        var listToAdd = [GMUWeightedLatLng]()
        if self.currentLocation != nil{
            self.activityIndicatior.isHidden = false
            let userLocation = self.currentLocation!.coordinate
            let lat = "\(userLocation.latitude)"
            let lng = "\(userLocation.longitude)"
            var params = ROGoogleTranslateParams()
            let translator = ROGoogleTranslate()
            //self.animalIcons = iconlist
            self.urlList.removeAll()
            for name in queryList{
                translator.apiKey = "AIzaSyCDS_M2Vf5qb4mwYsyM8vq_XuDkjCYYsF0"
                params.text = name
                translator.getimage(params: params) { (result) in
                    self.urlList[name] = result
                    if self.urlList.count == self.animalIcons.count{
                        DispatchQueue.main.async {
                            self.animalIcons = queryList
                            self.animalIconCollectionView.reloadData()
                            self.activityIndicatior.isHidden = true
                        }
                    }
                }
            }
        }
    }
        //        self.sendRequestToServer(methodId: 2,request: ["animals":queryList]){ (result) in
        //            if result != nil{
        //                if let list = result!["response"] as? String{
        //                    if let data = list.data(using: .utf8) {
        //                        if let json = try? JSON(data: data) {
        //                            for latlong in json.arrayValue {
        //                                let lat = latlong[0].doubleValue.roundTo(places: 4)
        //                                let lng = latlong[1].doubleValue.roundTo(places: 4)
        //                                let coords = GMUWeightedLatLng(coordinate: CLLocationCoordinate2DMake(lat , lng ), intensity: 700.0)
        //                                listToAdd.append(coords)
        //                            }
        //                            print(listToAdd)
        //                            var params = ROGoogleTranslateParams()
        //                            let translator = ROGoogleTranslate()
        //                            for name in queryList{
        //                                translator.apiKey = "AIzaSyCDS_M2Vf5qb4mwYsyM8vq_XuDkjCYYsF0"
        //                                params.text = name
        //                                translator.getimage(params: params) { (result) in
        //                                    self.urlList[name] = result
        //                                            self.animalIconCollectionView.reloadData()
        //                                        DispatchQueue.main.async {
        //                                            self.heatmapLayer.map = nil
        //                                            self.heatmapLayer.weightedData = listToAdd
        //                                            self.heatmapLayer.map = self.mapView
        //
        //                                        }
        //                                    }
        //                                }
        //                            }
        //
        //
        //                        }
        //                    }
        //                }
        //            }
        //
        //        }
}
    
    
    
    
    extension Double {
        
        /// Rounds the double to decimal places value
        
        func roundTo(places:Int) -> Double {
            
            let divisor = pow(10.0, Double(places))
            
            return (self * divisor).rounded() / divisor
            
        }
        
    }
    
    extension UIView {
        func fadeIn(duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
            UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
                self.alpha = 0.8
            }, completion: completion)  }
        
        func fadeOut(duration: TimeInterval = 1.0, delay: TimeInterval = 3.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
            UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
                self.alpha = 0.0
            }, completion: completion)
        }
        
    }
