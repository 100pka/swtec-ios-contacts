//
//  Contact+CoreDataProperties.swift
//  swtec-ios-contacts
//
//  Created by Kulagin Stepan on 3/25/21.
//
//

import Foundation
import CoreData

@objc(DBContact)
public class DBContact : NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBContact> {
        return NSFetchRequest<DBContact>(entityName: "DBContact")
    }
    
    @NSManaged public var email: String?
    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var phone: String?
    @NSManaged public var id: String?
    
    func toContact() throws -> Contact {
        guard let newFirstName = firstName,
              let newLastName = lastName,
              let newPhone = phone,
              let newEmail = email,
              let newId = id
        else {
            throw ContactsListError.runtimeError("Error while getting Contact from DB")
        }
        return Contact(firstName: newFirstName, lastName: newLastName, phone: newPhone, email: newEmail, id: newId)
    }
    
    func fromContact(contact: Contact) {
        firstName = contact.firstName
        lastName = contact.lastName
        phone = contact.phone
        email = contact.phone
        id = contact.id
    }
}
    
