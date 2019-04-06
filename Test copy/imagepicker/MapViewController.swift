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

class MapViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,GMSMapViewDelegate{
    var locationManager = CLLocationManager()
    private var heatmapLayer: GMUHeatmapTileLayer!
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    var animalIcons = [String]()
    var searchAnima = true
    var currentSelectedIcon : IndexPath?
    let imageCache = AutoPurgingImageCache()
    var urlList = [String:String]()
    private var gradientColors = [UIColor.green, UIColor.red]
    private var gradientStartPoints = [0.2, 1.0] as? [NSNumber]
    @IBOutlet weak var animalIconCollectionView: UICollectionView!
    
    
    
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var emptyView: UIView!
    
    @IBAction func filter(_ sender: Any) {
        //self.sendRequestToServer(methodId: 3,request: ["animals":["koala"]]){ (result) in
        
        //}
    }
    
    @IBAction func detailButton(_ sender: Any) {
        heatmapLayer = GMUHeatmapTileLayer()
        heatmapLayer.map = mapView
        heatmapLayer.radius = 80
        heatmapLayer.opacity = 0.8
        heatmapLayer.gradient = GMUGradient(colors: gradientColors,startPoints: gradientStartPoints!,colorMapSize: 256)
        addHeatmap()
        // Set the heatmap to the mapview.
        heatmapLayer.map = mapView
        heatmapLayer = GMUHeatmapTileLayer()
        heatmapLayer.map = mapView
        heatmapLayer.radius = 80
        heatmapLayer.opacity = 0.8
        heatmapLayer.gradient = GMUGradient(colors: gradientColors,startPoints: gradientStartPoints!,colorMapSize: 256)
//        var listToAdd = [GMUWeightedLatLng]()
//        self.sendRequestToServer(methodId: 2,request: ["animals":["kangaroo","koala"]]){ (result) in
//            if result != nil{
//                if let list = result!["response"] as? String{
//                    if let data = list.data(using: .utf8) {
//                        if let json = try? JSON(data: data) {
//                            for latlong in json.arrayValue {
//                                let lat = latlong[0].double
//                                let lng = latlong[1].double
//                                let coords = GMUWeightedLatLng(coordinate: CLLocationCoordinate2DMake(lat as! CLLocationDegrees, lng as! CLLocationDegrees), intensity: 1.0)
//                                listToAdd.append(coords)
//                            }
//                            print(listToAdd)
//                            DispatchQueue.main.async {
                                //print(self.heatmapLayer.weightedData = listToAdd)
                                self.addHeatmap()
                                print(self.heatmapLayer.map = self.mapView)
//                            }
//
//                        }
//                    }
//                }
//            }
//
//
//
//
//        }
//        heatmapLayer.map = mapView
    }
    
    override func viewDidLoad() {
        animalIconCollectionView.delegate = self
        animalIconCollectionView .dataSource = self
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
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
        emptyView.addSubview(mapView)
        detailButton.layer.shadowColor = UIColor.black.cgColor
        detailButton.layer.shadowOffset = CGSize(width: -1, height: -1)
        detailButton.layer.shadowRadius = 5
        detailButton.layer.shadowOpacity = 0.1
        animalIconCollectionView.layer.shadowColor = UIColor.black.cgColor
        animalIconCollectionView.layer.shadowOffset = CGSize(width: -1, height: -1)
        animalIconCollectionView.layer.shadowRadius = 5
        animalIconCollectionView.layer.shadowOpacity = 0.1
        super.viewDidLoad()
        //        mapView.isHidden = true
    }
    
    func addHeatmap()  {
        var list = [GMUWeightedLatLng]()
        do {
            // Get the data: latitude/longitude positions of police stations.
            if let path = Bundle.main.url(forResource: "police_stations", withExtension: "json") {
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
                    print(cachedAvatarImage)
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
        
        if self.currentSelectedIcon != nil{
            
        }
        self.currentSelectedIcon = indexPath
        if let cell = collectionView.cellForItem(at: indexPath) as! AnimalCollectionViewCell?{
            
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
            if location != currentLocation{var iconlist = [String]()
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
                                        }
                                    }
                                }
                            }
                            
                            
                        }
                    }
                }
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
    
    func sendRequestToServer(methodId:Int,request:NSDictionary, callback:@escaping (_ :NSDictionary?) -> ()){
        let url: String = "http://127.0.0.1:8081/restapi/ios"
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
    
    
    
}
