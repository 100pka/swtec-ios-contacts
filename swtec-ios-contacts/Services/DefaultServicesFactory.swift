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
        contacts = GistContactsRepo(url: URL(string: "https://gist.githubusercontent.com/artgoncharov/d257658423edd46a9ead5f721b837b8c/raw/c38ace33a7c871e4ad3b347fc4cd970bb45561a3/contacts_data.json")!)
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
