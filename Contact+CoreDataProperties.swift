//
//  Contact+CoreDataProperties.swift
//  swtec-ios-contacts
//
//  Created by Kulagin Stepan on 3/25/21.
//
//

import Foundation
import CoreData

@objc(Contact)
public class Contact : NSManagedObject, Codable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Contact> {
        return NSFetchRequest<Contact>(entityName: "Contact")
    }

    @NSManaged public var email: String?
    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var phone: String?

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        do {
            try container.encode(firstName, forKey: .firstName)
            try container.encode(lastName, forKey: .lastName)
            try container.encode(phone, forKey: .phone)
            try container.encode(email, forKey: .email)
        } catch {
            print("error while encoding NSManagedObject Contact")
        }
    }
    
    public required convenience init(from decoder: Decoder) throws {
        guard let contextUserInfoKey = CodingUserInfoKey.context,
              let managedObjectContext = decoder.userInfo[contextUserInfoKey] as? NSManagedObjectContext,
              let entity = NSEntityDescription.entity(forEntityName: "Contact", in: managedObjectContext) else {
            fatalError("error while decoding NSManagedObject Contact")
        }
        self.init(entity: entity, insertInto: managedObjectContext)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            self.firstName = try container.decode(String.self, forKey: .firstName)
            self.lastName = try container.decode(String.self, forKey: .lastName)
            self.phone = try container.decode(String.self, forKey: .phone)
            self.email = try container.decode(String.self, forKey: .email)
        } catch {
            print("error while decoding NSManagedObject Contact")
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case firstName = "firstname"
        case lastName = "lastname"
        case phone = "phone"
        case email = "email"
    }
}

extension Contact : Identifiable {

}

extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "context")
}
