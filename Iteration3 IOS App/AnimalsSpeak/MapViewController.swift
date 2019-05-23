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
import CoreLocation



//

/// This class implement the collectionView and collectionViewDataSource for dsiplaying the rounded animal icons in the top section of the MapView. When Icon seleted heat map will be renderd with on the mapView. Temperature Data will also be pass to slidingUpView. Animal location data and weather condition data is required form animalsSpeak server using REST API calls.
class MapViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,GMSMapViewDelegate,searchListDelegate{
    
    //    open class MyServerTrustPolicyManager: ServerTrustPolicyManager{
    //        open override func serverTrustPolicy(forHost host: String) -> ServerTrustPolicy? {
    //            return ServerTrustPolicy.disableEvaluation
    //        }
    //    }
    //
    //    let sessaionManager = SessionManager(delegate: SessionDelegate(), serverTrustPolicyManager:MyServerTrustPolicyManager(policies:["https://118.139.67.137:8443":.disableEvaluation]))
    //

    @IBAction func searchAnima(_ sender: Any) {
        
    }
    var apiKey = "AIzaSyCDS_M2Vf5qb4mwYsyM8vq_XuDkjCYYsF0"
    let slideUpPanelManager = TSSlidingUpPanelManager.with
    var showSearchResult = false
    var firstTime = true
    var locationSearchResult: CLLocationCoordinate2D?
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
    var sendAble = false
    var userLOcation: CLLocation?
    var slidingVC: SUSlidingUpVC?
    var selectedAnimal = ""
    private var gradientColors = [UIColor.blue, UIColor.red]
    private var gradientStartPoints = [0.2, 1.0] as [NSNumber]
    @IBOutlet weak var animalIconCollectionView: UICollectionView!
    
    @IBOutlet weak var buttonCark: UIActivityIndicatorView!
    

    @IBOutlet weak var searchInfroLabel: UILabel!
    
    @IBAction func refreshButton(_ sender: Any) {
        self.slideUpPanelManager.changeSlideUpPanelStateTo(toState: SLIDE_UP_PANEL_STATE.CLOSED)
        reload(self)
    }
    
    @IBOutlet weak var emptyView: UIView!
    
    @IBAction func filter(_ sender: Any) {
        //self.sendRequestToServer(methodId: 3,request: ["animals":["koala"]]){ (result) in
        
        //}
    }
    
    
    
    @IBAction func backToCurrentLocation(_ sender: Any) {
        if self.userLOcation != nil{
            mapView.clear()
            let camera = GMSCameraPosition.camera(withTarget: self.userLOcation!.coordinate, zoom: 6.0)
            mapView.animate(to: camera)
            self.currentLocation = self.userLOcation
            self.locationSearchResult = self.userLOcation!.coordinate
            reload(self)
        }
    }
    
    
    
    
    
    @IBAction func reload(_ sender: Any) {
        
        self.heatmapLayer.map = nil
        self.activityIndicatior.isHidden = false
        self.animalIcons = []
        self.urlList = [:]
        self.sendAble = false
        self.animalIconCollectionView.deselectAllItems(animated: false)
        self.animalIconCollectionView.reloadData()
        
        var iconlist = [String]()
        var counter = 0
        var userLocation = self.currentLocation!.coordinate
        if self.locationSearchResult != nil{
            userLocation = self.locationSearchResult!
        }
        let lat = "\(userLocation.latitude)"
        let lng = "\(userLocation.longitude)"
        var params = ROGoogleTranslateParams()
        let translator = APIWoker()
        translator.sendRequestToServer(methodId: 6,request: ["lat":lat,"lon":lng]){ (result) in
            DispatchQueue.global().async {
                if result != nil{
                    if let list = result!["response"] as? String{
                        if let data = list.data(using: .utf8) {
                            if let json = try? JSON(data: data) {
                                for name in json.arrayValue {
                                    translator.apiKey = self.apiKey
                                    params.text = name.stringValue
                                    translator.getimage(params: params) { (result) in
                                        self.urlList[name.stringValue] = result
                                        iconlist.append(name.stringValue)
                                            DispatchQueue.main.async {
                                                counter = counter + 1
                                                if counter == json.arrayValue.count - 1{
                                                    self.animalIcons = iconlist
                                                    self.animalIconCollectionView.reloadData()
                                                    self.activityIndicatior.isHidden = true
                                                }
                                            }
                                        
                                    }
                                }
                            }
                        }
                        
                        
                        
                        
                    }
                }else{
                    self.animalIcons = []
                    self.urlList = [:]
                    CBToast.showToast(message: "This address is beyond the Victoria border.", aLocationStr: "bottom", aShowTime: 5.0)
                }
            }
        }
    }
    

    
    @IBOutlet weak var activityIndicatior: UIActivityIndicatorView!
    
