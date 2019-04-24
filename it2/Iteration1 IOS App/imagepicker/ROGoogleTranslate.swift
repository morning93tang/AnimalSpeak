//
//  ROGoogleTranslate.swift
//  imagepicker
//
//  Created by 唐茂宁 on 1/4/19.
//  Copyright © 2019 Sara Robinson. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

/// Utility class for sending request to google
public struct ROGoogleTranslateParams {

    public init() {
        
    }
    
    /// Defind the lauguage of response
    ///
    /// - Parameters:
    ///   - source: source language
    ///   - target: target language
    ///   - text: query
    public init(source:String, target:String, text:String) {
        self.source = source
        self.target = target
        self.text = text
    }
    
    public var source = "zh-CN"
    public var target = "en"
    public var text = "Hallo"
}

/// Data structure for storing the response
public struct DetailResult {
    
    public init() {
        
    }
    
    public init(displayTitle:String, animalType:String, distribution:String,imageURL:String, image: UIImage, latLongs:NSDictionary) {
        self.displayTitle = displayTitle
        self.animalType = animalType
        self.distribution = distribution
        self.imageURL = imageURL
        self.image = image
        self.latLongs = latLongs
    }
    public var imageURL = ""
    public var displayTitle = ""
    public var animalType = ""
    public var distribution = ""
    public var latLongs:NSDictionary?
    public var image:UIImage?
}



/// Offers easier access to the Google Translate API
open class ROGoogleTranslate {
    
    /// Store here the Google Translate API Key
    public var apiKey = "AIzaSyCDS_M2Vf5qb4mwYsyM8vq_XuDkjCYYsF0"
    
    open class MyServerTrustPolicyManager: ServerTrustPolicyManager{
        open override func serverTrustPolicy(forHost host: String) -> ServerTrustPolicy? {
            return ServerTrustPolicy.disableEvaluation
        }
    }
    
    let sessaionManager = SessionManager(delegate: SessionDelegate(), serverTrustPolicyManager:MyServerTrustPolicyManager(policies:["http://35.201.22.21:8081/restapi/ios":.disableEvaluation]))
    
    ///
    /// Initial constructor
    ///
    public init() {
        
    }
    
    ///
    /// Translate a phrase from one language into another
    ///
    /// - parameter params:   ROGoogleTranslate Struct contains all the needed parameters to translate with the Google Translate API
    /// - parameter callback: The translated string will be returned in the callback
    ///
    
    open func translate(params:ROGoogleTranslateParams, callback:@escaping (_ translatedText:String) -> ()) {
        
        guard apiKey != "" else {
            print("Warning: You should set the api key before calling the translate method.")
            return
        }
        
        if let urlEncodedText = params.text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            if let url = URL(string: "https://kgsearch.googleapis.com/v1/entities:search?languages=\(params.source)&languages=\(params.target)&query=\(urlEncodedText)&types=Thing&key=\(self.apiKey)&limit=1") {
                print(url)
                let httprequest = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                    guard error == nil else {
                        print("Something went wrong: \(String(describing: error?.localizedDescription))")
                        return
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        
                        guard httpResponse.statusCode == 200 else {
                            
                            if let data = data {
                                print("Response [\(httpResponse.statusCode)] - \(data)")
                            }
                            
                            return
                        }
                        
                            let json = JSON(data: data!)
                            let errorObj: JSON = json["error"]
                            // Check for errors
                            if (errorObj.dictionaryValue != [:]) {
                                print("Error code \(errorObj["code"]): \(errorObj["message"])")
                            } else {
                                // Parse the response
                                
                                let responses: JSON = json
                                print(responses)
                                let labelAnnotations: JSON = responses["itemListElement"][0]["result"]["name"]
                                print(labelAnnotations)
                                let numLabels: Int = labelAnnotations.count
                                print(numLabels)
                                var labelResultsText:String = ""
                                if numLabels > 0 {
                                    for index in 0..<numLabels{
                                        if labelAnnotations[index]["@language"].stringValue == "en"{
                                            labelResultsText = labelAnnotations[index]["@value"].stringValue
                                            break
                                        }
                                    }
                                }
                                callback(labelResultsText)
                        }
                    }
                })

