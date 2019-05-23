//
//  CheckListViewController.swift
//  imagepicker
//
//  Created by 唐茂宁 on 6/5/19.
//  Copyright © 2019 Sara Robinson. All rights reserved.
//


import UIKit
import CoreData
import SwiftyJSON
import UserNotifications
import CoreLocation


/// This class is responsible for storeing the images and the loction coordinates. All the record which counting the number of witiness of an animal will be show in the form of table. The overall progress will be calculate to load a progress bar. A tittle and a badge will be loaded according to the overall progress.
class CheckListViewController: UIViewController, UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate {
    
    private var managedObjectContext: NSManagedObjectContext
    var locationManager: CLLocationManager = CLLocationManager()
    var checkLists = [CheckList]()
    var defaultList = [CheckList]()
    var userCheckLists = [CheckList]()
    var enabledList = ""
    var image: UIImage?
    var currentLocation: CLLocation?
    var sortedItems = [ListItem]()
    
    @IBOutlet weak var levelImage: UIImageView!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBAction func segementedChange(_ sender: Any) {
        tableView.reloadData()
    }
    required init?(coder aDecoder: NSCoder) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = (appDelegate?.persistentContainer.viewContext)!
        super.init(coder: aDecoder)!
        for geolocation in locationManager.monitoredRegions{
            locationManager.stopMonitoring(for: geolocation)
        }
        initAppData()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 20
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.badge, .alert, .sound]) { (granted, error) in
        }
    }
    
    /// Setup UI outlets
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        progressBar.layer.cornerRadius = 8
        progressBar.clipsToBounds = true
        progressBar.layer.sublayers![1].cornerRadius = 8
        progressBar.subviews[1].clipsToBounds = true
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        userCheckLists = checkLists.filter{ $0.customized }
        if userCheckLists.count > 0  && userCheckLists[0].fouded != nil{
            if (Int(userCheckLists[0].fouded!)! < 5){
                progressLabel.text = "\(userCheckLists[0].fouded!)/5"
                self.levelLabel.text = "Beginner"
                self.levelImage.image = UIImage(named: "beginner")
                self.progressBar.progress = Float(userCheckLists[0].fouded!)!/5
            }
            if Int(userCheckLists[0].fouded!)! >= 5 && Int(userCheckLists[0].fouded!)! < 18{
                progressLabel.text = "\(userCheckLists[0].fouded!)/18"
                self.levelLabel.text = "Intermediate"
                self.levelImage.image = UIImage(named: "inter")
                self.progressBar.progress = Float(userCheckLists[0].fouded!)!/18
            }
            if Int(userCheckLists[0].fouded!)! >= 18 && Int(userCheckLists[0].fouded!)! < 47{
                progressLabel.text = "\(userCheckLists[0].fouded!)/47"
                self.levelLabel.text = "Expert"
                self.levelImage.image = UIImage(named: "expert")
                self.progressBar.progress = Float(userCheckLists[0].fouded!)!/47
            }
            if Int(userCheckLists[0].fouded!)! >= 47{
                progressLabel.text = "\(userCheckLists[0].fouded!)/\(userCheckLists[0].fouded!)"
                 self.levelLabel.text = "Expert"
                self.levelImage.image = UIImage(named: "expert")
                self.progressBar.progress = 1.0
            }
        }else{
            progressLabel.text = "0/5"
            self.progressBar.progress = 0.0
        }
        
       
    }
    
    /// Check the current selected segment and perform segue accordingly by seleting element from correct NSArray.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)  {
        if  segue.identifier == "checkListSegue"{
            let destination = segue.destination as? CheckListItemViewController
            switch segmentedControl.selectedSegmentIndex{
            case 0:
                destination?.checkList = defaultList[tableView.indexPathForSelectedRow!.row]
            case 1:
                destination?.checkList = userCheckLists[tableView.indexPathForSelectedRow!.row]
            default:
                break
            }
        }
        if segue.identifier == "showItemOnMap"{
            let destination = segue.destination as? AlbumsMapViewController
                let item = sortedItems[tableView.indexPathForSelectedRow!.row]
                if let entities = item.hasEntities?.allObjects as? [ImageEntity]{
                    destination?.imageEntitys = entities
                }
        }
        if segue.identifier == "showAllItemOnMap"{
            let destination = segue.destination as? AlbumsMapViewController
            if let items = userCheckLists[0].hasItems?.allObjects as? [ListItem]{
                for item in items{
                    if let entities = item.hasEntities?.allObjects as? [ImageEntity]{
                        destination?.imageEntitys += entities
                    }
                }
                
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch segmentedControl.selectedSegmentIndex{
        case 0:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.21) {
                self.performSegue(withIdentifier: "checkListSegue", sender: self )
            }
        case 1: break
    
        default:
            break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentedControl.selectedSegmentIndex{
        case 0:
            defaultList = checkLists.filter{ !$0.customized }.sorted(by: { Int($0.fouded!)! > Int($1.fouded!)!})
            return defaultList.count
        case 1:
            userCheckLists = checkLists.filter{ $0.customized }
            return self.userCheckLists[0].hasItems!.count
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch segmentedControl.selectedSegmentIndex{
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CheckListTableViewCell
            if self.defaultList.count>6 {
                let checkList = self.defaultList[indexPath.row]
                cell.checkListImage.image = ImageWorker.loadImageData(fileName: checkList.imagePath!)
                cell.checkListTittleLabel.text = checkList.tittle
                cell.cheklistDetail.text = checkList.listDescription
                cell.checkListProgress.progress = Float(checkList.fouded!)!/Float(checkList.total!)!
                cell.countLabel.text = "\(checkList.fouded!)/\(checkList.total!)"
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! CheclistItemsTableViewCell
            let items = Array((self.userCheckLists[0].hasItems)!) as! [ListItem]
            self.sortedItems = items.sorted(by: { ($0.hasEntities?.count)! > ($1.hasEntities?.count)!})
            let item = sortedItems[indexPath.row]
            if item.imagePath != nil {
                cell.checkListImage.image = ImageWorker.loadImageData(fileName: item.imagePath!)
                if item.hasEntities!.count > 0 {
                    cell.numberOfImages.text = "\(item.hasEntities!.count)"
                }
            }
            cell.tittleLabel.text = item.animalName!
            return cell
        default:
            break
        }
        return UITableViewCell()
    }
    
    /// Initiate the app data for opening the app first time.
    func initAppData() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CheckList")
        do {
            let tempList = try managedObjectContext.fetch(fetchRequest) as! [CheckList]
            if tempList.count == 0 {
                insertData()
            }
            else{
                self.checkLists = tempList
                for checkList in checkLists{
                    var identifier = checkList.tittle!
                    identifier.append("\n")
                    identifier.append(UUID().uuidString)
                    let coordinate = CLLocationCoordinate2D(latitude: checkList.lat, longitude: checkList.long)
                    let geoLocation = CLCircularRegion(center: coordinate, radius: 5000, identifier: identifier)
                    geoLocation.notifyOnEntry = true
                    geoLocation.notifyOnExit = true
                    self.locationManager.startMonitoring(for: geoLocation)
                }
            }
        }
        catch{
            fatalError("Failed to fetch icon: \(error)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?,
                         withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error)")
    }
    
    /// Check and update animal record when an animal exits in the list.
    ///
    /// - Parameter animalName: <#animalName description#>
    func updateData(animalName:String){
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MMM-dd HH:mm:ss"
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        _ = date.timeIntervalSince1970
        
        if let checkList = self.checkLists.first(where: { $0.tittle == self.enabledList}){
            let fouded = Int(checkList.fouded!)
            if let items = checkList.hasItems?.allObjects as? [ListItem]{
                _ = items.first(where: { $0.animalName == animalName})?.found
                let item = items.first(where: { $0.animalName == animalName})
                item?.found = true
                let imagePath = ImageWorker.saveImage(image: self.image!, name: UUID().uuidString)
                item?.imagePath = imagePath
                let imageEntityst = NSEntityDescription.insertNewObject(forEntityName: "ImageEntity", into: managedObjectContext) as! ImageEntity
                imageEntityst.imagePath = imagePath
                if currentLocation != nil{
                    let coordinate = self.currentLocation?.coordinate
                    imageEntityst.lat = "\(coordinate?.latitude)"
                    imageEntityst.long = "\(coordinate?.longitude)"
                    imageEntityst.dateTime = dateString
                }
                item?.addToHasEntities(imageEntityst)
                if item?.hasEntities?.count == 1 {
                    checkList.fouded = String(fouded! + 1)
                }
                saveData()
                var message:NSString?
                message = "\(animalName) has been ticked in \(checkList.tittle!) checklist." as NSString
                CBToast.showToast(message: message, aLocationStr: "bottom", aShowTime: 5.0)
                self.tableView.reloadData()
            }
        }else{
            CBToast.showToast(message: "This function will only be activate when in the area of a national park that included in the checklists." as NSString, aLocationStr: "bottom", aShowTime: 5.0)
            if self.currentLocation != nil{
                self.latLong(lat: self.currentLocation!.coordinate.latitude,long: self.currentLocation!.coordinate.longitude)
            }
            
        }
        
        if let checkList = self.checkLists.first(where: { $0.tittle == "ALL"}){
            let fouded = Int(checkList.fouded!)
            if let items = checkList.hasItems?.allObjects as? [ListItem]{
                _ = items.first(where: { $0.animalName == animalName})?.found
                let item = items.first(where: { $0.animalName == animalName})
                item?.found = true
                let imagePath = ImageWorker.saveImage(image: self.image!, name: UUID().uuidString)
                item?.imagePath = imagePath
                let imageEntityst = NSEntityDescription.insertNewObject(forEntityName: "ImageEntity", into: managedObjectContext) as! ImageEntity
                imageEntityst.imagePath = imagePath
                if currentLocation != nil{
                    let coordinate = self.currentLocation?.coordinate
                    imageEntityst.lat = "\(coordinate?.latitude)"
                    imageEntityst.long = "\(coordinate?.longitude)"
                    imageEntityst.dateTime = dateString
                }
                item?.addToHasEntities(imageEntityst)
                if item?.hasEntities?.count == 1 {
                    checkList.fouded = String(fouded! + 1)
                }
                
                saveData()
                var message:NSString?
                message = "\(animalName) has been ticked in the Animals checkList." as NSString
                CBToast.showToast(message: message, aLocationStr: "bottom", aShowTime: 3.0)
                if self.tableView != nil{
                    self.tableView.reloadData()
                }
                
            }
        }
        
        if userCheckLists.count > 0 && userCheckLists[0].fouded != nil{
            if (Int(userCheckLists[0].fouded!)! < 5){
                progressLabel.text = "\(userCheckLists[0].fouded!)/5"
                self.levelLabel.text = "Beginner"
                self.levelImage.image = UIImage(named: "beginner")
                self.progressBar.progress = Float(userCheckLists[0].fouded!)!/5
            }
            if Int(userCheckLists[0].fouded!)! >= 5 && Int(userCheckLists[0].fouded!)! < 18{
                progressLabel.text = "\(userCheckLists[0].fouded!)/18"
                self.levelLabel.text = "Intermediate"
                self.levelImage.image = UIImage(named: "inter")
                self.progressBar.progress = Float(userCheckLists[0].fouded!)!/18
            }
            if Int(userCheckLists[0].fouded!)! >= 18 && Int(userCheckLists[0].fouded!)! < 47{
                progressLabel.text = "\(userCheckLists[0].fouded!)/47"
                self.levelLabel.text = "Expert"
                self.levelImage.image = UIImage(named: "expert")
                self.progressBar.progress = Float(userCheckLists[0].fouded!)!/47
            }
            if Int(userCheckLists[0].fouded!)! >= 47{
                progressLabel.text = "\(userCheckLists[0].fouded!)/\(userCheckLists[0].fouded!)"
                self.levelLabel.text = "Expert"
                self.levelImage.image = UIImage(named: "expert")
                self.progressBar.progress = 1.0
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath){
        cell.layoutIfNeeded()
    }
    
    
    
    
    /// Get address revers from latitude and longtitude
    ///
    /// - Parameters:
    ///   - lat: Double
    ///   - long: Double
    func latLong(lat: Double,long: Double){
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: lat , longitude: long)
        var address:Dictionary<String,String>?
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            address = [String:String]()
            
            if let error = error {
                print("Unable to Reverse Geocode Location (\(error))")
                print("Unable to Find Address for Location")
                
            } else {
                if let locationName = placeMark?.addressDictionary?["Name"] as? String {
                    print("Location Name :- \(locationName)")
                    address!["Name"] = locationName
                }
                if let placemarks = placemarks, let placemark = placemarks.first {
                    address!["full"] = placemark.compactAddress
                } else {
                    print("No Matching Addresses Found")
                }
            }
            }
        )
    }
    
    
   
    /// Insert 7 check list in the national park segmentation.
    /// Replace this methoid with your own API if your want to store them on the server side rather than locally.
    func insertData(){
        self.initdata(tittle: "Halls Gap", description: "If you’ve got to see a kangaroo in the wild, Hall’s Gap is your place. Located in the gorgeous Grampians mountain range, this town may have more kangaroos than people! With a human population of less than 700, Hall’s Gap and its surrounding natural areas are a hotspot for kangaroo mobs. Take a walk in the park areas or grassy fields and you just may catch a glimpse of a few roos. As a bonus, consider a hike up to The Pinnacle, a magnificent rock platform that offers one of the best elevated views in Australia.", imagePath: UIImage(named: "HallsGap.jpg")!, lat: -37.1471, lon: 142.5279, videoId: "wv8zhhF6zgg")

        self.initdata(tittle: "Great Otway National Park", description: "Let’s be honest. A trip to Australia is not complete without a koala sighting. Fortunately, these iconic marsupials are prevalent in many places throughout Victoria. You may even spot the road signs telling you to take care as they cross the road! In the Great Otway National Park along the Great Ocean Road, you’ll find one of the most dense koala populations on the planet. Look up and you may just see a koala in the branches above. Don’t expect them to notice you though. Koalas sleep up to 18 hours per day.", imagePath: UIImage(named: "GreatOtway.jpg")!, lat: -38.778201, lon: 143.511365, videoId: "LWEO0duqzgA")
        
        self.initdata(tittle: "Phillip Island", description: "Phillip Island’s penguins arrive like clockwork each night after a day of fishing. Waddling past onlookers by the dozens, the island’s famous penguin colony provides a thrilling and dependable dusk spectacle. With outdoor seating and a new underground viewing platform, the Penguin Parade is one of Australia’s most renowned experiences.  What does a seat to this magical event cost? Less than 16 GBP.  Little penguins, little price..", imagePath: UIImage(named: "Phillip Island.jpg")!, lat: -38.505346, lon: 145.147957,videoId: "EuixhVrMZNc")
        
        self.initdata(tittle: "Lake Elizabeth", description: "Head to Lake Elizabeth hidden deep in the Otways and discover its inspiring beauty with heavily timbered flanks and calm waters punctuated by the trunks of dead trees, drowned when the valley was flooded more than 50 years ago to form this \"perched lake\". The elusive platypus can be found in the waters of the lake - wake up early or head to Lake Elizabeth at dusk to catch a glimpse of these shy Australian natives.", imagePath: UIImage(named: "LakeElizabeth.jpg")!, lat: -38.510032, lon: 143.716917, videoId: "E0Lt0bgnhGg")
       
        self.initdata(tittle: "Healesville Sanctuary", description: "Echidnas are the only mammals other than the platypus that lays eggs. They’re also adorable, spiky balls of cuteness.  At the Healesville Sanctuary north of Melbourne, you can get up close with these gentle creatures. The sanctuary rehabilitates injured animals and provides shelter and health care for them to live out their days.  It’s certainly worth a visit, especially if you want to see a variety of Aussie animals in one place.", imagePath: UIImage(named: "HealesvilleSanctuary.jpg")!, lat: -37.669971, lon: 145.530885, videoId: "SlDcAJxnw74")
        
        self.initdata(tittle: "Wilsons Promontory National Park", description: "Did you know that in the late 1800s many Londoners owned pet wombats? That didn’t work out so well, as these fuzzy mammals are meant for the wild. You’ll have to come to Victoria to see them in their natural habitat and we suggest the isolated and magical Wilsons Prom for your wombat watching. The park offers the largest coastal wilderness area in Victoria, making it a favorite refuge for Aussie animals. As remote as it is beautiful, you may see more wombats than people on your trip to this famous peninsula.", imagePath: UIImage(named: "WilsonsPromontory.jpg")!, lat: -39.031195, lon: 146.325853, videoId: "Ql01RfhEuQI")
        
        self.initdata(tittle: "Tower Hill Wildlife Reserve", description: "The UK’s largest bird is the 8kg Mute Swan.  Australia’s largest bird is the 42kg emu. We like to do things big here in Oz. If you’re looking to spot one of these winged beasts, well, they’re hard to miss. But don’t look to the sky! You’ll find them roving on the ground, since they’re too heavy to fly. Where’s the best place to catch a glimpse of these massive birds? An extinct volcano on the Great Ocean Road. Tower Hill Wildlife Reserve is a refuge for a collection of free-roaming, wild Australian animals who call the crater-bound ecosystem home. Take a walk around the reserve and you may just see every land animal on this list.", imagePath: UIImage(named: "TowerHill.jpg")!, lat: -38.317875, lon: 142.360586, videoId: "mpneH3Hbd_Q")
        
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location:CLLocation = locations.last{
                self.currentLocation = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("Strted")
    }
    
    
    /// Send alarm and notifications when user enter a national park.
    ///

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let tokens = region.identifier.components(separatedBy: "\n")
        let name = tokens[0]
        self.createLocalNotification(message: "Welcome to the \(name), start your journey of exploring wildlife", identifier: "EnteredRegionNotification")
        self.createAlert(name: name)
        self.enabledList = name
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        self.enabledList = ""
    }
    
    func createLocalNotification(message: String, identifier: String) {
        //Create a local notification
        let content = UNMutableNotificationContent()
        content.body = message
        content.sound = UNNotificationSound.default
        
        // Deliver the notification
        let request = UNNotificationRequest.init(identifier: identifier, content: content, trigger: nil)
        
        // Schedule the notification
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
        }
    }
    
    func createAlert(name: String) {
        if self.presentedViewController == nil {
            let message = "Welcome to:\n " + name
            let alert = UIAlertController(title: "Start your journey!", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .`default`, handler: nil))
            self.present(alert,animated:true, completion: nil)
        } else {
            let thePresentedView : UIViewController? = self.presentedViewController as UIViewController?
            if thePresentedView != nil {
                if let thePresentedVCAsAlert : UIAlertController = thePresentedView as? UIAlertController {
                    var newMessage:String = thePresentedVCAsAlert.message!
                    newMessage.append("\n")
                    newMessage.append(name)
                    thePresentedVCAsAlert.message = newMessage
                }
            }
        }
    }
    
    
    func saveData() {
        
        do {
            try managedObjectContext.save()
        }
        catch let error {
            print("Could not save Core Data: \(error)")
        }
    }
    
    
    func  initdata(tittle:String,description:String,imagePath:UIImage,lat:Double,lon:Double,videoId:String) {
        let checkList = NSEntityDescription.insertNewObject(forEntityName: "CheckList", into: managedObjectContext) as! CheckList
        checkList.videoLink = videoId
        checkList.tittle = tittle
        checkList.listDescription = description
        checkList.lat = lat
        checkList.long = lon
        checkList.customized = false
        checkList.imagePath = ImageWorker.saveImage(image: imagePath, name: UUID().uuidString)
        let translator = APIWoker()
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let geoLocation = CLCircularRegion(center: coordinate, radius: 5000, identifier: tittle)
        geoLocation.notifyOnEntry = true
        geoLocation.notifyOnExit = true
        self.locationManager.startMonitoring(for: geoLocation)
        translator.sendRequestToServer(methodId: 6,request: ["lat":lat,"lon":lon]){ (result) in
            DispatchQueue.global().async {
                if result != nil{
                    if let list = result!["response"] as? String{
                        if let data = list.data(using: .utf8) {
                            if let json = try? JSON(data: data) {
                                for name in json.arrayValue {
                                    let item = NSEntityDescription.insertNewObject(forEntityName: "ListItem", into: self.managedObjectContext) as! ListItem
                                    item.animalName = name.stringValue
                                    item.unique = false
                                    item.found = false
                                    checkList.addToHasItems(item)
                                }
                                checkList.total = String(checkList.hasItems!.count)
                                checkList.fouded = "0"
                                
                                print(checkList)
                                DispatchQueue.main.async {
                                    self.checkLists.append(checkList)
                                    if self.checkLists.count == 7{
                                        self.saveData()
                                        self.newList(tittle:"ALL")
                                      // self.tableView.reloadData()
                                    }
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func  newList(tittle:String) {
        let checkList = NSEntityDescription.insertNewObject(forEntityName: "CheckList", into: managedObjectContext) as! CheckList
        checkList.tittle = tittle
        checkList.listDescription = description
        checkList.customized = true
        let translator = APIWoker()
        translator.sendRequestToServer(methodId: 3,request: ["lat":"asf","lon":"sdafsadf"]){ (result) in
            DispatchQueue.global().async {
                if result != nil{
                    if let list = result!["response"] as? String{
                        if let data = list.data(using: .utf8) {
                            if let json = try? JSON(data: data) {
                                print(json)
                                for animal in json.arrayValue {
                                    let item = NSEntityDescription.insertNewObject(forEntityName: "ListItem", into: self.managedObjectContext) as! ListItem
                                    item.animalName = animal["name"].stringValue
                                    item.unique = false
                                    item.found = false
                                    checkList.addToHasItems(item)
                                }
                                checkList.total = String(checkList.hasItems!.count)
                                checkList.fouded = "0"
                                print(checkList)
                                DispatchQueue.main.async {
                                    self.checkLists.append(checkList)
                                    self.saveData()
                                    //self.tableView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
}

extension CLPlacemark {
    var compactAddress: String? {
        if let name = name {
            var result = name
            if let city = locality {
                result += ", \(city)"
            }
            if let zip = postalCode{
                result += " \(zip)"
            }
            if let state = self.administrativeArea{
                result += ", \(state)"
            }
            if let country = country {
                result += ", \(country)"
            }
            return result
        }
        return nil
    }
    
}


