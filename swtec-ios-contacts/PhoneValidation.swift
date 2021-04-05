//
//  PhoneValidation.swift
//  swtec-ios-contacts
//
//  Created by Kulagin Stepan on 3/31/21.
//

import Foundation

extension String {
    func isValidPhone() -> Bool {
        let phoneRegex = "^[0-9+]{0,1}+[0-9]{5,16}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: self)
    }
}
