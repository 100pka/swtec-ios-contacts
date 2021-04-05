//
//  BirthdayNotificationService.swift
//  swtec-ios-contacts
//
//  Created by Kulagin Stepan on 4/4/21.
//

import Foundation
import UserNotifications

protocol BirthdayNotificationService {
    func setNotifications(contacts: [Contact])
}

class BirthdayNotificationServiceImplementation: BirthdayNotificationService {
    
    private enum Identifiers {
        static let title = "Birthday Notification"
    }
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    func setNotifications(contacts: [Contact]) {
        for contact in contacts {
            if let birthday = contact.birthday {
                let content = UNMutableNotificationContent()
                content.title = Identifiers.title
                content.body = "\(contact.firstName) \(contact.lastName)"
                content.sound = .default
                content.badge = 1
                let triggerDate = Calendar.current.dateComponents([.month, .day], from: birthday)
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
                let request = UNNotificationRequest(identifier: contact.recordId, content: content, trigger: trigger)
                notificationCenter.add(request) { error in
                    if let error = error {
                        print("Error \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
}
