//
//  ContactsDownloader.swift
//  swtec-ios-contacts
//
//  Created by Kulagin Stepan on 3/25/21.
//

import Foundation

class ContactsDownloaderOperation: Operation {
    let repository: ContactsRepository
    
    init(_ repository: ContactsRepository) {
        self.repository = repository
    }
    
    override func main() {
        if isCancelled {
            return
        }
        do {
            try repository.getContacts()
        } catch {
            print("Something went wrong while loading contacts: \(error)")
        }
    }
}
