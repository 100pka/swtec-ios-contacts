//
//  ContactsView.swift
//  ContactsDemo
//
//  Created by Artem Goncharov on 29.03.2021.
//

import Foundation

protocol ContactsView: AnyObject {
    func showContacts(_ contacts: [Contact])
    func showError(_ error: Error)
    
    func showProgress()
    func hideProgress()
    
    func reloadContacts()
}

protocol ContactsViewOutput {
    func viewOpened()
    func contactPressed(_ contact: Contact)
    func newContactAdded(_ contact: Contact)
    func updateContact(_ contact: Contact)
    func deleteContact(_ contact: Contact)
    func clear()
    func updateWithOperationQueue()
}
