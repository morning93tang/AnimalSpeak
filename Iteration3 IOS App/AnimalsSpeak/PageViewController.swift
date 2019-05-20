//
//  PageViewController.swift
//  imagepicker
//
//  Created by 唐茂宁 on 25/4/19.
//  Copyright © 2019 Sara Robinson. All rights reserved.
//

import UIKit
import Alamofire


class PageViewController: UIPageViewController,UIPageViewControllerDelegate,ResultDetailDelegate {
    
    
    var pageControl = UIPageControl()
    
    func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        pageControl = UIPageControl(frame: CGRect(x: self.view.frame.midX-30 ,y: UIScreen.main.bounds.maxY - 150,width: 60,height: 28))
//        self.pageControl.numberOfPages = orderedViewControllers.count
        self.pageControl.numberOfPages = 1
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.black
        self.pageControl.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.pageControl.layer.cornerRadius = 10
        self.pageControl.clipsToBounds = true
        self.pageControl.pageIndicatorTintColor = UIColor.white
        self.pageControl.currentPageIndicatorTintColor = UIColor.black
        self.pageControl.isUserInteractionEnabled = false
        self.pageControl.tag = 1234
        let vc1 = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "step1")
        let vc2 = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "step2")
        let vc3 = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "step3")
        let vc4 = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "step4")
        var controllers = [UIViewController]()
        controllers.append(vc1)
        controllers.append(vc2)
        controllers.append(vc3)
        controllers.append(vc4)
        self.orderedViewControllers = controllers
        self.pageControl.numberOfPages = controllers.count
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
//        self.view.viewWithTag(1234)?.isHidden = true
        self.view.addSubview(pageControl)
    }
    
    func gerResultData(detailResut: [DetailResult]) {
        self.derailResult = detailResut.sorted(by: { Double($0.matchingIndex)! > Double($1.matchingIndex)! })
        var controllers = [UIViewController]()
        for index in 0..<derailResult.count{
            if index == 0 || detailResut[index].displayTitle != detailResut[index-1].displayTitle
            {
                let vc = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "animalDetailController") as! AnimalDetailViewController
                vc.derailResult = derailResult[index]
                print(derailResult[index])
                //                    vc.activityIndicator.isHidden = false
                //                    vc.activityIndicator.startAnimating()
                //                    vc.phtotImageView.alpha = 0.5
                //                    vc.phtotImageView.image = nil
                //                    vc.derailResult = derailResult
                //                    vc.pageControl.layer.cornerRadius = 8.0
                //                    vc.nameLabe.text = self.derailResult[0].displayTitle
                //                    vc.descriptionTextView.text = self.derailResult[0].distribution
                //                    vc.iconImageView.contentMode = .scaleAspectFill
                //                    vc.iconImageView.image = self.derailResult[0].image!
                //                    Alamofire.request(self.derailResult[0].imageURL).responseImage { response in
                //                        if let image = response.result.value {
                //                            vc.phtotImageView.contentMode = .scaleAspectFill
                //                            vc.phtotImageView.image = image
                //                            vc.activityIndicator.stopAnimating()
                //                            vc.activityIndicator.isHidden = true
                //                            vc.phtotImageView.alpha = 1
                //                        }
                //                    }
                //                    vc.loadSound(animalName: derailResult[0].displayTitle)
                //                    vc.heatmapLayer.map = nil
                //                    let name = self.derailResult[0].displayTitle
                //                    let worker = ROGoogleTranslate()
                //                    worker.sendRequestToServer(methodId: 2,request: ["animals":[name]]){ (result) in
                
                //                    }
                controllers.append(vc)
            }
        }
//        for subview in self.view.subviews {
//            if (subview.tag == 1234) {
//                subview.removeFromSuperview()
//            }
//            self.configurePageControl()
//        }
        self.orderedViewControllers = controllers
        self.pageControl.numberOfPages = controllers.count
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
//        DispatchQueue.global().async {
//            self.dataSource = nil
//            self.dataSource = self
//        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ImageRecSegue"
        {
            if let destination = segue.destination as? ViewController {
                destination.delegate = self
            }
        }
    }
    
    var orderedViewControllers = [UIViewController]()
    
//    var aClient:[UIViewController] {
//        if(_aClient == nil) {
//            _aClient = Client(ClientSession.shared())
//        }
//        return _aClient!
//    }
    
    var derailResult = [DetailResult]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        configurePageControl()
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

extension PageViewController: UIPageViewControllerDataSource {
    // MARK: Data source functions.
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            //return orderedViewControllers.last
            return nil
            // Uncommment the line below, remove the line above if you don't want the page control to loop.
            // return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
//            return orderedViewControllers.first
            // Uncommment the line below, remove the line above if you don't want the page control to loop.
             return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = orderedViewControllers.index(of: pageContentViewController)!
    }
    
    
    
    
}
