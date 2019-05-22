//
//  CBToast.swift
//
//  Acknowledge to bolagong(https://github.com/bolagong)
//  This Toast file is written by bolagong on GitHub at: https://github.com/bolagong/Toast
//

import UIKit

let main_width = UIScreen.main.bounds.size.width
let main_height = UIScreen.main.bounds.size.height

class CBToast: NSObject {
    
    
    class func showToastAction(message : NSString) {
        self.showToast(message: message, aLocationStr: "bottom", aShowTime: 2.0)
    }
    
    class func showToast(message : NSString?, aLocationStr : NSString?, aShowTime : TimeInterval) {
        if Thread.current.isMainThread {
            toastLabel = self.currentToastLabel()
            toastLabel?.removeFromSuperview()
            
            let AppDlgt = UIApplication.shared.delegate as! AppDelegate
            AppDlgt.window?.addSubview(toastLabel!)
            
            var width = self.stringText(aText: message, aFont: 16, isHeightFixed: true, fixedValue: 40)
            var height : CGFloat = 0
            if width > (main_width - 20) {
                width = main_width - 20
                height = self.stringText(aText: message, aFont: 16, isHeightFixed: false, fixedValue: width)
            }else{
                height = 40
            }
            
            var labFrame = CGRect.zero
            if aLocationStr != nil, aLocationStr == "top" {
                labFrame = CGRect.init(x: (main_width-width)/2, y: main_height*0.15, width: width, height: height)
            }else if aLocationStr != nil, aLocationStr == "bottom" {
                labFrame = CGRect.init(x: (main_width-width)/2, y: main_height*0.75, width: width, height: height)
            }else{
                //default-->center
                labFrame = CGRect.init(x: (main_width-width)/2, y: main_height*0.5, width: width, height: height)
            }
            toastLabel?.frame = labFrame
            toastLabel?.text = message as String?
            toastLabel?.alpha = 1
            UIView.animate(withDuration: aShowTime, animations: {
                toastLabel?.alpha = 0;
            })
        }else{
            DispatchQueue.main.async {
                self.showToast(message: message, aLocationStr: aLocationStr, aShowTime: aShowTime)
            }
            return
        }
    }
    
}

extension CBToast {
    
    static var toastView : UIView?
    class func currentToastView() -> UIView {
        objc_sync_enter(self)
        if toastView == nil {
            toastView = UIView.init()
            toastView?.backgroundColor = UIColor.darkGray
            toastView?.layer.masksToBounds = true
            toastView?.layer.cornerRadius = 5.0
            toastView?.alpha = 0
            
            let indicatorView = UIActivityIndicatorView.init(style: .whiteLarge)
            indicatorView.tag = 10
            indicatorView.hidesWhenStopped = true
            indicatorView.color = UIColor.white
            toastView?.addSubview(indicatorView)
        }
        objc_sync_exit(self)
        return toastView!
    }
    
    static var toastLabel : UILabel?
    class func currentToastLabel() -> UILabel {
        objc_sync_enter(self)
        if toastLabel == nil {
            toastLabel = UILabel.init()
            toastLabel?.backgroundColor = UIColor.darkGray
            toastLabel?.font = UIFont.systemFont(ofSize: 16)
            toastLabel?.textColor = UIColor.white
            toastLabel?.numberOfLines = 0;
            toastLabel?.textAlignment = .center
            toastLabel?.lineBreakMode = .byCharWrapping
            toastLabel?.layer.masksToBounds = true
            toastLabel?.layer.cornerRadius = 5.0
            toastLabel?.alpha = 0;
        }
        objc_sync_exit(self)
        return toastLabel!
    }
    
    static var toastViewLabel : UIView?
    class func currentToastViewLabel() -> UIView {
        objc_sync_enter(self)
        if toastViewLabel == nil {
            toastViewLabel = UIView.init()
            toastViewLabel?.backgroundColor = UIColor.darkGray
            toastViewLabel?.layer.masksToBounds = true
            toastViewLabel?.layer.cornerRadius = 5.0
            toastViewLabel?.alpha = 0
            
            let indicatorView = UIActivityIndicatorView.init(style: .whiteLarge)
            indicatorView.tag = 10
            indicatorView.hidesWhenStopped = true
            indicatorView.color = UIColor.white
            toastViewLabel?.addSubview(indicatorView)
            
            let aLabel = UILabel.init()
            aLabel.tag = 11
            aLabel.backgroundColor = toastViewLabel?.backgroundColor
            aLabel.font = UIFont.systemFont(ofSize: 16)
            aLabel.textColor = UIColor.white
            aLabel.textAlignment = .center
            aLabel.lineBreakMode = .byCharWrapping
            aLabel.layer.masksToBounds = true
            aLabel.layer.cornerRadius = 5.0
            aLabel.numberOfLines = 0;
            toastViewLabel?.addSubview(aLabel)
        }
        objc_sync_exit(self)
        return toastViewLabel!
    }
}

extension CBToast {
    
    class func stringText(aText : NSString?, aFont : CGFloat, isHeightFixed : Bool, fixedValue : CGFloat) -> CGFloat {
        var size = CGSize.zero
        if isHeightFixed == true {
            size = CGSize.init(width: CGFloat(MAXFLOAT), height: fixedValue)
        }else{
            size = CGSize.init(width: fixedValue, height: CGFloat(MAXFLOAT))
        }
        let resultSize = aText?.boundingRect(with: size, options: (NSStringDrawingOptions(rawValue: NSStringDrawingOptions.usesLineFragmentOrigin.rawValue | NSStringDrawingOptions.usesFontLeading.rawValue | NSStringDrawingOptions.truncatesLastVisibleLine.rawValue)), attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: aFont)], context: nil).size
        if isHeightFixed == true {
            return resultSize!.width + 20
        } else {
            return resultSize!.height + 20
        }
    }
}
