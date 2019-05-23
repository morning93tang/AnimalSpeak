//
//  ListItem+CoreDataProperties.swift
//  
//
//  Created by 唐茂宁 on 7/5/19.
//
//

import Foundation
import CoreData


extension ListItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ListItem> {
        return NSFetchRequest<ListItem>(entityName: "ListItem")
    }

    @NSManaged public var animalName: String?
    @NSManaged public var found: Bool
    @NSManaged public var imagePath: String?
    @NSManaged public var unique: Bool
    @NSManaged public var belongsToCheckList: CheckList?
    @NSManaged public var hasEntities: NSSet?

}

// MARK: Generated accessors for hasEntities
extension ListItem {

    @objc(addHasEntitiesObject:)
    @NSManaged public func addToHasEntities(_ value: ImageEntity)

    @objc(removeHasEntitiesObject:)
    @NSManaged public func removeFromHasEntities(_ value: ImageEntity)

    @objc(addHasEntities:)
    @NSManaged public func addToHasEntities(_ values: NSSet)

    @objc(removeHasEntities:)
    @NSManaged public func removeFromHasEntities(_ values: NSSet)

}