                httprequest.resume()
            }
        }
    }
    
    /// Get image from sercer
    ///
    /// - Parameters:
    ///   - params: Animal name
    ///   - callback: Image
    open func getimage(params:ROGoogleTranslateParams, callback:@escaping (_ translatedText:String) -> ()) {
        
        guard apiKey != "" else {
            print("Warning: You should set the api key before calling the translate method.")
            return
        }
        
        if let urlEncodedText = params.text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            if let url = URL(string: "https://kgsearch.googleapis.com/v1/entities:search?languages=en&limit=1&prefix=true&query=\(urlEncodedText)&types=Thing&key=\(self.apiKey)") {
                let httprequest = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                    guard error == nil else {
                        print("Something went wrong: \(String(describing: error?.localizedDescription))")
                        return
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        
                        guard httpResponse.statusCode == 200 else {
                            
                            if let data = data {
                                print("Response [\(httpResponse.statusCode)] - \(data)")
                            }
                            
                            return
                        }
                        
                        let json = JSON(data: data!)
                        let errorObj: JSON = json["error"]
                        // Check for errors
                        if (errorObj.dictionaryValue != [:]) {
                            print("Error code \(errorObj["code"]): \(errorObj["message"])")
                        } else {
                            // Parse the response
                            
                            let responses: JSON = json
                            print(responses)
                            let labelAnnotations: JSON = responses["itemListElement"][0]["result"]["image"]["contentUrl"]
                            print(labelAnnotations)
                            let imageUrl = labelAnnotations.stringValue
                            print(imageUrl)
                            callback(imageUrl)
                        }
                        
                    }
                })
                
                httprequest.resume()
            }
        }
    }
    
    
    /// Get detail information of an animal
    ///
    /// - Parameters:
    ///   - params: animal name
    ///   - callback: detatil information in form of DerailResult structure
    open func getDetail(params:ROGoogleTranslateParams, callback:@escaping (_ detailResult:DetailResult) -> ()) {
        
        let query = params.text.components(separatedBy: " ")
        var queryText = ""
        for index in 0..<query.count{
            queryText = queryText + query[index] + "&query="
        }
        if let urlEncodedText = queryText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            if let url = URL(string: "https://collections.museumvictoria.com.au/api/search?query=\(urlEncodedText)&recordtype=species&hasimages=yes&page=1") {
                print(url)
                let httprequest = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                    guard error == nil else {
                        print("Something went wrong: \(String(describing: error?.localizedDescription))")
                        return
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        
                        guard httpResponse.statusCode == 200 else {
                            
                            if let data = data {
                                print("Response [\(httpResponse.statusCode)] - \(data)")
                            }
                            
                            return
                        }
                        
                        let json = JSON(data: data!)
                        let errorObj: JSON = json["error"]
                        // Check for errors
                        if (errorObj.dictionaryValue != [:]) {
                            print("Error code \(errorObj["code"]): \(errorObj["message"])")
                        } else {
                            // Parse the response
                            var detailResult = DetailResult()
                            let responses: JSON = json
                            print(responses)
                            detailResult.displayTitle = responses[0]["displayTitle"].stringValue.components(separatedBy: ", ").last!
                            detailResult.animalType = responses[0]["animalType"].stringValue
                            detailResult.distribution = responses[0]["biology"].stringValue
                            detailResult.imageURL = responses[0]["media"][0]["small"]["uri"].stringValue
                            callback(detailResult)
                        }
                    }
                })
                
                httprequest.resume()
            }
        }
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
            "postData":jsonString] as [String : Any]
//        let serverTrustPolicies: [String: ServerTrustPolicy] = [
//            "https://118.139.67.137:8443": .disableEvaluation
//        ]
//        sessaionManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
            //                    var statusCode = response.response?.statusCode
            //                    print(statusCode)
         Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
            switch response.result {
            case .success:
                if let alamoError = response.result.error {
                    print(alamoError._code)
                    print((response.response?.statusCode)!)
                } else { //no errors
                    let statusCode = (response.response?.statusCode)! //example : 200print(value)
                    if let value = response.result.value {
                        let responseDict = value as? NSDictionary
                        callback(responseDict)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    /// Send request to database server
    ///
    /// - Parameters:
    ///   - methodId: methodId(Int)
    ///   - request: query(String)
    ///   - callback: callback description(String)
//    public func sendRequestToServer(methodId:Int,request:NSDictionary, callback:@escaping (_ :NSDictionary?) -> ()){
//        let url: String = "http://35.201.22.21:8081/restapi/ios"
//        var jsonString = ""
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: request, options: .prettyPrinted)
//            jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
//        }catch{
//            print(error.localizedDescription)
//        }
//        let parameters = [
//            "methodId":methodId,
//            "postData":jsonString
//
//            ] as [String : Any]
//        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
//            switch response.result {
//            case .success:
//                if let alamoError = response.result.error {
//                    let alamoCode = alamoError._code
//                    let statusCode = (response.response?.statusCode)!
//                    print(alamoCode)
//                    print(statusCode)
//                } else { //no errors
//                    let statusCode = (response.response?.statusCode)! //example : 200print(value)
//                    print(statusCode)
//                    if let value = response.result.value {
//                        let responseDict = value as? NSDictionary
//                        callback(responseDict)
//                    }
//                }
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }
    
    
    
    
    
    
}
