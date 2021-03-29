//
//  ContactsRepository.swift
//  swtec-ios-contacts
//
//  Created by Kulagin Stepan on 3/24/21.
//

import Foundation
import Dispatch
import CoreData
import UIKit

protocol ContactsRepository {
    func getContacts() throws -> [NSManagedObject]
}

enum ConstantsEnum {
    static let contactsURL = "https://gist.githubusercontent.com/artgoncharov/d257658423edd46a9ead5f721b837b8c/raw/c38ace33a7c871e4ad3b347fc4cd970bb45561a3/contacts_data.json"
}

class GistContactsRepository: ContactsRepository {
    private let path: String
    private let context: NSManagedObjectContext
    init(path: String, managedContext: NSManagedObjectContext) {
        self.path = path
        self.context = managedContext
    }
    func getContacts() throws -> [NSManagedObject] {
        let sem = DispatchSemaphore(value: 0)
        guard let url = URL(string: path)
        else {
            throw ContactsListError.runtimeError("Incorrect URL")
        }
        let request = URLRequest(url: url)
        var result: [NSManagedObject] = []
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            defer {
                sem.signal()
            }
            guard error == nil, let data = data else {
                return
            }
            
            let decoder = JSONDecoder()
            decoder.userInfo[CodingUserInfoKey.context!] = self.context
        
            do {
                result = try decoder.decode([DBContact].self, from: data)
                do {
                    try self.context.save()
                } catch let error as NSError {
                    print("Couldn't save data \(String(describing: error)), \(String(describing: error.userInfo))")
                }
            } catch let error as NSError {
                print("Couldn't decode json \(String(describing: error)), \(String(describing: error.userInfo))")
            }
        }
        task.resume()

        if sem.wait(timeout: .now() + 15) == .timedOut {
            print("Request is timed out")
            return [NSManagedObject]()
        }
        return result
    }
}
