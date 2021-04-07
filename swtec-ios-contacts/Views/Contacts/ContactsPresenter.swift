//
//  ContactsPresenter.swift
//  ContactsDemo
//
//  Created by Artem Goncharov on 29.03.2021.
//

import Foundation

class ContactsPresenter {
    
    private var gistContactsRepository: ContactsRepository!
    private var fileManagerContactsRepository: ContactsRepository!
    private var callHistoryRepository: CallHistoryRepository!
    private var birthdayNotificationService: BirthdayNotificationService!
    private let operationQueue: OperationQueue = OperationQueue()
    weak var view: ContactsView?

    init(contactsRepository: ContactsRepository, fileManagerContactsRepository: ContactsRepository,callHistoryRepository: CallHistoryRepository, birthdayNotificationService: BirthdayNotificationService) {
        self.gistContactsRepository = contactsRepository
        self.fileManagerContactsRepository = fileManagerContactsRepository
        self.callHistoryRepository = callHistoryRepository
        self.birthdayNotificationService = birthdayNotificationService
    }
}

extension ContactsPresenter: ContactsViewOutput {
    func viewOpened() {
        view?.showProgress()
        async { [weak self] in
            
            guard let self = self else {
                return
            }
            
            defer {
                asyncMain {
                    self.view?.hideProgress()
                }
            }
            
            do {
                let contacts = try self.fileManagerContactsRepository.getContacts()
                asyncMain {
                    self.view?.showContacts(contacts)
                    self.birthdayNotificationService.setNotifications(contacts: contacts)
                }
            } catch {
                do {
                    let contacts = try self.gistContactsRepository.getContacts()
                    try self.fileManagerContactsRepository.addAll(contacts: contacts)
                    asyncMain {
                        self.view?.showContacts(contacts)
                        self.birthdayNotificationService.setNotifications(contacts: contacts)
                    }
                } catch {
                    asyncMain {
                        self.view?.showError(error)
                    }
                }
            }
        }
    }
    
    func updateWithOperationQueue() {
        view?.showProgress()
        let downloader = ContactsDownloaderOperation(gistContactsRepository)
        downloader.completionBlock = {
            if downloader.isCancelled {
                return
            }
            asyncMain {
                self.view?.showContacts(downloader.contacts)
                self.birthdayNotificationService.setNotifications(contacts: downloader.contacts)
                self.view?.hideProgress()
            }
        }
        operationQueue.addOperation(downloader)
    }
    
    func contactPressed(_ contact: Contact) {
        makeCall(to: contact)
    }
    
    func makeCall(to contact: Contact) {
        do {
            try callHistoryRepository.add(record: CallRecord(timestamp: Date(),
                                                             phone: contact.phone))
        } catch {
            view?.showError(error)
        }
        guard let phoneUrl = URL(string: "tel://" + contact.phone)
        else {
            return
        }
        view?.call(phoneUrl: phoneUrl)
    }
    
    func newContactAdded(_ contact: Contact) {
        do {
            try fileManagerContactsRepository.add(contact: contact)
        } catch {
            view?.showError(error)
        }
        view?.reloadContacts()
    }
    
    func updateContact(_ contact: Contact) {
        do {
            try fileManagerContactsRepository.update(contact: contact)
        } catch {
            view?.showError(error)
        }
        view?.reloadContacts()
    }
    
    func deleteContact(_ contact: Contact) {
        do {
            try fileManagerContactsRepository.delete(contact: contact)
        } catch {
            view?.showError(error)
        }
        view?.reloadContacts()
    }
    
    func clear() {
        do {
            try fileManagerContactsRepository.clear()
            try gistContactsRepository.clear()
        } catch {
            view?.showError(error)
        }
        view?.reloadContacts()
    }
}
