//
//  DefaultServicesFactory.swift
//  ContactsDemo
//
//  Created by Artem Goncharov on 29.03.2021.
//

import Foundation

class DefaultServicesFactory: ServicesFactory {
    
    private var contacts: ContactsRepository
    private var fileManagerContacts: ContactsRepository
    private var callHistory: CallHistoryRepository
    private var birthdayNotificationService: BirthdayNotificationService
    
    init() {
        let repo = HardcodedRepo()
        contacts = GistContactsRepo(url: URL(string: "https://gist.githubusercontent.com/artgoncharov/61c471db550238f469ad746a0c3102a7/raw/590dcd89a6aa10662c9667138c99e4b0a8f43c67/contacts_data2.json")!)
        fileManagerContacts = FileManagerRepo()
        callHistory = repo
        birthdayNotificationService = BirthdayNotificationServiceImplementation()
    }
    
    func getContactsRepository() -> ContactsRepository {
        return contacts
    }
    
    func getCallHistoryRepository() -> CallHistoryRepository {
        return callHistory
    }
    
    func getFileManagerContactsRepository() -> ContactsRepository {
        return fileManagerContacts
    }
    
    func getBirthdayNotificationService() -> BirthdayNotificationService {
        return birthdayNotificationService
    }
}
