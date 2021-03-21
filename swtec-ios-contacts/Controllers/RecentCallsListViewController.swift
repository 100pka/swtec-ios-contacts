//
//  RecentCallsListViewController.swift
//  swtec-ios-contacts
//
//  Created by Kulagin Stepan on 3/21/21.
//

import UIKit
import CoreData

class RecentCallsListViewController : UIViewController  {
    
    @IBOutlet var callsListTableView: UITableView!
    
    var calls: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.callsListTableView.delegate = self
        self.callsListTableView.dataSource = self
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        do {
            calls = try fetchDataFromCoreData()
            calls.reverse()
            callsListTableView.reloadData()
        } catch let error as NSError {
            print("Couldn't fetch \(String(describing: error)), \(String(describing: error.userInfo))")
        }
    }
        
    private func fetchDataFromCoreData() throws -> [NSManagedObject] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else {
            throw ContactsListError.runtimeError("Couldn't get AppDelegate")
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Call")
        return try managedContext.fetch(fetchRequest)
    }
}

extension RecentCallsListViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        calls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recentCallCell", for: indexPath) as! RecentCallCell
        let call = calls[indexPath.row]
        
        cell.nameTextLabel.text = call.value(forKeyPath: "name") as? String
        cell.timeTextLabel.text = call.value(forKeyPath: "time") as? String
        
        return cell
    }
}

