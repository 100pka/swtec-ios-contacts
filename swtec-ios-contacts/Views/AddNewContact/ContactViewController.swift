//
//  AddContactViewController.swift
//  swtec-ios-contacts
//
//  Created by Kulagin Stepan on 3/19/21.
//

import Foundation
import UIKit
import ContactsUI

class ContactViewController : CNContactViewController {
    
    var onResult: ((Contact) -> Void)?
    var contactForUpdateId: String?

}

extension ContactViewController: CNContactViewControllerDelegate {
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        guard let contact = contact,
              var newContact = Contact(contact: contact) else {
            return
        }
        if let contactForUpdateId = contactForUpdateId {
            newContact = Contact(recordId: contactForUpdateId, firstName: newContact.firstName, lastName: newContact.lastName, phone: newContact.phone, birthday: newContact.birthday)
        }
        onResult?(newContact)
        self.navigationController?.popViewController(animated: true)
    }
}


extension Contact {
    var contactValue: CNContact {
        let contact = CNMutableContact()
        contact.givenName = firstName
        contact.familyName = lastName
        contact.phoneNumbers.append(CNLabeledValue<CNPhoneNumber>(
                                        label: CNLabelPhoneNumberMain,
                                        value: CNPhoneNumber(stringValue: phone)))
        if let birthday = birthday {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .calendar], from: birthday)
            contact.birthday = components
        }
        return contact.copy() as! CNContact
    }
    
    init?(contact: CNContact) {
        let recordId = UUID().uuidString
        let firstName = contact.givenName
        let lastName = contact.familyName
        let phone = contact.phoneNumbers.first?.value.stringValue ?? ""
        let birthday = contact.birthday?.date
        self.init(recordId: recordId, firstName: firstName, lastName: lastName, phone: phone, birthday: birthday)
    }
}
