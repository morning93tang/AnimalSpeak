//
//  ViewController.swift
//  practice-basic1
//
//  Created by TIANYI YUAN on 24/3/19.
//  Copyright © 2019 TIANYI YUAN. All rights reserved.
//

import UIKit	
import Alamofire

class ViewController: UIViewController {
    
    
    @IBOutlet weak var powerBtn: UIButton!
    @IBOutlet weak var darkblueBG: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    @IBAction func powerBtnPress(_ sender: Any) {
        let url: String = "http://192.168.0.103:8081/rpc/authorize"
        let parameters = [
            "methodId":6,
            "postData":"anc"
            ] as [String : Any]
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
            switch response.result {
            case .success:
                if let value = response.result.value {
                    print(value)
                }
            case .failure(let error):
                print(error)
            }
        }
        
        
        
    }
    
    
}


