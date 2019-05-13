//
//  QuizHomeViewController.swift
//  imagepicker
//
//  Created by 唐茂宁 on 26/4/19.
//  Copyright © 2019 Sara Robinson. All rights reserved.
//

import UIKit
import CoreData

class QuizHomeViewController: UIViewController {
    var answer = ""
    @IBOutlet weak var playGameButton: UIButton!
    @IBOutlet weak var imageBackGround: UIImageView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var recordCardImageView: UIImageView!
    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var recordBackgroundView: UIView!
    private var managedObjectContext: NSManagedObjectContext
    
    
    required init?(coder aDecoder: NSCoder) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = (appDelegate?.persistentContainer.viewContext)!
        super.init(coder: aDecoder)!
    }
    
    func initAppData() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Record")
        do {
            let tempList = try managedObjectContext.fetch(fetchRequest) as! [Record]
            if tempList.count == 0 {
                recordLabel.text = "0"
            }
            else{
                for rec in tempList{
                    self.recordLabel.text = rec.record!
                }
            }
        }
        catch{
            fatalError("Failed to fetch icon: \(error)")
        }
    }
    
    override func viewDidLoad() {
        
        self.playGameButton.layer.cornerRadius = 20.0
        self.playGameButton.layer.masksToBounds = false
//        self.playGameButton.layer.backgroundColor = UIColor.white.cgColor
        self.playGameButton.layer.shadowColor =  UIColor.black.withAlphaComponent(0.6).cgColor
        self.playGameButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.playGameButton.layer.shadowOpacity = 0.8
        self.backgroundView.layer.cornerRadius = 3.0
        self.backgroundView.layer.masksToBounds = false
        self.backgroundView.layer.shadowColor = UIColor.black.withAlphaComponent(0.6).cgColor
        self.backgroundView.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.backgroundView.layer.shadowOpacity = 0.8
//        self.backgroundCardView.layer.shadowOpacity = 0.8
        self.recordCardImageView.layer.cornerRadius = 3.0
        self.recordCardImageView.contentMode = .scaleAspectFill
        self.recordCardImageView.clipsToBounds = true
        self.recordBackgroundView.layer.cornerRadius = 3.0
        self.recordBackgroundView.layer.masksToBounds = false
        self.recordBackgroundView.layer.borderWidth = 1
        self.recordBackgroundView.layer.borderColor = UIColor.white.cgColor
        self.recordBackgroundView.layer.shadowColor = UIColor.black.withAlphaComponent(0.6).cgColor
        self.recordBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.recordBackgroundView.layer.shadowOpacity = 0.8
        
        initAppData()

        // Do any additional setup after loading the view.
        super.viewDidLoad()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "answerSegue"
        {
            if let destination = segue.destination as? SecondaryAnimalDetailViewController {
                destination.animalName = self.answer
            }
        }
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
