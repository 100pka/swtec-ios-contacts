//
//  ContactListPresenter.swift
//  swtec-ios-contacts
//
//  Created by Kulagin Stepan on 3/28/21.
//

import Foundation
import UIKit

protocol ContactListPresentationLogic {
    func presentContacts(response: ContactList.ShowContacts.Response)
}

final class ContactListPresenter: ContactListPresentationLogic {
    weak var viewController: ContactListDisplayLogic?
    
    // MARk: - ContactListPresentationLogic
    
    func presentContacts(response: ContactList.ShowContacts.Response) {
        let mapped = response.contacts.map {
            ContactList
                .ShowContacts
                .ViewModel
                .DisplayedContact(firstName: $0.firstName,
                                  lastName: $0.lastName,
                                  phone: $0.phone)
        }
        
        let viewModel = ContactList.ShowContacts.ViewModel(displayedContacts: mapped)
        viewController?.displayContacts(viewModel: viewModel)
    }
}
