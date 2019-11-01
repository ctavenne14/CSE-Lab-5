//
//  CityEntity+CoreDataProperties.swift
//  ctavenne-Lab5
//
//  Created by Cody Tavenner on 3/18/19.
//  Copyright © 2019 Cody Tavenner. All rights reserved.
//
//

import Foundation
import CoreData


extension CityEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CityEntity> {
        return NSFetchRequest<CityEntity>(entityName: "CityEntity")
    }

    @NSManaged public var name: String?
    @NSManaged public var details: String?
    @NSManaged public var picture: NSData?

}
