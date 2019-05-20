//
//  AlbumsMapViewController.swift
//  imagepicker
//
//  Created by 唐茂宁 on 7/5/19.
//  Copyright © 2019 Sara Robinson. All rights reserved.
//

import GoogleMaps
import UIKit

/// Point of Interest Item which implements the GMUClusterItem protocol.
class POIItem: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var name: String!
    var datetime: String!
    var icon:UIImage
    
    init(position: CLLocationCoordinate2D, name: String,datetime:String,icon: UIImage) {
        self.position = position
        self.name = name
        self.datetime = datetime
        self.icon = icon
    }
}

let kClusterItemCount = 10000
let kCameraLatitude = -37.812946
let kCameraLongitude = 144.963658

class AlbumsMapViewController: UIViewController, GMUClusterManagerDelegate,GMSMapViewDelegate,GMUClusterRendererDelegate {


    
    private var mapView: GMSMapView!
    private var clusterManager: GMUClusterManager!
    var imageEntitys = [ImageEntity]()
    var arrFilteredData = [CLLocationCoordinate2D]()
    override func loadView() {
        let camera = GMSCameraPosition.camera(withLatitude: kCameraLatitude,
                                              longitude: kCameraLongitude, zoom: 5)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        self.view = mapView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up the cluster manager with default icon generator and renderer.
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        renderer.delegate = self
        
        // Generate and add random items to the cluster manager.
        //generateClusterItems()
        
        // Call cluster() after items have been added to perform the clustering and rendering on map.
        //clusterManager.cluster()
        setMarkerForMap(images: imageEntitys)
        clusterManager.cluster()
        // Register self to listen to both GMUClusterManagerDelegate and GMSMapViewDelegate events.
        clusterManager.setDelegate(self, mapDelegate: self)
        
    }
    
    // MARK: - GMUClusterManagerDelegate
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
                                                 zoom: mapView.camera.zoom + 1)
        let update = GMSCameraUpdate.setCamera(newCamera)
        mapView.moveCamera(update)
        return false
    }
    
    // MARK: - GMUMapViewDelegate
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if (marker.userData as? POIItem) != nil {
//            NSLog("Did tap marker for cluster item \(poiItem.name)")
            
        } else {
//            NSLog("Did tap a normal marker")
            self.mapView.selectedMarker = marker
        }
        return false
    }
    
    
    func generatePOIItems(_ accessibilityLabel: String, position: CLLocationCoordinate2D,datetime:String, icon: UIImage) {
        let item = POIItem(position: position, name: accessibilityLabel, datetime: datetime, icon: icon)
        self.clusterManager.add(item)
        
    }
    
    
    func setMarkerForMap(images: [ImageEntity]) -> Void {
        
        
        //clear all marker before load again
        var index = 0
        for location in images {
            let string = location.lat! as! String
            let marker = GMSMarker()
            let coordinate = checkIfMutlipleCoordinates(latitude: ((location.lat!.toDouble())), longitude: ((location.long!.toDouble())))
            arrFilteredData.append(coordinate)
                //CLLocationCoordinate2DMake((location.lat!.toDouble()),(location.long!.toDouble()))
            
//            //set image
//
//
//            marker.userData = location
//            marker.map = mapView
            mapView.delegate = self
            var datetime = ""
            if location.dateTime != nil{
                 datetime = location.dateTime!
            }
            self.generatePOIItems((location.isItem?.animalName)!, position: coordinate, datetime: datetime, icon: ImageWorker.loadImageData(fileName: location.imagePath!)!)
            index += 1
        }
        self.clusterManager.cluster()
    }
    
    
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        if let temp = (marker.userData as? POIItem){
            marker.snippet = temp.datetime
            marker.title = temp.name //location.isItem?.animalName
            marker.icon = temp.icon.resize(maxWidthHeight: 50)
            //marker.iconView = UIImageView(image: UIImage(named: "icons8-play_filled.png"))
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print(marker.title!)
        print(marker.snippet!)
    }
    
//    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker){
//        if let temp = (marker.userData as? POIItem){
//            marker.iconView = UIImageView(image: temp.icon)
//        }
//    }
//
    
//
//    func renderer(_ renderer: GMUClusterRenderer, will object: Any) -> GMSMarker? {
//        if let temp = (marker.userData as? POIItem){
//
//        }
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func checkIfMutlipleCoordinates(latitude : Double , longitude : Double) -> CLLocationCoordinate2D{
        
        var lat = latitude
        var lng = longitude
        
        // arrFilterData is array of model which is giving lat long
        
        let arrTemp = self.arrFilteredData.filter {
            
            return (((latitude == $0.latitude) && (longitude == $0.longitude)))
        }
        
        // arrTemp giving array of objects with similar lat long
        
        if arrTemp.count > 1{
            // Core Logic giving minor variation to similar lat long
            
            let variation = (randomFloat(min: 0.0, max: 2.0) - 0.5) / 1500
            lat = lat + variation
            lng = lng + variation
        }
        let finalPos = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lng))
        return  finalPos
    }
    
    func randomFloat(min: Double, max:Double) -> Double {
        return (Double(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }
    
    
}

extension String {
    func toDouble() -> Double {
        let nsString = self.replacingOccurrences(of: "[^\\.\\d+-]", with: "", options: [.regularExpression]) as NSString
        return nsString.doubleValue
    }
}
