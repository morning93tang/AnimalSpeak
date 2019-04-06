//
//  TableViewCell.swift
//  imagepicker
//
//  Created by 唐茂宁 on 5/4/19.
//  Copyright © 2019 Sara Robinson. All rights reserved.
//

import UIKit
import Alamofire

class TableViewCell: UITableViewCell {

    @IBOutlet weak var AnimalImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var tickBoxImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func sendRequestToServer(methodId:Int,request:NSDictionary){
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
                        let JSON = value as? NSDictionary
                        if let resultValue = JSON!["response"] as? String{
                            print(resultValue)
                        }
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
