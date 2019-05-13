//
//  TabBarController.swift
//  imagepicker
//
//  Created by 唐茂宁 on 28/3/19.
//  Copyright © 2019 Sara Robinson. All rights reserved.
//
import UIKit

class TabBarController: UITabBarController,UITabBarControllerDelegate {
    
    @IBOutlet weak var suTabBar: UITabBar!
    
    var slidingUpVC: SUSlidingUpVC!
    
    let slideUpPanelManager: TSSlidingUpPanelManager = TSSlidingUpPanelManager.with

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        slidingUpVC = (storyboard?.instantiateViewController(withIdentifier: "SUSlidingUp"))! as! SUSlidingUpVC
        
        slideUpPanelManager.slidingUpPanelStateDelegate = self
        slideUpPanelManager.initPanelWithTabBar(inView: view, tabBar: suTabBar, slidingUpPanelView: slidingUpVC.view, slidingUpPanelHeaderSize: 200)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let tabBar: UITabBarController = appDelegate.window!.rootViewController as! UITabBarController
        let first = tabBar.viewControllers![0] as! UINavigationController
        let mapViewController = first.viewControllers.first as! MapViewController
        mapViewController.slidingVC = slidingUpVC
        
        // Do any additional setup after loading the view.
    }
    
    
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        if tabBarIndex == 0 {
            CBToast.showToast(message: "Select an animal icon to check its distribution in 5KMs.", aLocationStr: "bottom", aShowTime: 3.0)
        }else{
            CBToast.showToast(message: "Select an animal icon to check its distribution in 5KMs.", aLocationStr: "bottom", aShowTime: 0.0)
            slideUpPanelManager.changeSlideUpPanelStateTo(toState: SLIDE_UP_PANEL_STATE.CLOSED)
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
extension TabBarController: TSSlidingUpPanelStateDelegate {
    
    
    
   
    
    func slidingUpPanelStateChanged(slidingUpPanelNewState: SLIDE_UP_PANEL_STATE, yPos: CGFloat) {
        
    }
}

