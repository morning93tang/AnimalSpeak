//
//  Record+CoreDataProperties.swift
//  
//
//  Created by 唐茂宁 on 28/4/19.
//
//

import Foundation
import CoreData


extension Record {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Record> {
        return NSFetchRequest<Record>(entityName: "Record")
    }

    @NSManaged public var record: String?

}
