//
//  Item+CoreDataProperties.swift
//  AtenaViewer
//
//  Created by gikoha on 2022/12/10.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var addressCode: String?
    @NSManaged public var atxBaseYear: Int32
    @NSManaged public var emailItem: String?
    @NSManaged public var firstName: String?
    @NSManaged public var fullAddress: String?
    @NSManaged public var furiFirstName: String?
    @NSManaged public var furiLastName: String?
    @NSManaged public var id: Int32
    @NSManaged public var lastName: String?
    @NSManaged public var memo: String?
    @NSManaged public var nameOfFamily1: String?
    @NSManaged public var nameOfFamily2: String?
    @NSManaged public var nameOfFamily3: String?
    @NSManaged public var nyCardHistory: String?
    @NSManaged public var phoneItem: String?
    @NSManaged public var printFlag: Int16
    @NSManaged public var selectedFlag: Int16
    @NSManaged public var suffix: String?
    @NSManaged public var suffix1: String?
    @NSManaged public var suffix2: String?
    @NSManaged public var suffix3: String?

}

extension Item : Identifiable {

}