    /// Initial the view
    override func viewDidLoad() {
        
        //self.sendable = false
        slideUpPanelManager.slidingUpPanelStateDelegate = self
        animalIconCollectionView.delegate = self
        animalIconCollectionView .dataSource = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 20
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        placesClient = GMSPlacesClient.shared()
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        mapView = GMSMapView.map(withFrame: emptyView.bounds, camera: camera)
        mapView.delegate = self
        mapView.settings.zoomGestures = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        heatmapLayer = GMUHeatmapTileLayer()
        heatmapLayer.map = mapView
        heatmapLayer.radius = 40
        heatmapLayer.opacity = 0.6
        heatmapLayer.gradient = GMUGradient(colors: gradientColors,startPoints: gradientStartPoints,colorMapSize: 256)
        emptyView.addSubview(mapView)
        animalIconCollectionView.layer.shadowColor = UIColor.black.cgColor
        animalIconCollectionView.layer.shadowOffset = CGSize(width: -1, height: -1)
        animalIconCollectionView.layer.shadowRadius = 5
        animalIconCollectionView.layer.shadowOpacity = 0.1
        self.activityIndicatior.isHidden = false
        self.activityIndicatior.style = UIActivityIndicatorView.Style.whiteLarge
        self.activityIndicatior.color = UIColor.black
        self.activityIndicatior.startAnimating()
        super.viewDidLoad()
        CBToast.showToast(message: "Select an animal icon to check its distribution in the radius of 5KMs.", aLocationStr: "bottom", aShowTime: 5.0)
        buttonCark.layer.cornerRadius = 8
        //        mapView.isHidden = true
    }
    
    
    
    
    
