// Copyright 2016 Google Inc. All Rights Reserved.
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

protocol ResultDetailDelegate {
    func gerResultData(detailResut: DetailResult) }

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITabBarControllerDelegate {
    let imagePicker = UIImagePickerController()
    let session = URLSession.shared
    var detailResut = DetailResult()
    var delegate:ResultDetailDelegate?
    private var canceled: Bool
    @IBOutlet weak var labelResults: UITextView!
    @IBOutlet weak var popUpView: UIView!

    @IBOutlet weak var animalImage: UIImageView!
    
    @IBOutlet weak var uploadButton: UIButton!
    @IBAction func startButton(_ sender: Any) {
        self.camara()
        self.uploadButton.isEnabled = false
    }
    
    
    
    
    var baiduAiURL: URL {
        return URL(string: "https://aip.baidubce.com/rest/2.0/image-classify/v1/animal?access_token=24.81bd31c59cc027009ad197c531ef19c3.2592000.1556634027.282335-15897168")!
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.canceled = false
        super.init(coder: aDecoder)!
    }
    
    
    @IBAction func testbutton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        self.canceled = true
        dismiss(animated: true, completion: nil)
//        let url: String = "http://118.139.91.44:8081/restapi/ios"
//        //let testDic = ["name":"SMH","age":12]as [String:Any]
//        //let jsonData = try! JSONSerialization.data(withJSONObject: testDic)
//
//        let pd = ["abc":"cba","xyz":"zyx"]
//        var jsonString = ""
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: pd, options: .prettyPrinted)
//            jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
//        }catch{
//            print(error.localizedDescription)
//        }
//        let parameters = [
//            "methodId":2,
//            "postData":jsonString
//
//            ] as [String : Any]
//        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
//            switch response.result {
//            case .success:
//                if let value = response.result.value {
//                    print(value)
//                    let JSON = value as? NSDictionary
//                    print(JSON?["response"] as! String)
//                }
//            case .failure(let error):
//                print(error)
//            }
//        }
//
        
    }
    
    func pickAnImage(){
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func displayMessage(_ title: String,_ message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func camara(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized: // The user has previously granted access to the camera.
                imagePicker.sourceType = UIImagePickerController.SourceType.camera
                imagePicker.allowsEditing = false
                imagePicker.delegate = self
                self.present(imagePicker, animated: true, completion: nil)
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
            pickAnImage()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
        imagePicker.delegate = self
        self.labelResults.text = "Please upload an animal photo and we will tell you what it is."
        self.popUpView.layer.cornerRadius = 10
        self.popUpView.layer.masksToBounds = true
        self.animalImage.contentMode = .scaleAspectFill
        ///Set the subviews to be clipped to the bounds of the animalPhotoView.
        self.animalImage.clipsToBounds = true
        //Set cormerRadius,border and backgroud color for animalIconView.
        self.animalImage.contentMode = .scaleAspectFill
        self.animalImage.layer.cornerRadius = 5
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        if tabBarIndex == 1 {
            self.camara()
        }
    }
    
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
        
            
            // Check for errors
            if (errorObj.dictionaryValue != [:]) {
                self.labelResults.text = "Error code \(errorObj["code"]): \(errorObj["message"])"
            } else {
                // Parse the response
                //print(json)
                let responses: JSON = json
                print(json)
                let labelAnnotations: JSON = responses["result"]
                    if labelAnnotations[0]["name"] != "非动物"{
                        let numLabels: Int = labelAnnotations.count
                        var labels: Array<String> = []
                        if numLabels > 0 {
                            
                            for index in 0..<numLabels {
                                let des = labelAnnotations[index]["baike_info"]["description"].stringValue
                                if (des.contains("澳洲")) || (des.contains("澳大利亚")){
                                    labels.append(labelAnnotations[index]["name"].stringValue)
                                }
                            }
                            
                            print(labels)
                        }
                    
                        let translator = ROGoogleTranslate()
                        translator.apiKey = "AIzaSyCDS_M2Vf5qb4mwYsyM8vq_XuDkjCYYsF0" // Add your API Key here
                        
                        var params = ROGoogleTranslateParams()
                        if labels.count > 0{
                            params.text = labels[0]
                            translator.translate(params: params) { (result) in
                                params.text = result
                                translator.getDetail(params: params){ (detailResult) in
                                    if detailResult.animalType.count > 1 && !self.canceled{
                                        DispatchQueue.main.async {
                                            self.detailResut = detailResult
                                            self.detailResut.image = self.animalImage.image!
                                            self.delegate!.gerResultData(detailResut: self.detailResut)
                                            self.dismiss(animated: true, completion: nil)
                                        }
                                    }
                                    else{
                                        DispatchQueue.main.async {[weak self] in
                                            self?.labelResults.text = "No labels found"
                                        }
                                    }
                                    
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.labelResults.text = "Sorry, we currently only offer animal identification service for Victoria wildlife."
                                UIView.animate(withDuration: 0.2, animations: {self.labelResults.isHidden = false})
                            }
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            self.labelResults.text = "It doesn't look like an animal. Please try again."
                        }
                    }
            }

    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let pickedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            labelResults.isHidden = true
            self.animalImage.image = pickedImage
            let blankView = UIView()
            blankView.frame.size = CGSize(width: 200, height: 200)
            blankView.center = view.center
            let gradient = CAGradientLayer(layer: blankView.layer)
            let pink = UIColor(red: 196/255.0, green: 70/255.0, blue: 107/255.0, alpha: 1.0)
            let clear = UIColor.white.withAlphaComponent(0).cgColor
            gradient.colors = [clear,pink.cgColor,clear]
            gradient.locations = [0.0,0.75,1.0]
            gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
            gradient.endPoint = CGPoint(x: 1.0, y: 0.0)
            gradient.frame = blankView.bounds
            blankView.layer.insertSublayer(gradient, at: 0)
            view.addSubview(blankView)
            let gadientAnimation = CABasicAnimation(keyPath: "locations")
            gadientAnimation.fromValue = [0.0,0.0,0.25]
            gadientAnimation.toValue = [0.75,1.0,1.0]
            gadientAnimation.duration = 3.0
            gadientAnimation.autoreverses = true
            gadientAnimation.repeatCount = Float.infinity
            gradient.add(gadientAnimation, forKey: nil)
            // Base64 encode the image and create the request
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
            let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
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
