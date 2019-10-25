//
//  CNContact+Model.swift
//  contactFix
//
//  Created by Hector De Diego on 24/10/19.
//  Copyright © 2019 dediego. All rights reserved.
//

import Contacts
import SwiftUI

extension CNContact: Identifiable {
    /// Resulting name of searching givenName, middleName, familyName
    var name: String {
        return [givenName, middleName, familyName].filter{ $0.count > 0}.joined(separator: " ")
    }
    
    var contactImage: Image {
        let defaultImage: Image = Image(systemName: "person.crop.circle")
        if !self.imageDataAvailable {
            return defaultImage
        }
        guard
            let data = self.thumbnailImageData,
            let image = UIImage(data: data) else {
                return defaultImage
        }
        return Image(uiImage: image)
    }
    
    var prettyName: String {
        self.name.isEmpty ? "No name saved" : self.name
    }
    
    static var goodExample: CNContact = {
        let contact = CNMutableContact()
        contact.imageData = UIImage(named: "turtlerock")?.pngData()
        contact.givenName = "John"
        contact.familyName = "Appleseed"
        contact.emailAddresses = [
            CNLabeledValue(label: CNContactEmailAddressesKey, value: "jupiter@amail.com")
        ]
        contact.phoneNumbers = [
            CNLabeledValue(
                label:CNLabelPhoneNumberiPhone,
                value:CNPhoneNumber(stringValue:"+52 1 55 55555555")
            ),
            CNLabeledValue(
                label:CNLabelSchool,
                value:CNPhoneNumber(stringValue:"+52 1 55 55555555")
            ),
        ]
        return contact
    }()
    
    static var badExample: CNContact = {
        let contact = CNMutableContact()
        contact.imageData = nil
        return contact
    }()
}