    /// Define the number of section in collection view
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    /// Define the number of cell will be shown in the colletion view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return animalIcons.count
    }
    
    
    
    /// Asks your data source object for the cell that corresponds to the specified item in the collection view.
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
            if self.urlList[name] != nil && URL(string: self.urlList[name]!) != nil{
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
        }
        return cell
    }
    
    /// Asks the delegate for the size of the specified item’s cell.
    ///
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
    
    
    /// Update map using animals location data
    ///
    /// - Parameter result: Anima loaction coodinates
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
                        //self.addHeatmap()
                        self.heatmapLayer.map = self.mapView
                        self.activityIndicatior.isHidden = true
                    }
                    
                }
            }
        }
        self.slidingVC!.animalName = self.animalIcons[self.currentSelectedIcon!.row]
        if let demand_windspeed_max = result["demand_windspeed_max"] as? String{
            if let demand_windspeed_min = result["demand_windspeed_min"] as? String{
                DispatchQueue.main.async {
                    self.slidingVC!.idealWind.text = "Ideal Wind Speed: \(demand_windspeed_min)m/s - \(demand_windspeed_max)m/s"
                    //self.slidingVC!.windLabel.text = "Ideal WindS"
                }
            }
            
        }
        
        if let demand_windspeed = result["demand_windspeed"] as? String{
            if let current_windspeed = result["current_windspeed"] as? String{
                DispatchQueue.main.async {
                    self.slidingVC!.windLabel.text = "\(current_windspeed)m/s"
                    if demand_windspeed == "yes" || demand_windspeed == "too low"{
                        self.slidingVC!.windImageView.image = UIImage(named: "wind")
                    }
                    if demand_windspeed == "too high"{
                        self.slidingVC!.windImageView.image = UIImage(named: "windy")
                        self.slidingVC!.windLabel.halfTextColorChange(fullText: "\(current_windspeed)m/s", changeText: "\(current_windspeed)m/s",color: UIColor.red, bold: false)
                    }
                    
                }
            }
        }
        
        
        if let demand_humid_max = result["demand_humid_max"] as? String{
            if let demand_humid_min = result["demand_humid_min"] as? String{
                DispatchQueue.main.async {
                    self.slidingVC!.idealHumid.text = "Ideal Humidty: \(demand_humid_min)% - \(demand_humid_max)%"
                }
            }
        }
        
        
        if let demand_humi = result["demand_humi"] as? String{
            if let current_humid = result["current_humid"] as? String{
                DispatchQueue.main.async {
                    self.slidingVC!.humidtyLabel.text = "\(current_humid)%"
                    if demand_humi == "yes" || demand_humi == "to high"{
                        self.slidingVC!.humidtyImageView.image = UIImage(named: "wet")
                    }
                    if demand_humi == "too low"{
                        self.slidingVC!.humidtyImageView.image = UIImage(named: "dry")
                        self.slidingVC!.humidtyLabel.halfTextColorChange(fullText: " \(current_humid)%", changeText: "\(current_humid)%",color: UIColor.red, bold: false)
                    }
                    
                }
            }
        }
        
        if let demand_temperature_max = result["demand_temperature_max"] as? String{
            if let demand_temperature_min = result["demand_temperature_min"] as? String{
                DispatchQueue.main.async {
                    self.slidingVC!.idealTemp.text = "Ideal Temperature: \(demand_temperature_min)\u{00B0}C - \(demand_temperature_max)\u{00B0}C"
                }
            }
        }
        
        
        if let demand_temperature = result["demand_temperature"] as? String{
            if let current_temperature = result["current_temperature"] as? String{
                DispatchQueue.main.async {
                    self.slidingVC!.tempLabel.text = "\(current_temperature)\u{00B0}C"
                    if demand_temperature == "yes"{
                        self.slidingVC!.tempImageView.image = UIImage(named: "goodtemp")
                    }
                    if demand_temperature == "too low"{
                        self.slidingVC!.tempImageView.image = UIImage(named: "cold")
                        self.slidingVC!.tempLabel.halfTextColorChange(fullText: "\(current_temperature)\u{00B0}C", changeText: "\(current_temperature)\u{00B0}C",color: UIColor.blue, bold: false)
                    }
                    if demand_temperature == "too high"{
                        self.slidingVC!.tempImageView.image = UIImage(named: "hot")
                        self.slidingVC!.tempLabel.halfTextColorChange(fullText: "\(current_temperature)\u{00B0}C", changeText: "\(current_temperature)\u{00B0}C",color: UIColor.red, bold: false)
                    }
                    
                }
                DispatchQueue.main.async {
                    
                }
            }
        }

        if let possibility = result["possibility"] as? String{
            DispatchQueue.main.async {
                print(possibility)
                let possibilityString = possibility.capitalizingFirstLetter()
                let stringValue =  possibilityString + " to see the animal."
                
                self.slidingVC!.posibilityLabel.text = stringValue
                if possibility == "have a chance"{
                    self.slidingVC!.posibilityLabel.halfTextColorChange(fullText: stringValue, changeText: possibilityString,color: UIColor.blue, bold: true)
                }
                if possibility == "very unlikely"{
                    self.slidingVC!.posibilityLabel.halfTextColorChange(fullText: stringValue, changeText: possibilityString,color: UIColor.red, bold: true)
                }
                if possibility == "unlikely"{
                    self.slidingVC!.posibilityLabel.halfTextColorChange(fullText: stringValue, changeText: possibilityString,color: UIColor.orange, bold: true)
                }
                if possibility == "likely"{
                    self.slidingVC!.posibilityLabel.halfTextColorChange(fullText: stringValue, changeText: possibilityString,color: UIColor.green, bold: true)
                }
                if possibility == "very likely"{
                    self.slidingVC!.posibilityLabel.halfTextColorChange(fullText: stringValue, changeText: possibilityString,color: UIColor.green, bold: true)
                }
                self.slideUpPanelManager.changeSlideUpPanelStateTo(toState: .DOCKED)
            }
        }
        
        
        
    }
    
    
    
    /// Perform change on the map when cell in collection view has been selection
    ///
    /// - Parameters:
    ///   - collectionView: Current instance of collection view
    ///   - indexPath: Index of selected cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.sendAble = true
        self.activityIndicatior.isHidden = false
        if currentSelectedIcon != indexPath{
            self.currentSelectedIcon = indexPath
            if let cell = collectionView.cellForItem(at: indexPath) as! AnimalCollectionViewCell?{
                self.currentSelectedIcon = indexPath
                heatmapLayer.map = nil
                let name = cell.number.text!
                if name != self.selectedAnimal{
                    toggleSlidingUpPanel()
                    self.selectedAnimal = name
                    let lat = String(self.locationSearchResult!.latitude)
                    print("\(self.locationSearchResult!.latitude)")
                    let lng = String(self.locationSearchResult!.longitude)
                    if showSearchResult{
                        let worker = APIWoker()
                        worker.sendRequestToServer(methodId: 7,request: ["animal":name,"lat":lat,"lon":lng] ){ (result) in
                            DispatchQueue.global().async {
                                if result != nil{
                                    
                                    self.updateMap(result: result!)
                                }
                            }
                        }
                    }else{
                        let worker = APIWoker()
                        worker.sendRequestToServer(methodId: 7,request: ["animal":name,"lat":lat,"lon":lng] ){ (result) in
                            DispatchQueue.global().async {
                                if result != nil{
                                    
                                    self.updateMap(result: result!)
                                }
                            }
                        }
                    }
                    
                }
            }
        }
        else{
            self.activityIndicatior.isHidden = true
        }
    }
    
    /// Check user location permission after view loaded
    ///
    /// - Parameter animated: Update view with animation
    override func viewWillAppear(_ animated: Bool) {
        if CLLocationManager.authorizationStatus() == .denied{
            mapView.settings.myLocationButton = false
            let alertController = UIAlertController(title: "Unable to track your location", message: "Please check your location permission settings", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    /// Notifies the view controller that a segue is about to be performed.
    ///
    /// - Parameters:
    ///   - segue: segue
    ///   - sender: sender description
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        if identifier == "detailAnimaSegue" {
            let destVC : SecondaryAnimalDetailViewController = segue.destination as! SecondaryAnimalDetailViewController
            if self.currentSelectedIcon != nil{
                destVC.animalName = self.animalIcons[self.currentSelectedIcon!.row]
            }
        }
        if identifier == "searchSegue"{
            self.slideUpPanelManager.changeSlideUpPanelStateTo(toState: SLIDE_UP_PANEL_STATE.CLOSED)
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
    
    func getAutocompletePicker() {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        let filter = GMSAutocompleteFilter()
        filter.country = "AU"
        autocompleteController.autocompleteFilter = filter
        present(autocompleteController, animated: true, completion: nil)
    }
    @IBAction func serachLocation(sender: UIButton)
    {
//        self.viewContainer.isHidden = true
        self.getAutocompletePicker()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func mapView (_ mapView: GMSMapView, didEndDragging didEndDraggingMarker: GMSMarker) {
        
        self.locationSearchResult = didEndDraggingMarker.position
        let camera = GMSCameraPosition.camera(withLatitude: didEndDraggingMarker.position.latitude,
                                              longitude: didEndDraggingMarker.position.longitude,
                                              zoom: 10)
        mapView.animate(to: camera)
        self.reload(self)
        
    }
    
}
extension MapViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    
    /// Tells the delegate that new location data is available.
    ///
    /// - Parameters:
    ///   - manager: manager instance
    ///   - locations: locations description
    
   
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location:CLLocation = locations.last{
                self.userLOcation = location
                self.currentLocation = location
                if firstTime{
                    self.locationSearchResult = location.coordinate
                    self.reload(self)
                    
                    let camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 6.0)
                    mapView.animate(to: camera)
                }
                firstTime = false
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
    
   
    
    /// Get detail result of an animal and displaying them on the screen
    ///
    /// - Parameter selctedanimalList: List of selected animals.
    func gerResultData(selctedanimalList: [animal]) {
        self.sendAble = false
        self.currentSelectedIcon = nil
        self.showSearchResult = true
        var queryList = [String]()
        for item in selctedanimalList{
            queryList.append(item.name)
            self.animalIcons = queryList
        }
        if self.currentLocation != nil{
            self.activityIndicatior.isHidden = false
            _ = self.currentLocation!.coordinate
            var params = ROGoogleTranslateParams()
            let translator = APIWoker()
            //self.animalIcons = iconlist
            self.urlList.removeAll()
            for name in queryList{
                translator.apiKey = self.apiKey
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
}




extension Double {
    
    /// Rounds the double to decimal places value
    
    func roundTo(places:Int) -> Double {
        
        let divisor = pow(10.0, Double(places))
        
        return (self * divisor).rounded() / divisor
        
    }
    
}

// MARK: - Add animation for displaying UIView
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


extension MapViewController: GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        mapView.clear()
        
        let name = place.addressComponents?.first(where: { $0.type == "administrative_area_level_1" })?.shortName
        if name != "VIC" {
             CBToast.showToast(message: "This address is beyond the Victoria border.", aLocationStr: "bottom", aShowTime: 5.0)
        }else{
            let position = place.coordinate
            let marker = GMSMarker(position: position)
            marker.title = place.name
            marker.snippet = "Long press to drag"
            marker.isDraggable = true
            marker.map = self.mapView
            marker.icon = UIImage(named: "zoom")?.resize(maxWidthHeight: 30.0)
            let camera = GMSCameraPosition.camera(withLatitude: position.latitude,
                                                  longitude: position.longitude,
                                                  zoom: 10)
            mapView.animate(to: camera)
            self.locationSearchResult = position
            self.mapView.selectedMarker = marker
            self.reload(self)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
//        self.viewContainer.isHidden = true
//
        print("Error: ", error.localizedDescription)
    }
    
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
//        self.viewContainer.isHidden = true
//        self.indicatorView.isHidden = true
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

extension MapViewController: TSSlidingUpPanelStateDelegate{
    
    
    func toggleSlidingUpPanel() {
        switch slideUpPanelManager.getSlideUpPanelState() {
        case .OPENED:
            slideUpPanelManager.changeSlideUpPanelStateTo(toState: .CLOSED)
            break
        case .CLOSED:
            slideUpPanelManager.changeSlideUpPanelStateTo(toState: .CLOSED)
            break
        case .DOCKED:
            slideUpPanelManager.changeSlideUpPanelStateTo(toState: .CLOSED)
            break
        }
    }
    func slidingUpPanelStateChanged(slidingUpPanelNewState: SLIDE_UP_PANEL_STATE, yPos: CGFloat) {
        print("[SUFirstScreenVC::slidingUpPanelStateChanged] slidingUpPanelNewState=\(slidingUpPanelNewState) yPos=\(yPos)")
    }
}

extension UICollectionView {
    
    func deselectAllItems(animated: Bool) {
        guard let selectedItems = indexPathsForSelectedItems else { return }
        for indexPath in selectedItems { deselectItem(at: indexPath, animated: animated) }
    }
}

extension UILabel {
    func halfTextColorChange (fullText : String , changeText : String, color:UIColor,bold:Bool) {
        let strNumber: NSString = fullText as NSString
        let range = (strNumber).range(of: changeText)
        let attribute = NSMutableAttributedString.init(string: fullText)
        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: color , range: range)
        if bold {
            attribute.addAttribute(NSAttributedString.Key.font, value: UIFont(name:"AmericanTypewriter-Bold",size:18)! , range: range)
        }
        
        self.attributedText = attribute
    }
}


extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
