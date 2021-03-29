//
//  ContactListModels.swift
//  swtec-ios-contacts
//
//  Created by Kulagin Stepan on 3/28/21.
//

import Foundation
import UIKit

enum ContactList {
    // MARK: - Use cases
    
    enum ShowContacts {
        struct Request {
    
        }
        
        struct Response {
            var contacts: [Contact]
        }
        
        struct ViewModel {
            struct DisplayedContact {
                let firstName: String
                let lastName: String
                let phone: String
                
                var fullName: String {
                    return firstName + " " + lastName
                }
            }
            
            var displayedContacts: [DisplayedContact]
        }
    }
    
    enum AddContact {
        struct Request {

        }
        
        struct Response {
            
        }
        
        struct ViewModel {
            
        }
    }
}
