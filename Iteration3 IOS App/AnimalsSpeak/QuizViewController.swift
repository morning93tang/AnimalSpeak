//
//  QuizViewController.swift
//  imagepicker
//
//  Created by 唐茂宁 on 27/4/19.
//  Copyright © 2019 Sara Robinson. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation
import SwiftyJSON
import CoreData


/// This controller dynamically loading quizs from server. Images and audio files will be downloaded and catched after a question is loaded from server. Loading page will be shown with curent number of correct answers during the process of downloading.
class QuizViewController: UIViewController {

    private var managedObjectContext: NSManagedObjectContext
    private var record = [Record]()
    var newAttempt = 0
    var currentBest = 0
    var start = DispatchTime.now()
    var end = DispatchTime.now()
    @IBOutlet weak var answerStreakLabel: UILabel!
    @IBOutlet weak var loadingPage: UIView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var anwserButton1: UIButton!
    @IBOutlet weak var anwserButton2: UIButton!
    @IBOutlet weak var answerButton3: UIButton!
    @IBOutlet weak var answerButton4: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playButtonBackgroundView: UIView!
    @IBOutlet weak var feedBackLabel: UILabel!
    @IBOutlet weak var goodLuck: UIImageView!
    @IBOutlet weak var cardBackView: UIView!
    var answer = ""
    var player: AVPlayer?
    var audioPlayer:AVAudioPlayer!
    
