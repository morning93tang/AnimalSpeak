// Copyright 2016 Baidu Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit
import SwiftyJSON
import Alamofire
import AVFoundation
import AlamofireImage
import Photos

/// Cofirm with this delegate to get image recognition result.
protocol ResultDetailDelegate {
    func gerResultData(detailResut: [DetailResult]) }

/// This ViewController is connnect to imagePicerView which can be presented as a pop up view. This view allow user to upload image from local photo library or camera. After user upload an image, it will be resize and send to image recgition API. Finally the result will be converted from JSON format to DetailResult() stucture.
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITabBarControllerDelegate {
    let imagePicker = UIImagePickerController()
    let session = URLSession.shared
    //    var detailResut = DetailResult()
    var detailResuts = [DetailResult]()
    var delegate:ResultDetailDelegate?
    var imageString:String?
    private var canceled: Bool
    @IBOutlet weak var labelResults: UILabel!
    @IBOutlet weak var popUpView: UIView!
    
    @IBOutlet weak var animalImage: UIImageView!
    
    @IBOutlet weak var cancleButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    @IBAction func startButton(_ sender: Any) {
        self.camara()
        self.uploadButton.isEnabled = false
    }
    
    @IBOutlet weak var activityIndecater: UIActivityIndicatorView!
    
    
    
    var fastDict = ["蓝舌蜥":"Blotched Blue-tongued Lizard","澳洲鹤":"Brolga","八哥":"Common Myna","树蛇":"Common Tree Snake","南美珊瑚蛇":"Coral Snake","蟒蛇":"Diamond Python","韩国杜莎犬":"Dingo","鼩鼱":"Dusky Antechinus","袋鼠":"Eastern Grey Kangaroo","袋貂":"Eastern Quoll","鸸鹋":"Emu","米切氏凤头鹦鹉":"Galah","北方狭口蛙":"Giant Burrowing Frog","兔耳袋狸":"Greater Bilby","狐蝠":"Grey-headed Flying-fox","树袋熊":"Koala","巨蜥":"Lace Monitor","小蓝企鹅":"Little Penguin","睡鼠":"Little_Pygmy-possum","野鸭":"Mallard","壁虎":"Marbled Gecko","小袋鼠":"Parma Wallaby","鸭嘴兽":"Platypus","短尾矮袋鼠":"Quokka","红袋鼠":"Red Kangaroo","葵花凤头鹦鹉":"Sulphur-crested Cockatoo","袋獾":"Tasmanian Devil","夜鹰":"Tawny Frogmouth","澳洲魔蜥":"Thorny Devil","虎蛇":"Tiger Snake","White's Skink":"石龙子"]
    
    var baiduAiURL: URL {
        return URL(string: "https://aip.baidubce.com/rest/2.0/image-classify/v1/animal?access_token=24.d6928c257251cd4f6209e34b039cfcb8.2592000.1559435618.282335-15897168")!
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.canceled = false
        super.init(coder: aDecoder)!
    }
    
    
    @IBAction func testbutton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        self.canceled = true
        dismiss(animated: true, completion: nil)
    }
    
    /// Pick image in photo library
    func pickAnImage(){
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    /// Show alarm
    ///
    /// - Parameters:
    ///   - title: title description
    ///   - message: message description
    func displayMessage(_ title: String,_ message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// Use carmara to take a picture
    func camara(){
        let alertController = UIAlertController(title: nil, message: "Upload a photo.", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.uploadButton.isEnabled = true
        }
        alertController.addAction(cancelAction)
        
        
        let uploadPhotoAction = UIAlertAction(title: "Take a photo", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                switch AVCaptureDevice.authorizationStatus(for: .video) {
                case .authorized: // The user has previously granted access to the camera.
                    self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
                    self.imagePicker.allowsEditing = false
                    self.imagePicker.delegate = self
                    self.present(self.imagePicker, animated: true, completion: nil)
                case .denied: // The user has previously denied access.
                    self.displayMessage("Not able to access your camera","Please check your permission settings")
                case .restricted: // The user can't grant access due to restrictions.
                    self.displayMessage("Not able to access your camera","Please check your permission settings")
                case .notDetermined:
                    // The user has not yet been asked for camera access.
                    AVCaptureDevice.requestAccess(for: .video) { granted in
                        if granted {
                            self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
                            self.imagePicker.allowsEditing = false
                            self.imagePicker.delegate = self
                            self.present(self.imagePicker, animated: true, completion: nil)
                        }
                    }
                }
            }
            else {
                self.pickAnImage()
            }
        }
        alertController.addAction(uploadPhotoAction)
        
        let TakePhotoAction = UIAlertAction(title: "Select a photo", style: .default) { (action) in
            self.pickAnImage()
        }
        alertController.addAction(TakePhotoAction)
        present(alertController, animated: true)
        
        
    }
    
    /// Initialize the view
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
        imagePicker.delegate = self
        self.labelResults.text = "Please upload an animal photo and we will tell you what it is."
        self.popUpView.layer.cornerRadius = 10
        self.popUpView.layer.masksToBounds = true
        self.animalImage.contentMode = .scaleAspectFill
        self.cancleButton.layer.cornerRadius = 8
        self.uploadButton.layer.cornerRadius = 8
        ///Set the subviews to be clipped to the bounds of the animalPhotoView.
        self.animalImage.clipsToBounds = true
        //Set cormerRadius,border and backgroud color for animalIconView.
        self.animalImage.contentMode = .scaleAspectFill
        self.animalImage.layer.cornerRadius = 5
        self.activityIndecater.isHidden = true
        self.activityIndecater.style = UIActivityIndicatorView.Style.whiteLarge
        self.activityIndecater.color = UIColor.black
        
        
    }
    
    /// Sent to the view controller when the app receives a memory warning.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Tells the delegate that the user selected an item in the tab bar.
    ///
    /// - Parameters:
    ///   - tabBarController: tabBarController description
    ///   - viewController: viewController description
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        if tabBarIndex == 1 {
            self.camara()
        }
    }
    
    /// Metches strings user regular expression
    ///
    /// - Parameters:
    ///   - regex: regular expression applied
    ///   - text: text to matchtes
    /// - Returns: metches result
    func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}



