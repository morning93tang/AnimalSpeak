//
//  CheckListTableViewController.swift
//  imagepicker
//
//  Created by 唐茂宁 on 19/4/19.
//  Copyright © 2019 Sara Robinson. All rights reserved.
//

import UIKit
import CoreData
import SwiftyJSON
import UserNotifications
import CoreLocation


class CheckListTableViewController: UITableViewController,CLLocationManagerDelegate {

    private var managedObjectContext: NSManagedObjectContext
    var locationManager: CLLocationManager = CLLocationManager()
    var checkLists = [CheckList]()
    var enabledList = ""
    var image: UIImage?
    var currentLocation: CLLocation?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)  {
        if  segue.identifier == "checkListSegue"{
            let destination = segue.destination as? CheckListItemViewController
            destination?.checkList = checkLists[tableView.indexPathForSelectedRow!.row]
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.21) {
            self.performSegue(withIdentifier: "checkListSegue", sender: self )
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CheckListTableViewCell
        
        if self.checkLists.count>6 {
            let checkList = self.checkLists[indexPath.row]
            cell.checkListImage.image = ImageWorker.loadImageData(fileName: checkList.imagePath!)
            cell.checkListTittleLabel.text = checkList.tittle
            cell.cheklistDetail.text = checkList.listDescription
            cell.checkListProgress.progress = Float(checkList.fouded!)!/Float(checkList.total!)!
            cell.countLabel.text = "\(checkList.fouded!)/\(checkList.total!)"
        }
        return cell
    }
    
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
    
    func updateData(animalName:String){
//        var checkList = CheckList()
//        var index = 0
//        if let checkList = self.checkLists.first(where: { $0.tittle == self.enabledList}){
//            index = self.checkLists.index(of:checkList)!
//        }
        
        if let checkList = self.checkLists.first(where: { $0.tittle == self.enabledList}){
            let fouded = Int(checkList.fouded!)
            if let items = checkList.hasItems?.allObjects as? [ListItem]{
                let needUpdate = items.first(where: { $0.animalName == animalName})?.found
                if !needUpdate!{
                    items.first(where: { $0.animalName == animalName})?.found = true
                    items.first(where: { $0.animalName == animalName})?.imagePath = ImageWorker.saveImage(image: self.image!, name: UUID().uuidString)
                    checkList.fouded = String(fouded! + 1)
                    saveData()
                    var message:NSString?
                    message = "\(animalName) has been ticked in \(checkList.tittle!) checkList." as NSString
                    CBToast.showToast(message: message, aLocationStr: "bottom", aShowTime: 3.0)
                    self.tableView.reloadData()
                }
            }
            
//            let indexPath = IndexPath(row:index, section: 0)
//            tableView.reloadRows(at: [indexPath], with: .top)
        }else{
//            CBToast.showToast(message: "This function will only be activate when in the area of a national park that included in the checklists." as NSString, aLocationStr: "bottom", aShowTime: 5.0)
//            if self.currentLocation != nil{
//                self.latLong(lat: self.currentLocation!.coordinate.latitude,long: self.currentLocation!.coordinate.longitude)
//            }
            
        }
        
    
//        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ListItem")
//        fetchRequest.predicate = NSPredicate(format: "belongsToCheckList.tittle = %@", self.enabledList)
//        do {
//            let tempList = try managedObjectContext.fetch(fetchRequest) as! [ListItem]
//
//            if tempList.count != 0 {
//                var managedObject = tempList[0]
//                managedObject.setValue(true, forKey: "found")
//                saveData()
//            }
//        }
//        catch{
//            fatalError("Failed to fetch icon: \(error)")
//        }
//        self.checkLists.first(where: { $0.tittle == self.enabledList})?.hasItems. = value
    }
    
    

    
    func latLong(lat: Double,long: Double)  {
        
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: lat , longitude: long)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            print("Response GeoLocation : \(placemarks)")
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            // Country
            if let country = placeMark.addressDictionary!["Country"] as? String {
                print("Country :- \(country)")
                // City
                if let city = placeMark.addressDictionary!["City"] as? String {
                    print("City :- \(city)")
                    // State
                    if let state = placeMark.addressDictionary!["State"] as? String{
                        print("State :- \(state)")
                        // Street
                        if let street = placeMark.addressDictionary!["Street"] as? String{
                            print("Street :- \(street)")
                            let str = street
                            let streetNumber = str.components(
                                separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
                            print("streetNumber :- \(streetNumber)" as Any)
                            
                            // ZIP
                            if let zip = placeMark.addressDictionary!["ZIP"] as? String{
                                print("ZIP :- \(zip)")
                                // Location name
                                if let locationName = placeMark?.addressDictionary?["Name"] as? String {
                                    print("Location Name :- \(locationName)")
                                    // Street address
                                    if let thoroughfare = placeMark?.addressDictionary!["Thoroughfare"] as? NSString {
                                        print("Thoroughfare :- \(thoroughfare)")
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    
    /// Creat 5 default animals and animal iocns when application is run at the first time.
    func insertData(){
        self.initdata(tittle: "Halls Gap", description: "If you’ve got to see a kangaroo in the wild, Hall’s Gap is your place. Located in the gorgeous Grampians mountain range, this town may have more kangaroos than people! With a human population of less than 700, Hall’s Gap and its surrounding natural areas are a hotspot for kangaroo mobs. Take a walk in the park areas or grassy fields and you just may catch a glimpse of a few roos. As a bonus, consider a hike up to The Pinnacle, a magnificent rock platform that offers one of the best elevated views in Australia.", imagePath: "HallsGap.jpg", lat: -37.1471, lon: 142.5279, videoId: "wv8zhhF6zgg")
//        let checkList1 = NSEntityDescription.insertNewObject(forEntityName: "CheckList", into: managedObjectContext) as! CheckList
//        checkList1.tittle = "Halls Gap"
//        checkList1.listDescription = "If you’ve got to see a kangaroo in the wild, Hall’s Gap is your place. Located in the gorgeous Grampians mountain range, this town may have more kangaroos than people! With a human population of less than 700, Hall’s Gap and its surrounding natural areas are a hotspot for kangaroo mobs. Take a walk in the park areas or grassy fields and you just may catch a glimpse of a few roos. As a bonus, consider a hike up to The Pinnacle, a magnificent rock platform that offers one of the best elevated views in Australia."
//        checkList1.lat = -37.1471
//        checkList1.long = 142.5279
//        checkList1.imagePath = ImageWorker.saveImage(image: UIImage(named: "HallsGap.jpg")!, name: UUID().uuidString)
//        let translator = ROGoogleTranslate()
//        translator.sendRequestToServer(methodId: 6,request: ["lat":checkList1.lat,"lon":checkList1.long]){ (result) in
//            DispatchQueue.global().async {
//                if result != nil{
//                    print(result)
//                    if let list = result!["response"] as? String{
//                        if let data = list.data(using: .utf8) {
//                            if let json = try? JSON(data: data) {
//
//                                for name in json.arrayValue {
//                                    let item = NSEntityDescription.insertNewObject(forEntityName: "ListItem", into: self.managedObjectContext) as! ListItem
//                                    item.animalName = name.stringValue
//                                    item.unique = false
//                                    checkList1.addToHasItems(item)
//                                }
//                                checkList1.total = String(checkList1.hasItems!.count)
//                                checkList1.fouded = "0"
//                                self.checkLists.append(checkList1)
//                                print("Done Done")
//                            }
//                        }
//                    }
//                }
//            }
//        }
        self.initdata(tittle: "Great Otway National Park", description: "Let’s be honest. A trip to Australia is not complete without a koala sighting. Fortunately, these iconic marsupials are prevalent in many places throughout Victoria. You may even spot the road signs telling you to take care as they cross the road! In the Great Otway National Park along the Great Ocean Road, you’ll find one of the most dense koala populations on the planet. Look up and you may just see a koala in the branches above. Don’t expect them to notice you though. Koalas sleep up to 18 hours per day.", imagePath: "GreatOtway.jpg", lat: -38.778201, lon: 143.511365, videoId: "LWEO0duqzgA")
//        let checkList2 = NSEntityDescription.insertNewObject(forEntityName: "CheckList", into: managedObjectContext) as! CheckList
//        checkList2.tittle = "Cape Otway"
//        checkList2.listDescription = "Let’s be honest. A trip to Australia is not complete without a koala sighting. Fortunately, these iconic marsupials are prevalent in many places throughout Victoria. You may even spot the road signs telling you to take care as they cross the road! In the Great Otway National Park along the Great Ocean Road, you’ll find one of the most dense koala populations on the planet. Look up and you may just see a koala in the branches above. Don’t expect them to notice you though. Koalas sleep up to 18 hours per day."
//        checkList2.lat = -38.778201
//        checkList2.long = 143.511365
//        checkList2.imagePath = ImageWorker.saveImage(image: UIImage(named: "GreatOtway.jpg")!, name: UUID().uuidString)
//        translator.sendRequestToServer(methodId: 6,request: ["lat":checkList2.lat,"lon":checkList2.long]){ (result) in
//            DispatchQueue.global().async {
//                if result != nil{
//                    print(result)
//                    if let list = result!["response"] as? String{
//                        if let data = list.data(using: .utf8) {
//                            if let json = try? JSON(data: data) {
//
//                                for name in json.arrayValue {
//                                    let item = NSEntityDescription.insertNewObject(forEntityName: "ListItem", into: self.managedObjectContext) as! ListItem
//                                    item.animalName = name.stringValue
//                                    item.unique = false
//                                    checkList2.addToHasItems(item)
//                                }
//                                checkList2.total = String(checkList1.hasItems!.count)
//                                checkList2.fouded = "0"
//                                self.checkLists.append(checkList1)
//                                print("Done Done")
//                            }
//                        }
//                    }
//                }
//            }
//        }
        self.initdata(tittle: "Phillip Island", description: "Phillip Island’s penguins arrive like clockwork each night after a day of fishing. Waddling past onlookers by the dozens, the island’s famous penguin colony provides a thrilling and dependable dusk spectacle. With outdoor seating and a new underground viewing platform, the Penguin Parade is one of Australia’s most renowned experiences.  What does a seat to this magical event cost? Less than 16 GBP.  Little penguins, little price..", imagePath: "Phillip Island.jpg", lat: -38.505346, lon: 145.147957,videoId: "EuixhVrMZNc")
//        checkList = NSEntityDescription.insertNewObject(forEntityName: "CheckList", into: managedObjectContext) as! CheckList
//        checkList.tittle = "Phillip Island"
//        checkList.listDescription = "Phillip Island’s penguins arrive like clockwork each night after a day of fishing. Waddling past onlookers by the dozens, the island’s famous penguin colony provides a thrilling and dependable dusk spectacle. With outdoor seating and a new underground viewing platform, the Penguin Parade is one of Australia’s most renowned experiences.  What does a seat to this magical event cost? Less than 16 GBP.  Little penguins, little price.."
//        checkList.lat = -38.505346
//        checkList.long = 145.147957
//        checkList.imagePath = ImageWorker.saveImage(image: UIImage(named: "Phillip Island.jpg")!, name: UUID().uuidString)
//
//        item = NSEntityDescription.insertNewObject(forEntityName: "ListItem", into: managedObjectContext) as! ListItem
//        item.animalName = "Sheep"
//        item.unique = false
//        checkList.addToHasItems(item)
//        checkList.total = String(checkList.hasItems!.count)
//        checkList.fouded = "0"
//        self.checkLists.append(checkList)
        self.initdata(tittle: "Lake Elizabeth", description: "Head to Lake Elizabeth hidden deep in the Otways and discover its inspiring beauty with heavily timbered flanks and calm waters punctuated by the trunks of dead trees, drowned when the valley was flooded more than 50 years ago to form this \"perched lake\". The elusive platypus can be found in the waters of the lake - wake up early or head to Lake Elizabeth at dusk to catch a glimpse of these shy Australian natives.", imagePath: "LakeElizabeth.jpg", lat: -38.510032, lon: 143.716917, videoId: "E0Lt0bgnhGg")
//        checkList = NSEntityDescription.insertNewObject(forEntityName: "CheckList", into: managedObjectContext) as! CheckList
//        checkList.tittle = "Lake Elizabeth"
//        checkList.listDescription = "Head to Lake Elizabeth hidden deep in the Otways and discover its inspiring beauty with heavily timbered flanks and calm waters punctuated by the trunks of dead trees, drowned when the valley was flooded more than 50 years ago to form this \"perched lake\". The elusive platypus can be found in the waters of the lake - wake up early or head to Lake Elizabeth at dusk to catch a glimpse of these shy Australian natives."
//        checkList.lat = -38.510032
//        checkList.long = 143.716917
//        checkList.imagePath = ImageWorker.saveImage(image: UIImage(named: "LakeElizabeth.jpg")!, name: UUID().uuidString)
//
//        item = NSEntityDescription.insertNewObject(forEntityName: "ListItem", into: managedObjectContext) as! ListItem
//        item.animalName = "Sheep"
//        item.unique = false
//        checkList.addToHasItems(item)
//        checkList.total = String(checkList.hasItems!.count)
//        checkList.fouded = "0"
//        self.checkLists.append(checkList)
        self.initdata(tittle: "Healesville Sanctuary", description: "Echidnas are the only mammals other than the platypus that lays eggs. They’re also adorable, spiky balls of cuteness.  At the Healesville Sanctuary north of Melbourne, you can get up close with these gentle creatures. The sanctuary rehabilitates injured animals and provides shelter and health care for them to live out their days.  It’s certainly worth a visit, especially if you want to see a variety of Aussie animals in one place.", imagePath: "HealesvilleSanctuary.jpg", lat: -37.669971, lon: 145.530885, videoId: "SlDcAJxnw74")
//        checkList = NSEntityDescription.insertNewObject(forEntityName: "CheckList", into: managedObjectContext) as! CheckList
//        checkList.tittle = "Healesville Sanctuary"
//        checkList.listDescription = "Echidnas are the only mammals other than the platypus that lays eggs. They’re also adorable, spiky balls of cuteness.  At the Healesville Sanctuary north of Melbourne, you can get up close with these gentle creatures. The sanctuary rehabilitates injured animals and provides shelter and health care for them to live out their days.  It’s certainly worth a visit, especially if you want to see a variety of Aussie animals in one place. "
//        checkList.lat = -37.669971
//        checkList.long = 145.530885
//        checkList.imagePath = ImageWorker.saveImage(image: UIImage(named: "HealesvilleSanctuary.jpg")!, name: UUID().uuidString)
//
//        item = NSEntityDescription.insertNewObject(forEntityName: "ListItem", into: managedObjectContext) as! ListItem
//        item.animalName = "Sheep"
//        item.unique = false
//        checkList.addToHasItems(item)
//        checkList.total = String(checkList.hasItems!.count)
//        checkList.fouded = "0"
//        self.checkLists.append(checkList)
        self.initdata(tittle: "Wilsons Promontory National Park", description: "Did you know that in the late 1800s many Londoners owned pet wombats? That didn’t work out so well, as these fuzzy mammals are meant for the wild. You’ll have to come to Victoria to see them in their natural habitat and we suggest the isolated and magical Wilsons Prom for your wombat watching. The park offers the largest coastal wilderness area in Victoria, making it a favorite refuge for Aussie animals. As remote as it is beautiful, you may see more wombats than people on your trip to this famous peninsula.", imagePath: "WilsonsPromontory.jpg", lat: -39.031195, lon: 146.325853, videoId: "Ql01RfhEuQI")
//        checkList = NSEntityDescription.insertNewObject(forEntityName: "CheckList", into: managedObjectContext) as! CheckList
//        checkList.tittle = "Wilsons Promontory National Park"
//        checkList.listDescription = "Did you know that in the late 1800s many Londoners owned pet wombats? That didn’t work out so well, as these fuzzy mammals are meant for the wild. You’ll have to come to Victoria to see them in their natural habitat and we suggest the isolated and magical Wilsons Prom for your wombat watching. The park offers the largest coastal wilderness area in Victoria, making it a favorite refuge for Aussie animals. As remote as it is beautiful, you may see more wombats than people on your trip to this famous peninsula."
//        checkList.lat = -39.031195
//        checkList.long = 146.325853
//        checkList.imagePath = ImageWorker.saveImage(image: UIImage(named: "WilsonsPromontory.jpg")!, name: UUID().uuidString)
//
//        item = NSEntityDescription.insertNewObject(forEntityName: "ListItem", into: managedObjectContext) as! ListItem
//        item.animalName = "Sheep"
//        item.unique = false
//        checkList.addToHasItems(item)
//        checkList.total = String(checkList.hasItems!.count)
//        checkList.fouded = "0"
//        self.checkLists.append(checkList)
        self.initdata(tittle: "Tower Hill Wildlife Reserve", description: "The UK’s largest bird is the 8kg Mute Swan.  Australia’s largest bird is the 42kg emu. We like to do things big here in Oz. If you’re looking to spot one of these winged beasts, well, they’re hard to miss. But don’t look to the sky! You’ll find them roving on the ground, since they’re too heavy to fly. Where’s the best place to catch a glimpse of these massive birds? An extinct volcano on the Great Ocean Road. Tower Hill Wildlife Reserve is a refuge for a collection of free-roaming, wild Australian animals who call the crater-bound ecosystem home. Take a walk around the reserve and you may just see every land animal on this list.", imagePath: "TowerHill.jpg", lat: -38.317875, lon: 142.360586, videoId: "mpneH3Hbd_Q")
//        checkList = NSEntityDescription.insertNewObject(forEntityName: "CheckList", into: managedObjectContext) as! CheckList
//        checkList.tittle = "Tower Hill Wildlife Reserve"
//        checkList.listDescription = "The UK’s largest bird is the 8kg Mute Swan.  Australia’s largest bird is the 42kg emu. We like to do things big here in Oz. If you’re looking to spot one of these winged beasts, well, they’re hard to miss. But don’t look to the sky! You’ll find them roving on the ground, since they’re too heavy to fly. Where’s the best place to catch a glimpse of these massive birds? An extinct volcano on the Great Ocean Road. Tower Hill Wildlife Reserve is a refuge for a collection of free-roaming, wild Australian animals who call the crater-bound ecosystem home. Take a walk around the reserve and you may just see every land animal on this list."
//        checkList.lat = -38.317875
//        checkList.long = 142.360586
//        checkList.imagePath = ImageWorker.saveImage(image: UIImage(named: "TowerHill.jpg")!, name: UUID().uuidString)
        
//        item = NSEntityDescription.insertNewObject(forEntityName: "ListItem", into: managedObjectContext) as! ListItem
//        item.animalName = "Sheep"
//        item.unique = false
//        checkList.addToHasItems(item)
//        checkList.total = String(checkList.hasItems!.count)
//        checkList.fouded = "0"
//        self.checkLists.append(checkList)
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location:CLLocation = locations.last{
                self.currentLocation = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("Strted")
    }
        
    
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
    
    
    func  initdata(tittle:String,description:String,imagePath:String,lat:Double,lon:Double,videoId:String) {
        let checkList = NSEntityDescription.insertNewObject(forEntityName: "CheckList", into: managedObjectContext) as! CheckList
        checkList.videoLink = videoId
        checkList.tittle = tittle
        checkList.listDescription = description
        checkList.lat = lat
        checkList.long = lon
        checkList.imagePath = ImageWorker.saveImage(image: UIImage(named: imagePath)!, name: UUID().uuidString)
        let translator = ROGoogleTranslate()
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
                                        self.tableView.reloadData()
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
