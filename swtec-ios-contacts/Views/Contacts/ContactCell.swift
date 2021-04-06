//
//  ContactCell.swift
//  swtec-ios-contacts
//
//  Created by Kulagin Stepan on 4/5/21.
//

import Foundation
import UIKit

class ContactCell : UITableViewCell {
   
    @IBOutlet var nameTextLabel: UILabel!
    
    @IBOutlet var phoneTextLabel: UILabel!
    
    @IBOutlet var avatarView: AvatarView!
    
    @IBOutlet var avatarImageView: UIImageView!
    
    override func prepareForReuse() {
        avatarView.setNeedsDisplay()
        avatarImageView.isHidden = true
        avatarView.isHidden = true
        super.prepareForReuse()
    }
}