/// Image processing

extension ViewController {
    
    func analyzeResults(_ dataToParse: Data) {
        
        // Update UI on the main thread
        
        
        // Use SwiftyJSON to parse results
        let json = JSON(data: dataToParse)
        let errorObj: JSON = json["error"]
        var translate = true
        
        // Check for errors
        if (errorObj.dictionaryValue != [:]) {
            self.labelResults.text = "Error code \(errorObj["code"]): \(errorObj["message"])"
        } else {
            // Parse the response
            //print(json)
            let responses: JSON = json
            print(responses)
            print(json)
            let labelAnnotations: JSON = responses["result"]
            if labelAnnotations[0]["name"] != "非动物"{
                let numLabels: Int = labelAnnotations.count
                var labels = [String: String]()
                if numLabels > 0 {
                    
                    
                    for index in 0..<numLabels {
                        let des = labelAnnotations[index]["name"].stringValue
                        print(des)
                        let name = fastDict[des]
                        if name != nil{
                            var score = labelAnnotations[index]["score"].doubleValue.roundTo(places: 4) * 100
                            if score < 1{
                                score = (score * 80).roundTo(places:1)
                            }
                            if score < 5{
                                score = (score * 14).roundTo(places:1)
                            }
                            labels[name!] = "\(score)"
                        }
                    }
                    if labels.count == 0{
                        for index in 0..<numLabels {
                            let des = labelAnnotations[index]["baike_info"]["description"].stringValue
                            if des.contains("澳洲") || des.contains("澳大利亚") || des.contains("大洋洲"){
                                var score = labelAnnotations[index]["score"].doubleValue.roundTo(places: 4) * 100
                                if score < 1{
                                    score = (score * 80).roundTo(places:1)
                                }
                                if score < 5{
                                    score = (score * 14).roundTo(places:1)
                                }
                                labels[labelAnnotations[index]["name"].stringValue] = "\(score)"
                                //                            matchingIndex.append("\(labelAnnotations[index]["score"].doubleValue.roundTo(places: 2))")
                            }
                        }
                    }else{
                        translate = false
                    }
                }
                finalResult(labels:labels,transLate:translate)
                
            }
            else {
                DispatchQueue.main.async {
                    self.labelResults.text = "It doesn't look like an animal. Please try again."
                    self.animalImage.alpha = 1
                    self.activityIndecater.isHidden = true
                    self.uploadButton.isEnabled = true
                }
            }
        }
        
    }
    
