//
//  Contact.swift
//  swtec-ios-contacts
//
//  Created by Kulagin Stepan on 3/29/21.
//

import Foundation

final class Contact {
    let id: String
    var firstName: String
    var lastName: String
    var phone: String
    var email: String
    
    init(firstName: String = "",
         lastName: String = "",
         phone: String = "",
         email: String = "",
         id: String = UUID().uuidString) {

        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.phone = phone
        self.email = email
    }
}
