//
//  SlidingUpViewController.swift
//  imagepicker
//
//  Created by 唐茂宁 on 11/5/19.
//  Copyright © 2019 Sara Robinson. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation
import GooglePlaces
import GoogleMaps
import SwiftyJSON


/// This class is for add a sliding up panel which includes all the detail of an animal. The idetifier of the corresponding UIViewController is "SUSlidingUp".
class SUSlidingUpVC: UIViewController, TSSlidingUpPanelDraggingDelegate,TSSlidingUpPanelAnimationDelegate,GMSMapViewDelegate {
    
    /// This inner class can be used to setup your server trustpolicy, in case your are using a server with out enterprise certificate.
    open class MyServerTrustPolicyManager: ServerTrustPolicyManager{
        open override func serverTrustPolicy(forHost host: String) -> ServerTrustPolicy? {
            return ServerTrustPolicy.disableEvaluation
        }
    }
    
    /// Setup the trust ip address here.
    let sessaionManager = SessionManager(delegate: SessionDelegate(), serverTrustPolicyManager:MyServerTrustPolicyManager(policies:["https://118.139.67.137:8443":.disableEvaluation]))
    
    @IBOutlet weak var weatherConView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var idealWind: UILabel!
    @IBOutlet weak var idealHumid: UILabel!
    @IBOutlet weak var idealTemp: UILabel!
    @IBOutlet weak var posibilityLabel: UILabel!
    @IBOutlet weak var animalImgaeView: UIImageView!
    @IBOutlet weak var tittleLabel: UILabel!
    @IBOutlet weak var descriptionTextBox: UITextView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playIcon: UIImageView!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var humidtyLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var humidtyImageView: UIImageView!
    @IBOutlet weak var humidityView: UIView!
    @IBOutlet weak var windImageView: UIImageView!
    @IBOutlet weak var windView: UIView!
    @IBOutlet weak var tempView: UIView!
    @IBOutlet weak var tempImageView: UIImageView!
    @IBOutlet var cardView: UIView!
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var toggleSlidingUpPanelBtn: UIButton!
    let slidingUpManager: TSSlidingUpPanelManager = TSSlidingUpPanelManager.with
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 5.0
    var animalName = ""
    var dispalyedName = ""
    var player: AVPlayer?
    var audioPlayer:AVAudioPlayer!
    private var heatmapLayer: GMUHeatmapTileLayer!
    private var gradientColors = [UIColor.blue, UIColor.red]
    private var gradientStartPoints = [0.2, 1.0] as [NSNumber]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up UI outlets
        self.weatherConView.layer.masksToBounds = false
        self.weatherConView.layer.shadowColor = UIColor.black.withAlphaComponent(0.6).cgColor
        self.weatherConView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.weatherConView.layer.shadowOpacity = 0.9
        humidityView.layer.cornerRadius = 8
        windView.layer.cornerRadius = 8
        tempView.layer.cornerRadius = 8
        humidityView.layer.masksToBounds = true
        windView.layer.masksToBounds = true
        tempView.layer.masksToBounds = true
        cardView.roundCornersWithLayerMask(cornerRadii: 8, corners: [.topLeft,.topRight])
        slidingUpManager.slidingUpPanelDraggingDelegate = self
        slidingUpManager.slidingUpPanelAnimationDelegate = self
        self.playButton.isHidden = true
        self.playIcon.isHidden = true
        self.playButton.layer.cornerRadius = 5
        self.playButton.clipsToBounds = true
        placesClient = GMSPlacesClient.shared()
        self.activityIndicator.isHidden = false
        self.activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        self.activityIndicator.color = UIColor.black
        self.activityIndicator.startAnimating()
        let camera = GMSCameraPosition.camera(withLatitude: -37.812946, longitude: 144.963658, zoom: 5.0)
        mapView = GMSMapView.map(withFrame: emptyView.bounds, camera: camera)
        mapView.delegate = self
        mapView.settings.myLocationButton = true
        mapView.settings.zoomGestures = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
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
        
    }
    
    /// Update the heatmap according to the result get from server.
    ///
    /// - Parameter result: JSON formate response
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
        _ = [GMUWeightedLatLng]()
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
    
    
    /// Play sonund when play button clicked
    ///
    /// - Parameter sender: viewController
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
    
    
    
    /// Change the state of sliding up panel according to panel's current state(close to open)
    ///
    /// - Parameter sender: self
    @IBAction func toggleSlidingUpPanelBtnPressed(_ sender: Any) {
        if audioPlayer.isPlaying {
            self.audioPlayer.stop()
            self.audioPlayer.currentTime = 0
            self.playIcon.isHighlighted = false
        }
        if slidingUpManager.getSlideUpPanelState() == .DOCKED {
            slidingUpManager.changeSlideUpPanelStateTo(toState: .OPENED)
            updateView()
        } else {
            slidingUpManager.changeSlideUpPanelStateTo(toState: .DOCKED)
        }
    }
    
    /// Defin actions when panel is start dragging actions.
    ///
    /// - Parameter startYPos: the original Y position of the panel
    func slidingUpPanelStartDragging(startYPos: CGFloat) {
        updateView()
    }
    
    func slidingUpPanelDraggingFinished(delta: CGFloat) {
        
    }
    
    /// Rotating the button acordding to panel's y position.
    ///
    /// - Parameter yPos: the original Y position of the panel
    func slidingUpPanelDraggingVertically(yPos: CGFloat) {
        let dismissBtnRotationDegree = slidingUpManager.scaleNumber(oldValue: yPos, newMin: 0, newMax: CGFloat(Double.pi))
        
        toggleSlidingUpPanelBtn.transform = CGAffineTransform(rotationAngle: dismissBtnRotationDegree)
    }
    
    /// Change the state of sliding up panel according to panel's current state(close to open)
    ///
    /// - Parameter sender: self
    func slidingUpPanelAnimationStart(withDuration: TimeInterval, slidingUpCurrentPanelState: SLIDE_UP_PANEL_STATE, yPos: CGFloat) {
        
        var rotationAngle: CGFloat = 0.0
        print("[SUSlidingUpVC::animationStart] sliding Up Panel state=\(slidingUpCurrentPanelState) yPos=\(yPos)")
        
        switch slidingUpCurrentPanelState {
            
        case .OPENED:
            rotationAngle = CGFloat(Double.pi)
            break
        case .DOCKED:
            rotationAngle = 0.0
            break
        case .CLOSED:
            rotationAngle = CGFloat(Double.pi)
            break;
        }
        
        UIView.animate(withDuration: withDuration, animations: {
            self.toggleSlidingUpPanelBtn.transform = CGAffineTransform(rotationAngle: rotationAngle)
        })
        
    }
    
    /// Change the state of sliding up panel according to panel's current state(close to open)
    ///
    /// - Parameter sender: self
    func slidingUpPanelAnimationFinished(withDuration: TimeInterval, slidingUpCurrentPanelState: SLIDE_UP_PANEL_STATE, yPos: CGFloat) {
        print("[SUSlidingUpVC::animationFinished] sliding Up Panel state=\(slidingUpCurrentPanelState) yPos=\(yPos)")
        
    }
    
    
    /// Call this method to up date the panel after seleted animal is changed
    func updateView(){
        if dispalyedName != animalName{
            dispalyedName = animalName
            self.playButton.isHidden = true
            self.playIcon.isHidden = true
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            self.animalImgaeView.image = nil
            self.descriptionTextBox.text = "Loading..."
            let camera = GMSCameraPosition.camera(withLatitude: -37.812946, longitude: 144.963658, zoom: 6.0)
            mapView.animate(to: camera)
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
            }}
    }
    
}

extension UIView {
    /// Define corner radius according to the corner position.
    ///
    /// - Parameters:
    ///   - cornerRadii: CGFloat
    ///   - corners: UIRectCorner
    func roundCornersWithLayerMask(cornerRadii: CGFloat, corners: UIRectCorner) {
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: cornerRadii, height: cornerRadii))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }
}
