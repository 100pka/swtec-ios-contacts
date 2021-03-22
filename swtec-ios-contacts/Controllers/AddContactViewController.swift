//
//  AddContactViewController.swift
//  swtec-ios-contacts
//
//  Created by Kulagin Stepan on 3/19/21.
//

import Foundation
import UIKit


class AddContactViewController: UIViewController {
    
    @IBOutlet var nameTextField: UITextField!
    
    @IBOutlet var phoneNumberTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        guard let newName = nameTextField.text,
              !newName.isEmpty
        else {
            nameTextField.placeholder = "Incorrect name"
            return
        }
        
        guard let newPhone = phoneNumberTextField.text,
              newPhone.isValidPhone()
        else {
            phoneNumberTextField.text = ""
            phoneNumberTextField.placeholder = "Incorrect number"
            return
        }
    
        NotificationCenter.default.post(name: ContactsListViewController.notificationCenter, object: nil, userInfo: ["name": newName, "phone": newPhone])
        navigationController?.popViewController(animated: true)
    }
}
