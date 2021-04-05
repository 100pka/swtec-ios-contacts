//
//  TabBarController.swift
//  swtec-ios-contacts
//
//  Created by Kulagin Stepan on 4/2/21.
//

import Foundation
import UIKit

class TabBarController: UITabBarController {
    
    private enum Identifiers {
        static let startTab = "start_tab"
    }
    
    var freshLaunch = true
    
    override func viewWillAppear(_ animated: Bool) {
        if freshLaunch {
            freshLaunch = false
            
            let page = UserDefaults.standard.integer(forKey: Identifiers.startTab)
            self.selectedIndex = page
        }
    }
}
