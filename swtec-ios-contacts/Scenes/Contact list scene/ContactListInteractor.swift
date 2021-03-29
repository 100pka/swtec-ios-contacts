//
//  ContactListInteractor.swift
//  swtec-ios-contacts
//
//  Created by Kulagin Stepan on 3/28/21.
//

import Foundation
import UIKit

protocol ContactListBusinessLogic {
    func showContacts(request: ContactList.ShowContacts.Request)
}

protocol ContactListDataStore {
    var contacts: [Contact]? { get }
}

final class ContactListInteractor: ContactListBusinessLogic, ContactListDataStore {
    var presenter: ContactListPresentationLogic?
    var worker: ContactListWorker = ContactListWorker()
    var contacts: [Contact]?
    
    // MARK: - ContactListBusinessLogic
    
    func showContacts(request: ContactList.ShowContacts.Request) {
        let contacts = worker.getContacts()
        self.contacts = contacts
        let response = ContactList.ShowContacts.Response(contacts: contacts)
        presenter?.presentContacts(response: response)
    }
}
