//
//  ContactsRepository.swift
//  ContactsDemo
//
//  Created by Artem Goncharov on 29.03.2021.
//

import Foundation


struct Contact : Codable {
    let recordId: String
    let firstName: String
    let lastName: String
    let phone: String
    var birthday: Date? = nil
    var photoUrl: String? = nil
}

struct ContactsData {
    let firstName: String
    let lastName: String
    let phone: String
}


protocol ContactsRepository {
    
    func getContacts() throws -> [Contact]
    
    func add(contact: Contact) throws
    func delete(contact: Contact) throws
    func update(contact: Contact) throws
    func addAll(contacts: [Contact]) throws
    func clear() throws
}