    required init?(coder aDecoder: NSCoder) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = (appDelegate?.persistentContainer.viewContext)!
        super.init(coder: aDecoder)!
    }
    
    /// Save record data to managedObjectContext
    func saveData() {
        
        do {
            try managedObjectContext.save()
        }
        catch let error {
            print("Could not save Core Data: \(error)")
        }
    }
    
    func initAppData() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Record")
        do {
            let tempList = try managedObjectContext.fetch(fetchRequest) as! [Record]
            if tempList.count == 0 {
                let record = NSEntityDescription.insertNewObject(forEntityName: "Record", into: managedObjectContext) as! Record
                record.record = "0"
                print(record)
                self.record.append(record)
                print(self.record)
                self.saveData()
            }
            else{
                self.record = tempList
                for rec in record{
                    self.currentBest = Int(rec.record!)!
                }
            }
        }
        catch{
            fatalError("Failed to fetch icon: \(error)")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAppData()
        self.goodLuck.isHighlighted = true
        self.feedBackLabel.text = "Good Luck"
        self.anwserButton1.layer.borderColor = UIColor.white.cgColor
         self.anwserButton1.layer.borderWidth = 1
        self.anwserButton2.layer.borderColor = UIColor.white.cgColor
        self.anwserButton2.layer.borderWidth = 1
        self.answerButton3.layer.borderColor = UIColor.white.cgColor
        self.answerButton3.layer.borderWidth = 1
        self.answerButton4.layer.borderColor = UIColor.white.cgColor
        self.answerButton4.layer.borderWidth = 1
        self.playButtonBackgroundView.layer.cornerRadius = 0.5 * playButtonBackgroundView.bounds.size.width
        self.playButtonBackgroundView.layer.shadowColor = UIColor.black.withAlphaComponent(0.6).cgColor
        self.playButtonBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.playButtonBackgroundView.layer.shadowOpacity = 0.8
        self.playButton.layer.cornerRadius = 0.5 * playButton.bounds.size.width
        self.cardBackView.layer.shadowColor = UIColor.black.withAlphaComponent(0.6).cgColor
        self.cardBackView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardBackView.layer.shadowOpacity = 0.8
        self.cardBackView.layer.cornerRadius = 4
        generateQuize()
        // Do any additional setup after loading the view.
    }
    /// Play audio onclick
    @IBAction func play(_ sender: Any) {
        self.audioPlayer.play()
    }
    
    /// Check answer onclick
    @IBAction func answarButton1Action(_ sender: Any) {
        print(self.answer)
        self.checkAnwser(answer: self.label1.text!)
    }
        /// Check answer onclick
    @IBAction func answarButton2Action(_ sender: Any) {
        self.checkAnwser(answer: self.label2.text!)
    }
        /// Check answer onclick
    @IBAction func answarButton3Action(_ sender: Any) {
         self.checkAnwser(answer: self.label3.text!)
    }
        /// Check answer onclick
    @IBAction func answarButton4Action(_ sender: Any) {
        self.checkAnwser(answer: self.label4.text!)
        
    }
    
    
    /// Compare user selection with correct answer. Load next question if correctly answered, otherwise stop and save the new record if there is one.
    func checkAnwser(answer:String){
        start = DispatchTime.now()
        if answer == self.answer{
            self.newAttempt = self.newAttempt + 1
            self.answerStreakLabel.text = "\(self.newAttempt)"
            if self.newAttempt > self.currentBest{
                record[0].record = "\(self.newAttempt)"
                self.saveData()
            }
            self.generateQuize()
            self.loadingPage.isHidden = false
        }else{
            self.performSegue(withIdentifier: "resultSegue", sender: self)
        }
    }
    
    
    /// Use animal name to download audio file from server
    func loadSound(animalName:String){
        self.playButton.isHidden = true
        self.audioPlayer = nil
        let strWithNoSpace = animalName.replacingOccurrences(of: " ", with: "%20")
        let audioFileName = strWithNoSpace as NSString
        let pathExtension = audioFileName.pathExtension
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent("yourFileName."+pathExtension)
            return (documentsURL, [.removePreviousFile])
        }
        Alamofire.download("http://35.201.22.21:8081/getVoice?id=\(strWithNoSpace)", to: destination).response { response in
            
            if let localURL = response.destinationURL {
                
                print(localURL)
                do {
                    print(localURL.absoluteURL)
                    self.audioPlayer = try AVAudioPlayer(contentsOf:localURL.absoluteURL )
                    self.audioPlayer.prepareToPlay()
                    self.playButton.isHidden = false
                    self.end = DispatchTime.now()
                    let nanoTime = self.end.uptimeNanoseconds - self.start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
                    let timeInterval = Double(nanoTime) / 1_000_000_000 // Technically could overflow for long running tests
                    if timeInterval < 3.0{
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 - timeInterval) {
                            self.loadingPage.isHidden = true
                            self.goodLuck.isHighlighted = false
                            self.feedBackLabel.text = "Correct"
                        }
                        
                    }
                    else{
                        self.loadingPage.isHidden = true
                        self.goodLuck.isHighlighted = false
                        self.feedBackLabel.text = "Correct"
                    }
                    
                    
                } catch let error {
                    print(error.localizedDescription)
                    self.generateQuize()
                }
                
            } else {
                self.generateQuize()
            }
            
        }
    }
    
    /// Send request to server to get a question and its correct anwser.
    func generateQuize(){
        let translator = APIWoker()
        var params = ROGoogleTranslateParams()
        var results = [DetailResult]()
        let group = DispatchGroup()
        translator.sendRequestToServer(methodId: 8,request: ["":""] ){ (result) in
            if result != nil{
                if let answer = result!["answer"] as? String{
                    self.answer = answer
                }
                
                if let list = result!["response"] as? String{
                    if let data = list.data(using: .utf8) {
                        if let json = try? JSON(data: data) {
                            var queues = [DispatchQueue]()
                            for name in json.arrayValue {
                                let queue = DispatchQueue(label: name.stringValue, qos: .utility)
                                queues.append(queue)
                            }
                            var index = 0
                            for name in json.arrayValue{
                                group.enter()
                                queues[index].async(group: group) {
                                    params.text = name.stringValue
                                    //print("bbbb\(params.text)")
                                    translator.getDetail(params: params){ (detailResult) in
                                        if detailResult.animalType.count > 1 {
                                                results.append(detailResult)
                                                print("bbbb\(detailResult)")
                                            group.leave()
                                        }else{
                                            group.leave()
                                            
                                        }
                                    }
                                }
                                index = index + 1
                            }
                            group.notify(queue: DispatchQueue.main) {
                                print("sb\(results)")
                                if results.count == 4 {

                                    var forDisplay = [String:UIImage]()
                                    var lables = [self.label1,self.label2,self.label3,self.label4]
                                    var buttons = [self.anwserButton1,self.anwserButton2,self.answerButton3,self.answerButton4]
                                    for result in results{
                                            Alamofire.request(result.imageURL).responseImage { response in
                                                debugPrint(response)
                                                debugPrint(response.result)
                                                DispatchQueue.main.async{
                                                    if let image = response.result.value {
                                                        if forDisplay[result.displayTitle] != nil{
                                                            self.generateQuize()
                                                        }
                                                        forDisplay[result.displayTitle] = image
                                                        print("sb\(forDisplay)")
                                                        print("caocaocao\(result.displayTitle)")
                                                        if forDisplay.count == 4{
                                                            var index2 = 0
                                                            for value in forDisplay{
                                                                lables[index2]!.text = value.key
                                                                
                                                                buttons[index2]!.setImage(value.value, for: .normal)
                                                                buttons[index2]!.imageView?.contentMode = UIView.ContentMode.scaleAspectFill
                                                                index2 = index2 + 1
                                                            }
                                                            print("load")
                                                            self.loadSound(animalName:self.answer)
                                                        }
                                                }
                                            }
                                        }
                                    }
                                    results = [DetailResult]()
                                }else{
                                    results = [DetailResult]()
                                    self.generateQuize()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "resultSegue"
        {
            if let destination = segue.destination as? QuizeResultViewController {
                if self.currentBest != self.newAttempt{
                    destination.tittle = "Nice Try"
                }
                destination.currentBest = self.record[0].record!
                destination.newAttempt = "\(self.newAttempt)"
                destination.answer = self.answer
            }
        }
    }
    
    
}
