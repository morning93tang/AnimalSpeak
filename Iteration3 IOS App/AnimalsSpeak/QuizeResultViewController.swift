//
//  QuizeResultViewController.swift
//  imagepicker
//
//  Created by 唐茂宁 on 28/4/19.
//  Copyright © 2019 Sara Robinson. All rights reserved.
//

import UIKit

/// The controller is responsible for diplay detail of the correct answer.
class QuizeResultViewController: UIViewController {
    
    var newAttempt:String?
    var currentBest:String?
    var tittle:String?
    var answer:String?
    /// Back to quizHomeViewController(segue to secondaryDetailViewController)
    ///
    /// - Parameter sender: <#sender description#>
    @IBAction func backToHome(_ sender: Any) {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.window?.rootViewController?.dismiss(animated: true, completion: nil)
                let tabBar: UITabBarController = appDelegate.window?.rootViewController as! UITabBarController
                
                let thirdTab = tabBar.viewControllers![3] as! UINavigationController
                thirdTab.popToRootViewController(animated: true)
            }
    }
    /// Check the correct answer(segue to secondaryDetailViewController)
    ///
    @IBAction func seeAnwser(_ sender: Any) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let tabBar: UITabBarController = appDelegate.window?.rootViewController as! UITabBarController
            let thirdTab = tabBar.viewControllers![3] as! UINavigationController
            let homeVC = thirdTab.viewControllers.first as! QuizHomeViewController
            homeVC.answer = self.answer!
            appDelegate.window?.rootViewController?.dismiss(animated: false, completion: nil)
            thirdTab.popToRootViewController(animated: false)
            homeVC.performSegue(withIdentifier: "answerSegue", sender: homeVC)
        }
    }
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var resultButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var recordCardImageView: UIImageView!
    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var recordBackgroundView: UIView!
    @IBOutlet weak var newAttemptLabel: UILabel!
    @IBOutlet weak var bestLabel: UILabel!
    
    /// Setup UI outlet
    override func viewDidLoad() {
        self.recordLabel.text = tittle
        self.bestLabel.text = currentBest
        self.newAttemptLabel.text = newAttempt
        self.homeButton.layer.cornerRadius = 20.0
        self.homeButton.layer.masksToBounds = false
        //        self.playGameButton.layer.backgroundColor = UIColor.white.cgColor
        self.homeButton.layer.shadowColor =  UIColor.black.withAlphaComponent(0.6).cgColor
        self.homeButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.homeButton.layer.shadowOpacity = 0.8
        
        self.resultButton.layer.cornerRadius = 20.0
        self.resultButton.layer.masksToBounds = false
        //        self.playGameButton.layer.backgroundColor = UIColor.white.cgColor
        self.resultButton.layer.shadowColor =  UIColor.black.withAlphaComponent(0.6).cgColor
        self.resultButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.resultButton.layer.shadowOpacity = 0.8
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
        
        
        
        // Do any additional setup after loading the view.
        super.viewDidLoad()
    }


}
