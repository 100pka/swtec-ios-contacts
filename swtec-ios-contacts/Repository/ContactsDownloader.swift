//
//  ContactsDownloader.swift
//  swtec-ios-contacts
//
//  Created by Kulagin Stepan on 3/25/21.
//

import Foundation

class ContactsDownloader: Operation {
    let repository: ContactsRepository
    
    init(_ repository: ContactsRepository) {
        self.repository = repository
    }
    
    override func main() {
        if isCancelled {
            return
        }
        
        if (try? repository.getContacts()) != nil {
            return
        }
    }
}
