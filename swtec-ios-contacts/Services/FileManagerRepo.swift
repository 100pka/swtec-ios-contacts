//
//  FileManagerRepo.swift
//  swtec-ios-contacts
//
//  Created by Kulagin Stepan on 4/2/21.
//

import Foundation

class FileManagerRepo: ContactsRepository {
    
    private enum Identifiers {
        static let fileName = "contacts.json"
    }
    
    private let fileManager = FileManager.default
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    private var contacts: [Contact] = []
    
    init() {
        decoder = JSONDecoder()
        encoder = JSONEncoder()
        if let path = fileManager.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last?.appendingPathComponent(Identifiers.fileName),
           !fileManager.fileExists(atPath: path.path) {
            fileManager.createFile(atPath: path.path, contents: nil, attributes: nil)
        }
    }
    
    func getContacts() throws -> [Contact] {
        
        if !contacts.isEmpty {
            return contacts
        }
        
        guard let path = fileManager.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last?.appendingPathComponent(Identifiers.fileName)
        else {
            throw ContactsListError.runtimeError("Error while getting path")
        }
        let data = try Data(contentsOf: path, options: .mappedIfSafe)
        self.contacts = try self.decoder.decode([Contact].self, from: data)
            .sorted{ $0.firstName.lowercased() < $1.firstName.lowercased() }
        if contacts.isEmpty {
            throw ContactsListError.runtimeError("Empty contacts file")
        }
        return contacts
    }
    
    func add(contact: Contact) throws {
        contacts.append(contact)
        try saveContactsOnDisk()
    }
    
    func delete(contact: Contact) throws {
        let index = contacts.firstIndex{ $0.recordId == contact.recordId }
        guard let index = index else {
            return
        }
        self.contacts.remove(at: index)
        try saveContactsOnDisk()
    }
    
    func update(contact: Contact) throws {
        let index = contacts.firstIndex{ $0.recordId == contact.recordId }
        guard let index = index else {
            return
        }
        contacts[index] = contact
        try saveContactsOnDisk()
    }
    
    func addAll(contacts: [Contact]) throws {
        self.contacts.removeAll()
        self.contacts.append(contentsOf: contacts)
        try saveContactsOnDisk()
    }
    
    func clear() throws {
        contacts.removeAll()
        try saveContactsOnDisk()
    }
    
    private func saveContactsOnDisk() throws {
        if let jsonData = try? encoder.encode(self.contacts),
           let path = fileManager.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last?.appendingPathComponent(Identifiers.fileName) {
            do {
                try jsonData.write(to: path)
            } catch {
                throw ContactsListError.runtimeError("Error while writing into file")
            }
        }
    }
}
