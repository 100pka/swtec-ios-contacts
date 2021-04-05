//
//  ContactsDownloaderOperation.swift
//  swtec-ios-contacts
//
//  Created by Kulagin Stepan on 4/5/21.
//

import Foundation

class ContactsDownloaderOperation: Operation {
    let repository: ContactsRepository
    var contacts: [Contact] = []
    
    init(_ repository: ContactsRepository) {
        self.repository = repository
    }
    
    override func main() {
        if isCancelled {
            return
        }
        do {
            contacts = try repository.getContacts()
        } catch {
            print("Something went wrong while loading contacts: \(error)")
        }
    }
}
