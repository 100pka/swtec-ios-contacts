//
//  ContactListWorker.swift
//  swtec-ios-contacts
//
//  Created by Kulagin Stepan on 3/28/21.
//

import Foundation
import UIKit

class ContactListWorker {
    func getContacts() -> [DBContact] {
        return DBService.shared.getContacts()
    }
}