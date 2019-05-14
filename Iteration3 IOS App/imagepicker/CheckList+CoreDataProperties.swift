//
//  CheckList+CoreDataProperties.swift
//  
//
//  Created by 唐茂宁 on 7/5/19.
//
//

import Foundation
import CoreData


extension CheckList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CheckList> {
        return NSFetchRequest<CheckList>(entityName: "CheckList")
    }

    @NSManaged public var fouded: String?
    @NSManaged public var imagePath: String?
    @NSManaged public var lat: Double
    @NSManaged public var listDescription: String?
    @NSManaged public var long: Double
    @NSManaged public var tittle: String?
    @NSManaged public var total: String?
    @NSManaged public var videoLink: String?
    @NSManaged public var customized: Bool
    @NSManaged public var hasItems: NSSet?

}

// MARK: Generated accessors for hasItems
extension CheckList {

    @objc(addHasItemsObject:)
    @NSManaged public func addToHasItems(_ value: ListItem)

    @objc(removeHasItemsObject:)
    @NSManaged public func removeFromHasItems(_ value: ListItem)

    @objc(addHasItems:)
    @NSManaged public func addToHasItems(_ values: NSSet)

    @objc(removeHasItems:)
    @NSManaged public func removeFromHasItems(_ values: NSSet)

}
