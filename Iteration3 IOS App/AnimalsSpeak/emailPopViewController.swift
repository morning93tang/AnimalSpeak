//
//  emailPopViewController.swift
//  imagepicker
//
//  Created by 唐茂宁 on 28/4/19.
//  Copyright © 2019 Sara Robinson. All rights reserved.
//

import UIKit



class emailPopViewController: UIViewController,UITextFieldDelegate,UITextViewDelegate {
    @IBOutlet weak var additionallabel: UILabel!
    @IBOutlet weak var cancleButton: UIButton!
    @IBOutlet weak var seeTempButton: UIButton!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var emailTextView: UITextField!
    @IBOutlet weak var infomationTextField: UITextView!
    @IBOutlet weak var hintLabel: UILabel!
    var goodToSend = false
    
    @IBAction func sendButtonAction(_ sender: Any) {
        if goodToSend{
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                let tabBar: UITabBarController = appDelegate.window?.rootViewController as! UITabBarController
                let fivthTab = tabBar.viewControllers![4] as! UINavigationController
                let pageVC = fivthTab.viewControllers.first as! ReportPageViewController
                pageVC.email = self.emailTextView.text!
                if self.infomationTextField.text != nil{
                    pageVC.msg = self.infomationTextField.text
                }else{
                    pageVC.msg = "No information provided"
                }
                appDelegate.window?.rootViewController?.dismiss(animated: false, completion: nil)
                pageVC.performSegue(withIdentifier: "seeTempSegue", sender: pageVC)
            }
        }else{
            
        }
    }
    @IBAction func cancleButtonAction(_ sender: Any) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
//            let tabBar: UITabBarController = appDelegate.window?.rootViewController as! UITabBarController
//            let fivthTab = tabBar.viewControllers![4] as! UINavigationController
//            let pageVC = fivthTab.viewControllers.first as! ReportPageViewController
            appDelegate.window?.rootViewController?.dismiss(animated: false, completion: nil)
//            pageVC.popToRootViewController(animated: false)
//            pageVC.performSegue(withIdentifier: "answerSegue", sender: homeVC)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        additionallabel.textColor = UIColor.white
        cancleButton.layer.cornerRadius = 5
        seeTempButton.layer.cornerRadius = 5
        popUpView.layer.cornerRadius = 5
        infomationTextField.layer.cornerRadius = 5
        infomationTextField.text = "You can provide any additional information that may help us address the problem faster."
        infomationTextField.textColor = UIColor.lightGray
        hintLabel.text = "We will generate a templet for you to check, than you can decide to sent it."
        hintLabel.textColor = UIColor.white
        self.infomationTextField.delegate = self
        self.emailTextView.delegate = self
//        NotificationCenter.default.addObserver(self, selector: Selector(("keyboardWillShow:")), name:UIResponder.keyboardWillShowNotification, object: nil);
//        NotificationCenter.default.addObserver(self, selector: Selector(("keyboardWillHide:")), name:UIResponder.keyboardWillHideNotification, object: nil);
        // Do any additional setup after loading the view.
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateViewMoving(up: true, moveValue: 100)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateViewMoving(up: false, moveValue: 100)
        if textField.text != nil && isValidEmail(testStr:textField.text!){
            goodToSend = true
            self.hintLabel.text = ""
        }else{
            self.hintLabel.text = "Please use a valid email."
            self.hintLabel.textColor = UIColor.red
        }
        self.view.endEditing(true)
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        animateViewMoving(up: true, moveValue: 100)
    }
    @IBAction func dismissKeboard(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "You can provide any additional information that may help us addrees the problem faster."
            textView.textColor = UIColor.lightGray
        }
        animateViewMoving(up: false, moveValue: 100)
        self.view.endEditing(true)
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }

    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: testStr)

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