    func finalResult(labels:[String: String],transLate:Bool){
        let translator = APIWoker()
        translator.apiKey = "AIzaSyCDS_M2Vf5qb4mwYsyM8vq_XuDkjCYYsF0" // Add your API Key here
        
        let group = DispatchGroup()
        
        var params = ROGoogleTranslateParams()
        
        if labels.count > 0{
            var queues = [DispatchQueue]()
            for label in labels{
                let queue = DispatchQueue(label: label.key, qos: .utility)
                queues.append(queue)
            }
            var index = 0
            for label in labels{
                group.enter()
                queues[index].async(group: group) {
                    params.text = label.key
                    if transLate{
                        translator.translate(params: params) { (result) in
                            params.text = result
                            translator.getDetail(params: params){ (detailResult) in
                                if detailResult.animalType.count > 1 && !self.canceled{
                                    DispatchQueue.main.async {
                                        var resut = detailResult
                                        resut.image = self.animalImage.image!
                                        resut.matchingIndex = label.value
                                        self.detailResuts.append(resut)
                                        print(resut.displayTitle)
                                        group.leave()
                                    }
                                }else{
                                    group.leave()
                                }
                            }
                        }
                        
                    }else{
                        translator.getDetail(params: params){ (detailResult) in
                            if detailResult.animalType.count > 1 && !self.canceled{
                                DispatchQueue.main.async {
                                    var resut = detailResult
                                    resut.image = self.animalImage.image!
                                    resut.matchingIndex = label.value
                                    self.detailResuts.append(resut)
                                    print(resut.displayTitle)
                                    group.leave()
                                }
                            }else{
                                group.leave()
                            }
                        }
                    }
                }
                index = index + 1
            }
            group.notify(queue: DispatchQueue.main) {
                if self.detailResuts.count == 0{
                    self.labelResults.text = "Sorry, I'm not able to identify this animal."
                    self.uploadButton.isEnabled = true
                    self.animalImage.alpha = 1
                    self.activityIndecater.isHidden = true
                }else{
                    self.delegate!.gerResultData(detailResut: self.detailResuts)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        } else {
            DispatchQueue.main.async {
                self.labelResults.text = "Sorry, we currently only offer animal identification service for Victoria wildlife."
                UIView.animate(withDuration: 0.2, animations: {self.labelResults.isHidden = false})
                self.animalImage.alpha = 1
                self.activityIndecater.isHidden = true
                self.uploadButton.isEnabled = true
            }
        }
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        if let pickedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            self.activityIndecater.startAnimating()
            labelResults.text = "Processing..."
            self.activityIndecater.isHidden = false
            self.animalImage.image = pickedImage
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: pickedImage)
            }, completionHandler: { success, error in
                if success {
                    // Saved successfully!
                }
                else if error != nil {
                    // Save photo failed with error
                }
                else {
                    // Save photo failed with no error
                }
            })
            self.animalImage.alpha = 0.5
            let binaryImageData = base64EncodeImage(pickedImage)
            createRequest(with: binaryImageData)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = newImage!.pngData()
        UIGraphicsEndImageContext()
        return resizedImage!
    }
}


/// Networking

extension ViewController {
    func base64EncodeImage(_ image: UIImage) -> String {
        var imagedata = image.pngData()
        
        // Resize the image if it exceeds the 2MB API limit
        if (imagedata?.count > 2097152) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSize(width: 300, height: oldSize.height / oldSize.width * 300)
            imagedata = resizeImage(newSize, image: image)
        }
        
        return imagedata!.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    
    func createRequest(with imageBase64: String) {
        // Create our request URL
        
        var request = URLRequest(url: baiduAiURL)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded",forHTTPHeaderField: "Content-Type")
        let imageString = "image= " + imageBase64.addingPercentEncoding(withAllowedCharacters:
            .alphanumerics)! + "&baike_num= 5"
        
        
        request.httpBody = imageString.data(using: .utf8)
        
        // Run the request on a background thread
        DispatchQueue.global().async { self.runRequestOnBackgroundThread(request) }
    }
    
    func runRequestOnBackgroundThread(_ request: URLRequest) {
        // run the request
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
            
            self.analyzeResults(data)
        }
        
        task.resume()
    }
}



// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}

