//
//  ContactListViewController.swift
//  swtec-ios-contacts
//
//  Created by Kulagin Stepan on 3/28/21.
//

import Foundation
import UIKit

protocol ContactListDisplayLogic: AnyObject {
    func displayContacts(viewModel: ContactList.ShowContacts.ViewModel)
}

final class ContactListViewController: UIViewController, ContactListDisplayLogic {
    var interactor: ContactListBusinessLogic?
    var router: (ContactListRoutingLogic & ContactListDataPassing)?

    var displayedContacts = [ContactList.ShowContacts.ViewModel.DisplayedContact]()
    
    @IBOutlet private var tableView: UITableView!

    // MARK: Object lifecycle

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: - Setup

    private func setup() {
        let viewController = self
        let interactor = ContactListInteractor()
        let presenter = ContactListPresenter()
        let router = ContactListRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchContacts()
    }

    // MARK: - Private

    private func fetchContacts() {
        let request = ContactList.ShowContacts.Request()
        interactor?.showContacts(request: request)
    }

    // MARK: - ContactListDisplayLogic

    func displayContacts(viewModel: ContactList.ShowContacts.ViewModel) {
        displayedContacts = viewModel.displayedContacts
        tableView.reloadData()
    }
}

// MARK: - UITableDataSource

extension ContactListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedContacts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "contcactListCell") {

            let contact = displayedContacts[indexPath.row]

            cell.textLabel?.text = contact.fullName

            return cell
        }

        return UITableViewCell()
    }
}
