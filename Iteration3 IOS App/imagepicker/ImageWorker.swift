//
//  ImageWorker.swift
//  imagepicker
//
//  Created by 唐茂宁 on 21/4/19.
//  Copyright © 2019 Sara Robinson. All rights reserved.
//


import UIKit
import CoreData

class ImageWorker{
    
    /// Save a image use .jpg extensions and the file path will be returned.
    ///
    /// - Parameters:
    ///   - image: The image file need to be saved.
    ///   - name: Filename.
    /// - Returns: The full path of the file.
    static func saveImage(image:UIImage,name:String) -> String{
        var data = Data()
        var fileName = ""
        data = image.jpegData(compressionQuality:0.8)!
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                       .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent("\(name)") {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
            fileName = "\(name)"
        }
        return fileName
    }
    
    
    /// Load a image by calling this method with the file path.
    ///
    /// - Parameter fileName: The icon image file need to be saved.
    /// - Returns: The file's full path.
    static func loadImageData(fileName: String) -> UIImage? {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                       .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent(fileName) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            let fileData = fileManager.contents(atPath: filePath)
            let image = UIImage(data: fileData!)!
            return image
        }
        return nil
    }
    
    /// Resize a image for using it as map maker.
    ///
    /// - Parameter icon: Animal icon image.
    /// - Returns: Resized image.
    static func makePin(icon:UIImage) -> UIImage{
        let pinImage = icon
        let size = CGSize(width: 30, height: 30)
        UIGraphicsBeginImageContext(size)
        pinImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage!
    }
}

extension UIImage {
    
    func resize(maxWidthHeight : Double)-> UIImage? {
        
        let actualHeight = Double(size.height)
        let actualWidth = Double(size.width)
        var maxWidth = 0.0
        var maxHeight = 0.0
        
        if actualWidth > actualHeight {
            maxWidth = maxWidthHeight
            let per = (100.0 * maxWidthHeight / actualWidth)
            maxHeight = (actualHeight * per) / 100.0
        }else{
            maxHeight = maxWidthHeight
            let per = (100.0 * maxWidthHeight / actualHeight)
            maxWidth = (actualWidth * per) / 100.0
        }
        
        let hasAlpha = true
        let scale: CGFloat = 0.0
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: maxWidth, height: maxHeight), !hasAlpha, scale)
        self.draw(in: CGRect(origin: .zero, size: CGSize(width: maxWidth, height: maxHeight)))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
    }
    
}

