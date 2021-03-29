//
//  ContactListRouter.swift
//  swtec-ios-contacts
//
//  Created by Kulagin Stepan on 3/28/21.
//

import Foundation
import UIKit

@objc protocol ContactListRoutingLogic {
    func routeToViewContact()
    func routeToAddContact()
}

protocol ContactListDataPassing {
    var dataStore: ContactListDataStore? { get }
}

final class ContactListRouter: ContactListRoutingLogic, ContactListDataPassing {
    weak var viewController: ContactListViewController?
    var dataStore: ContactListDataStore?

    // MARK: Routing

    func routeToViewContact() {
        let storyboard = UIStoryboard(name: "Contact", bundle: .none)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "contactViewControl") as! ContactViewViewController
        var destinationDS = destinationVC.router!.dataStore!
        passDataToViewContact(source: dataStore!, destination: &destinationDS)
        navigateToViewContact(source: viewController!, destination: destinationVC)
    }

    func routeToAddContact() {
        let storyboard = UIStoryboard(name: "Contact", bundle: .none)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "addContactControl") as! AddContactViewController
        var destinationDS = destinationVC.router!.dataStore!
        passDataToAddContact(source: dataStore!, destination: &destinationDS)
        navigateToAddContact(source: viewController!, destination: destinationVC)
    }

    // MARK: - Navigation

    func navigateToAddContact(source: ContactListViewController, destination: AddContactViewController) {
        source.show(destination, sender: .none)
    }

    func navigateToViewContact(source: ContactListViewController, destination: ContactViewViewController) {
        source.show(destination, sender: .none)
    }

    // MARK: - Passing data

    func passDataToAddContact(source: ContactListDataStore, destination: inout AddContactDataStore) {
    }

    func passDataToViewContact(source: ContactListDataStore, destination: inout ContactViewDataStore) {
        let selectedRow = viewController?.tableView.indexPathForSelectedRow?.row
        destination.contact = source.contacts?[selectedRow!]
    }
}
