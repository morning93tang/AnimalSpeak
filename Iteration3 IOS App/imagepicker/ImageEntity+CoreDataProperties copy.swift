//
//  ImageEntity+CoreDataProperties.swift
//  
//
//  Created by 唐茂宁 on 13/5/19.
//
//

import Foundation
import CoreData


extension ImageEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageEntity> {
        return NSFetchRequest<ImageEntity>(entityName: "ImageEntity")
    }

    @NSManaged public var imagePath: String?
    @NSManaged public var lat: String?
    @NSManaged public var long: String?
    @NSManaged public var dateTime: String?
    @NSManaged public var isItem: ListItem?

}
