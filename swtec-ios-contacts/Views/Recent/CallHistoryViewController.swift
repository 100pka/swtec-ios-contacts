//
//  CallHistoryViewController.swift
//  swtec-ios-contacts
//
//  Created by Kulagin Stepan on 4/1/21.
//

import UIKit

class CallHistoryViewController: UIViewController {

    private struct CallRecordViewRepresentation {
        let displayName: String
        let phone: String
        let timestamp: Date
    }
    private enum Identifiers {
        static let callHistoryCell = "recentCallCell"
    }
    
    @IBOutlet private var callHistoryTableView: UITableView!
    
    private var callHistoryRepository: CallHistoryRepository!
    private var contactsRepository: ContactsRepository!
    
    private var history: [CallRecordViewRepresentation] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contactsRepository = Services.factory.getFileManagerContactsRepository()
        callHistoryRepository = Services.factory.getCallHistoryRepository()
        
        callHistoryTableView.dataSource = self
        callHistoryTableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        do {
            let callRecords = try callHistoryRepository.getHistory()
            let contacts = try contactsRepository.getContacts()
            
            history = callRecords.map { record in
                
                let displayName: String
                if let contact = contacts.first(where: { $0.phone == record.phone }) {
                    displayName = "\(contact.firstName) \(contact.lastName)"
                } else {
                    displayName = ""
                }
                
                return CallRecordViewRepresentation(displayName: displayName,
                                                    phone: record.phone,
                                                    timestamp: record.timestamp)
            }
            
            callHistoryTableView.reloadData()
        } catch {
            showError(error)
        }
    }
    
    func showError(_ error: Error) {
        
    }
}

extension CallHistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        history.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "recentCallCell", for: indexPath) as! RecentCallCell
        
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        
        let record = history[indexPath.row]
        cell.nameTextLabel.text = record.displayName
        cell.phoneTextLabel.text = record.phone
        cell.timeTextLabel.text = formatter.string(from: record.timestamp)
        
        return cell
    }
}

extension CallHistoryViewController: UITableViewDelegate {
    
}
