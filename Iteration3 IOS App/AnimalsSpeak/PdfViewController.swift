//
//  PdfViewController.swift
//  imagepicker
//
//  Created by 唐茂宁 on 28/4/19.
//  Copyright © 2019 Sara Robinson. All rights reserved.
//

import UIKit
import WebKit

class PdfViewController: UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var emptyview: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var acticityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var buttonBackView: UIView!
    var wkwebView: WKWebView!
    var email = ""
    var name = ""
    var msg = ""
    var img:UIImage?
    var lat = ""
    var long = ""
    var fileName = ""
    
    
//    override func loadView() {
//        webView = WKWebView()
//        webView.navigationDelegate = self
//        view = webView
//    }
    @IBAction func send(_ sender: Any) {
        self.sendButton.isEnabled = false
        let translator = ROGoogleTranslate()
        translator.sendRequestToServer(methodId: 10,request: ["file":fileName,"ccAddress":email]){ (result) in
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                let tabBar: UITabBarController = appDelegate.window?.rootViewController as! UITabBarController
                let thirdTab = tabBar.viewControllers![4] as! UINavigationController
                thirdTab.popToRootViewController(animated: true)
            DispatchQueue.global().async {
                if result != nil{
                    CBToast.showToast(message: "Email sent. We have also sent you an copy of that to your email.", aLocationStr: "bottom", aShowTime: 3.0)
                    }
                }
                
            }
        }
        
    }
    
    func base64EncodeImage(_ image: UIImage) -> String {
        var imagedata = image.jpegData(compressionQuality:0.001)!
        
        // Resize the image if it exceeds the 2MB API limit
        if ((imagedata.count) > 2097152) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
            imagedata = resizeImage(newSize, image: image)
        }
        
        return "data:image/jpeg;base64," + imagedata.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    
    func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = newImage!.pngData()
        UIGraphicsEndImageContext()
        return resizedImage!
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sendButton.isEnabled = false
        self.emptyview.isHidden = false
        self.acticityIndicator.isHidden = true
        self.acticityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        self.acticityIndicator.color = UIColor.black
        self.acticityIndicator.isHidden = false
        self.acticityIndicator.startAnimating()
        self.wkwebView = WKWebView(frame:contentView.bounds)
        self.wkwebView.navigationDelegate = self
        self.contentView.addSubview(wkwebView)
        let translator = ROGoogleTranslate()
        self.sendButton.layer.cornerRadius = 8.0
        self.sendButton.layer.masksToBounds = false
        //        self.playGameButton.layer.backgroundColor = UIColor.white.cgColor
        self.buttonBackView.layer.shadowColor =  UIColor.black.withAlphaComponent(0.6).cgColor
        self.buttonBackView.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.buttonBackView.layer.shadowOpacity = 0.8
        //let imageString = self.base64EncodeImage(self.img!)
        //print(imageString)
        translator.sendRequestToServer(methodId: 9,request: ["animal":name,"className":"mammalia","lat":lat,"lon":long,"userName":"Animal talk app user","email":email,"msg":msg,"img":self.base64EncodeImage(img!)]){ (result) in
            DispatchQueue.global().async {
                if result != nil{
                    if let fileName = result!["response"] as? String{
                        let url = URL(string: "http://35.201.22.21:8081/getReport?id=\(fileName)")!
                        self.fileName = fileName
                        DispatchQueue.main.async{
                            self.wkwebView.load(URLRequest(url: url))
                            self.acticityIndicator.isHidden = true
                            self.acticityIndicator.stopAnimating()
                            self.sendButton.isEnabled = true
                            self.emptyview.isHidden = true
                        }
                        
                    }
                }
            }
        }
        
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        }
        
        
        //                            Alamofire.download("http://localhost:8081/getReport?id=\(strWithNoSpace)", to: destination).response { response in
        //                                if let localURL = response.destinationURL {
        //                                    print(localURL)
        //                                    do {
        //                                        print(localURL.absoluteURL)
        //                                        self.audioPlayer = try AVAudioPlayer(contentsOf:localURL.absoluteURL )
        //                                        self.audioPlayer.prepareToPlay()
        //                                        self.playButton.isHidden = false
        //                                        self.playIcon.isHidden = false
        //                                    } catch let error {
        //                                        print(error.localizedDescription)
        //                                    }
        //                                } else {
        //
        //                                }
        //                        }
        //                    }
        //                }
        
        // Do any additional setup after loading the view.
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
