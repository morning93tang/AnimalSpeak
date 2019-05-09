//
//  CheckListItemViewController.swift
//  imagepicker
//
//  Created by 唐茂宁 on 23/4/19.
//  Copyright © 2019 Sara Robinson. All rights reserved.
//

import UIKit
import CoreData
import YoutubePlayer_in_WKWebView

class CheckListItemViewController: UIViewController,UITableViewDelegate,UIScrollViewDelegate, UITableViewDataSource{
    
    
    @IBOutlet weak var pagecontrol: UIPageControl!
    @IBOutlet weak var scroolView: UIScrollView!
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var checkListDes: UILabel!
    @IBOutlet weak var tittleLabel: UILabel!
//    @IBOutlet weak var checkListImageView: UIImageView!
    @IBOutlet weak var checkListItemTableView: UITableView!
    var checkListItems = [ListItem]()
    var checkList:CheckList?
    var frame = CGRect(x:0,y:0,width:0,height:0)
    private var managedObjectContext: NSManagedObjectContext
    required init?(coder aDecoder: NSCoder) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = (appDelegate?.persistentContainer.viewContext)!
        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkListDes.setLineSpacing(lineSpacing: 5.0)
        self.scroolView.delegate = self
        self.checkListItemTableView.delegate = self
        self.checkListItemTableView .dataSource = self
        self.pagecontrol.layer.cornerRadius = 8.0
        self.backGroundView.layer.cornerRadius = 5.0
        self.checkListItemTableView.layer.cornerRadius = 5.0
        self.checkListItemTableView.layer.masksToBounds = true
        self.backGroundView.layer.shadowColor = UIColor.black.withAlphaComponent(0.6).cgColor
        self.backGroundView.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.backGroundView.layer.shadowOpacity = 0.8
        self.pagecontrol.numberOfPages = 2
        for index in 0..<2{
            if index == 0 {
                frame.origin.x = UIScreen.main.bounds.width * CGFloat(index)
                frame.size = scroolView.frame.size
                let checkListImageView = UIImageView(frame:frame)
                checkListImageView.contentMode = .scaleToFill
                checkListImageView.image = ImageWorker.loadImageData(fileName: checkList!.imagePath!)
                self.scroolView.addSubview(checkListImageView)
            }else{
                frame.origin.x = UIScreen.main.bounds.width * CGFloat(index)
                frame.size = scroolView.frame.size
                let videoWebView = WKYTPlayerView(frame:frame)
                videoWebView.load(withVideoId: checkList!.videoLink!)
//                videoWebView.allowsInlineMediaPlayback = true
//                videoWebView.loadHTMLString("<iframe width=\""+"\(videoWebView.frame.width)" + "\" height=\"" + "\(videoWebView.frame.height)" + "\" src=\"" + "https://www.youtube.com/embed/" + checkList!.videoLink! + "?&playinline=1\" frameborder=\"0\" allowfullscreen></iframe>", baseURL: nil)
//                videoWebView.scrollView.contentOffset = videoWebView.scrollView.center;
//                //videoWebView.scrollView.isScrollEnabled = false
                self.scroolView.addSubview(videoWebView)
            }
        }
        scroolView.contentSize = CGSize(width: (UIScreen.main.bounds.width * CGFloat(2)), height: scroolView.frame.size.height)
        self.scroolView.layer.shadowColor = UIColor.black.withAlphaComponent(0.6).cgColor
        self.scroolView.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.scroolView.layer.shadowOpacity = 0.8
        if checkList != nil{
            self.checkListDes.text = checkList!.listDescription
            self.tittleLabel.text = checkList!.tittle
//            self.checkListImageView.image = ImageWorker.loadImageData(fileName: checkList!.imagePath!)
        }
        if checkList?.hasItems != nil{
            checkListItems = Array((checkList?.hasItems)!) as! [ListItem]
            print(checkListItems)
            self.checkListItemTableView.reloadData()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = scrollView.contentOffset.x / UIScreen.main.bounds.width
        print(pageNumber)
        pagecontrol.currentPage = Int(pageNumber)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checkListItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "checkListItemCell", for: indexPath) as! CheclistItemsTableViewCell
        let checkListItems = self.checkListItems[indexPath.row]
        if checkListItems.imagePath != nil {
            cell.checkListImage.image = ImageWorker.loadImageData(fileName: checkListItems.imagePath!)
        }
        cell.tittleLabel.text = checkListItems.animalName!
        cell.tickboxImageView.isHighlighted = checkListItems.found
        return cell
    }

}

extension UILabel {
    
    // Pass value for any one of both parameters and see result
    func setLineSpacing(lineSpacing: CGFloat = 0.0, lineHeightMultiple: CGFloat = 0.0) {
        
        guard let labelText = self.text else { return }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        
        let attributedString:NSMutableAttributedString
        if let labelattributedText = self.attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelattributedText)
        } else {
            attributedString = NSMutableAttributedString(string: labelText)
        }
        
        // Line spacing attribute
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        
        self.attributedText = attributedString
    }
}

