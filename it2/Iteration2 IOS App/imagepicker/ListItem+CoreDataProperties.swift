//
//  ListItem+CoreDataProperties.swift
//  
//
//  Created by 唐茂宁 on 26/4/19.
//
//

import Foundation
import CoreData


extension ListItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ListItem> {
        return NSFetchRequest<ListItem>(entityName: "ListItem")
    }

    @NSManaged public var animalName: String?
    @NSManaged public var imagePath: String?
    @NSManaged public var unique: Bool
    @NSManaged public var found: Bool
    @NSManaged public var belongsToCheckList: CheckList?

}
