//
//  PhoneContact.swift
//  MateflickPhotobank
//
//  Created by Panda on 7/11/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit

import Foundation
import ContactsUI

class PhoneContact: NSObject {
    
    var name: String?
    var avatarData: Data?
    var phoneNumber: [String] = [String]()
    var email: [String] = [String]()
    var isSelected: Bool = false
    var isInvited = false
    
    init(contact: CNContact) {
        name        = contact.givenName + " " + contact.familyName
        avatarData  = contact.thumbnailImageData
        for phone in contact.phoneNumbers {
            phoneNumber.append(phone.value.stringValue)
        }
        for mail in contact.emailAddresses {
            email.append(mail.value as String)
        }
    }
    
    override init() {
        super.init()
    }
}
