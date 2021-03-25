//
//  ViewController.swift
//  swtec-ios-contacts
//
//  Created by Kulagin Stepan on 3/18/21.
//

import UIKit
import CoreData

class ContactsListViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    static let notificationCenter = Notification.Name("contactBookNotification")
    
    @IBOutlet var addButton: UIBarButtonItem!
    
    @IBOutlet var tableView: UITableView!
    let spinner = UIActivityIndicatorView(style: .large)
    
    var contacts: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundView = spinner
        spinner.hidesWhenStopped = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(saveNewContact(notification:)), name:ContactsListViewController.notificationCenter, object: nil)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressedForUpdateContact(sender:)))
        self.view.addGestureRecognizer(longPressRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        do {
            contacts = try fetchDataFromCoreData()
        } catch let error as NSError {
            print("Couldn't fetch \(String(describing: error)), \(String(describing: error.userInfo))")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)
        let contact = contacts[indexPath.row]
        
        if let fistName = contact.value(forKey: "firstName") as? String,
           let lastName = contact.value(forKey: "lastName") as? String {
            cell.textLabel?.text = fistName + " " + lastName
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteContactFromCoreData(indexPath: indexPath.row)
            do {
                contacts = try fetchDataFromCoreData()
            } catch let error as NSError {
                print("Couldn't fetch \(String(describing: error)), \(String(describing: error.userInfo))")
            }
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let phone = contacts[indexPath.row].value(forKeyPath: "phone") as? String,
              let name = contacts[indexPath.row].value(forKeyPath: "firstName") as? String,
              let phoneUrl = URL(string: "tel://" + phone),
              UIApplication.shared.canOpenURL(phoneUrl)
        else {
            return
        }
        saveNewCallToCoreData(newCallName: name, newCallTime: getTime())
        UIApplication.shared.open(phoneUrl)
    }

    @IBAction func clearContacts(_ sender: Any) {
        clearContactsData()
        do {
            contacts = try fetchDataFromCoreData()
        } catch let error as NSError {
            print("Couldn't fetch \(String(describing: error)), \(String(describing: error.userInfo))")
        }
        tableView.reloadData()
    }
    
    @IBAction func updateDataByGCD(_ sender: Any) {
        spinner.startAnimating()
        clearContactsData()
        do {
            contacts = try fetchDataFromCoreData()
        } catch let error as NSError {
            print("Couldn't fetch \(String(describing: error)), \(String(describing: error.userInfo))")
        }
        tableView.reloadData()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let contactsRepo = GistContactsRepository(path: ConstantsEnum.contactsURL, managedContext: appDelegate.persistentContainer.newBackgroundContext())
            
            DispatchQueue.global(qos: .utility).async {
                if (try? contactsRepo.getContacts()) != nil {
                    DispatchQueue.main.async {
                        do {
                            self.contacts = try self.fetchDataFromCoreData()
                        } catch let error as NSError {
                            print("Couldn't fetch \(String(describing: error)), \(String(describing: error.userInfo))")
                        }
                        self.tableView.reloadData()
                        self.spinner.stopAnimating()
                    }
                }
            }
        }
    }
    
    @IBAction func updateByOperationQueue(_ sender: Any) {
        spinner.startAnimating()
        clearContactsData()
        do {
            contacts = try fetchDataFromCoreData()
        } catch let error as NSError {
            print("Couldn't fetch \(String(describing: error)), \(String(describing: error.userInfo))")
        }
        tableView.reloadData()
        
        let downloadQueue = OperationQueue()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let contactsRepo = GistContactsRepository(path: ConstantsEnum.contactsURL, managedContext: appDelegate.persistentContainer.newBackgroundContext())
            let downloader = ContactsDownloader(contactsRepo)
            downloader.completionBlock = {
                if downloader.isCancelled {
                    return
                }
                DispatchQueue.main.async {
                    do {
                        self.contacts = try self.fetchDataFromCoreData()
                    } catch let error as NSError {
                        print("Couldn't fetch \(String(describing: error)), \(String(describing: error.userInfo))")
                    }
                    self.tableView.reloadData()
                    self.spinner.stopAnimating()
                }
            }
            downloadQueue.addOperation(downloader)
        }
        
    }
    
    // MARK: - New contact notification handler
    
    @objc func saveNewContact(notification: Notification) {
        guard let data = notification.userInfo as? [String: String], let newContactName = data["firstName"], let newContactPhone = data["phone"] else {
            return
        }
        
        saveNewContactToCoreData(newContactName: newContactName, newContactPhone: newContactPhone)
        
        self.tableView.reloadData()
    }
    
    // MARK: - Actions
    
    
    @objc func longPressedForUpdateContact(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.began {
            let touchPoint = sender.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint),
               let contact = contacts[indexPath.row] as? Contact {
                let alert = UIAlertController(title: "Update Contact", message: "", preferredStyle: .alert)
                
                let updateAction = UIAlertAction(title: "Update", style: .default, handler: {
                    (action) -> Void in
                    
                    guard let newNameField = alert.textFields?.first,
                          let newName = newNameField.text
                    else {
                        return
                    }
                    
                    guard let newPhoneField = alert.textFields?[1],
                          let newPhone = newPhoneField.text
                    else {
                        return
                    }
                    
                    self.updateData(newName: newName, newPhone: newPhone, newContact: contact)
                    do {
                        self.contacts = try self.fetchDataFromCoreData()
                    } catch let error as NSError {
                        print("Couldn't fetch \(String(describing: error)), \(String(describing: error.userInfo))")
                    }
                    self.tableView.reloadData()
                })
                
                alert.addTextField{
                    (textField: UITextField) in
                    textField.addTarget(self, action: #selector(self.alertNameTextChanged(sender:)), for: .editingChanged)
                    textField.text = "\(((contact.value(forKey: "firstName") as? String)) ?? "Enter Name")"
                }
                
                alert.addTextField{
                    (textField: UITextField) in
                    textField.addTarget(self, action: #selector(self.alertPhoneTextChanged(sender:)), for: .editingChanged)
                    textField.text = "\(((contact.value(forKey: "phone") as? String)) ?? "Enter Phone")"
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .default)
                alert.addAction(updateAction)
                alert.addAction(cancelAction)
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @objc private func alertNameTextChanged(sender: AnyObject) {
        guard let nameTextField = sender as? UITextField
        else {
            return
        }
        var responder: UIResponder = nameTextField
        while !(responder is UIAlertController) {
            guard let nextResponder = responder.next
            else {
                return
            }
            responder = nextResponder
        }
        
        let alert = responder as? UIAlertController
        guard let updateAction = alert?.actions[0]
        else {
            return
        }
        updateAction.isEnabled = (nameTextField.text != "")
    }
    
    @objc private func alertPhoneTextChanged(sender: AnyObject) {
        guard let phoneTextField = sender as? UITextField,
              let phone = phoneTextField.text
        else {
            return
        }
        var responder: UIResponder = phoneTextField
        while !(responder is UIAlertController) {
            guard let nextResponder = responder.next
            else {
                return
            }
            responder = nextResponder
        }
        
        let alert = responder as? UIAlertController
        guard let updateAction = alert?.actions[0]
        else {
            return
        }
        updateAction.isEnabled = (phone.isValidPhone())
    }
    
    // MARK: - Core Data Operations
    
    private func fetchDataFromCoreData() throws -> [NSManagedObject] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else {
            throw ContactsListError.runtimeError("Couldn't get AppDelegate")
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Contact")
        return try managedContext.fetch(fetchRequest)
    }
    
    private func clearContactsData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Contact")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try managedContext.execute(deleteRequest)
            try managedContext.save()
        } catch {
            // error
        }
    }
    
    private func saveNewContactToCoreData(newContactName name: String, newContactPhone phone: String) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Contact", in: managedContext)
        else {
            return
        }

        let contact = NSManagedObject(entity: entity, insertInto: managedContext)
        
        contact.setValue(name, forKeyPath: "firstName")
        contact.setValue(phone, forKeyPath: "phone")
        contact.setValue("", forKeyPath: "lastName")
        contact.setValue("", forKeyPath: "email")
        
        do {
            try managedContext.save()
            contacts.append(contact)
        } catch let error as NSError{
            print("Couldn't save \(String(describing: error)), \(String(describing: error.userInfo))")
        }
    }
    
    private func deleteContactFromCoreData(indexPath index: Int) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let contact = contacts[index] as? Contact
        else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.delete(contact)
        do {
            try managedContext.save()
        } catch let error as NSError{
            print("Couldn't delete \(String(describing: error)), \(String(describing: error.userInfo))")
        }
    }
    
    private func updateData(newName name: String, newPhone phone: String, newContact contact: Contact) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        contact.setValue(name, forKeyPath: "firstName")
        contact.setValue(phone, forKeyPath: "phone")
        do {
            try managedContext.save()
        } catch let error as NSError{
            print("Couldn't update \(String(describing: error)), \(String(describing: error.userInfo))")
        }
    }
    
    private func saveNewCallToCoreData(newCallName name: String, newCallTime time: String) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Call", in: managedContext)
        else {
            return
        }

        let call = NSManagedObject(entity: entity, insertInto: managedContext)
        
        call.setValue(name, forKeyPath: "name")
        call.setValue(time, forKeyPath: "time")
        print("\(name): \(time)")
        do {
            try managedContext.save()
        } catch let error as NSError{
            print("Couldn't save call \(String(describing: error)), \(String(describing: error.userInfo))")
        }
    }
    
    func getTime() -> String {
        let today = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: today)
    }
}

enum ContactsListError: Error {
    case runtimeError(String)
}

extension String {
    func isValidPhone() -> Bool {
            let phoneRegex = "^[0-9+]{0,1}+[0-9]{5,16}$"
            let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
            return phoneTest.evaluate(with: self)
        }
}

