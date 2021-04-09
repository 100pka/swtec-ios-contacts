//
//  ContactsViewController.swift
//  ContactsDemo
//
//  Created by Artem Goncharov on 29.03.2021.
//

import UIKit
import ContactsUI
import SwiftyGif

class ContactsViewController: UIViewController {
    
    private enum Identifiers {
        static let contactCell = "contactCell"
        static let addNewContact = "addNewContact"
        static let errorTitle = "Error"
    }

    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var contactsTableView: UITableView!
    
    @IBOutlet var gcdButton: UIButton!
    @IBOutlet var operationQueueButton: UIButton!
    @IBOutlet var clearButton: UIBarButtonItem!
    @IBOutlet var addContactButton: UIBarButtonItem!
    
    private var output: ContactsViewOutput!
    private var contacts: [Contact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let presenter = ContactsPresenter(contactsRepository: Services.factory.getContactsRepository(),
                                         fileManagerContactsRepository: Services.factory.getFileManagerContactsRepository(), callHistoryRepository: Services.factory.getCallHistoryRepository(),
                                         birthdayNotificationService: Services.factory.getBirthdayNotificationService())
        presenter.view = self
        output = presenter
        contactsTableView.dataSource = self
        contactsTableView.delegate = self
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressedForUpdateContact(sender:)))
                self.view.addGestureRecognizer(longPressRecognizer)
            
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        output.viewOpened()
    }
    
    @IBAction func addContactPressed(_ sender: Any) {
        let newContactViewController = ContactViewController(forNewContact: nil)
        
        newContactViewController.delegate = newContactViewController
        newContactViewController.hidesBottomBarWhenPushed = true
        newContactViewController.onResult = { [weak self] contact in
            self?.output.newContactAdded(contact)
        }
        navigationController?.pushViewController(newContactViewController, animated: true)
    }

    
    @IBAction func clearPressed(_ sender: Any) {
        self.contacts.removeAll()
        self.output.clear()
    }
    
    @IBAction func gcdPressed(_ sender: Any) {
        self.contacts.removeAll()
        self.output.clear()
        self.output.viewOpened()
    }
    
    @IBAction func operationQueuePressed(_ sender: Any) {
        self.contacts.removeAll()
        self.output.clear()
        self.output.updateWithOperationQueue()
    }
    
    @objc func longPressedForUpdateContact(sender: UILongPressGestureRecognizer) {
            if sender.state == UIGestureRecognizer.State.began {
                let touchPoint = sender.location(in: contactsTableView)
                if let indexPath = contactsTableView.indexPathForRow(at: touchPoint)
                {
                    let contact = contacts[indexPath.row]
                    let newContactViewController = ContactViewController(for: contact.contactValue)
                    newContactViewController.contactForUpdateId = contact.recordId
                    newContactViewController.onResult = { [weak self] contact in
                        self?.output.updateContact(contact)
                    }
                    newContactViewController.delegate = newContactViewController
                    newContactViewController.hidesBottomBarWhenPushed = true
                    navigationController?.pushViewController(newContactViewController, animated: true)
                }
            }
    }
}

extension ContactsViewController: ContactsView {
    func showProgress() {
        contactsTableView.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        gcdButton.isEnabled = false
        operationQueueButton.isEnabled = false
        clearButton.isEnabled = false
        addContactButton.isEnabled = false
    }
    
    func hideProgress() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        contactsTableView.isHidden = false
        gcdButton.isEnabled = true
        operationQueueButton.isEnabled = true
        clearButton.isEnabled = true
        addContactButton.isEnabled = true
    }
    
    
    func showContacts(_ contacts: [Contact]) {
        self.contacts = contacts
        contactsTableView.reloadData()
    }
    
    func showError(_ error: Error) {
        let alert = UIAlertController(title: Identifiers.errorTitle, message: "\(error)", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: { action in
                                    self.hideProgress() })
        alert.addAction(cancel)
        self.present(alert, animated: true)
    }
    
    func reloadContacts() {
        contactsTableView.reloadData()
    }
    
    func call(phoneUrl: URL) {
        guard UIApplication.shared.canOpenURL(phoneUrl)
        else {
            return
        }
        UIApplication.shared.open(phoneUrl)
    }
}


extension ContactsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.contactCell, for: indexPath) as! ContactCell
        
        let contact = contacts[indexPath.row]
        
        
        cell.nameTextLabel?.text = "\(contact.firstName) \(contact.lastName)"
        cell.phoneTextLabel?.text = contact.phone
        
        if let photoUrl = contact.photoUrl,
           let url = URL(string: photoUrl)
        {
            cell.avatarView.isHidden = true
            cell.avatarImageView.isHidden = false
            cell.avatarImageView.setGifFromURL(url)
        }
        else {
            cell.avatarView.isHidden = false
            cell.avatarImageView.isHidden = true
            guard let firstLetter = contact.firstName.first?.uppercased(),
                  let secondLetter = contact.lastName.first?.uppercased()
            else {
                return cell
            }
            cell.avatarView.text = firstLetter + secondLetter
        }
        return cell
    }
}

extension ContactsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let contact = contacts[indexPath.row]
        output.contactPressed(contact)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let contact = contacts[indexPath.row]
            self.output.deleteContact(contact)
            contacts.remove(at: indexPath.row)
        }
    }
}



enum ContactsListError: Error {
    case runtimeError(String)
}
