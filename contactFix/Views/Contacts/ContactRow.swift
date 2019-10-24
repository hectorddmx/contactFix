//
//  ContactRow.swift
//  contactFix
//
//  Created by Hector De Diego on 24/10/19.
//  Copyright © 2019 dediego. All rights reserved.
//

import SwiftUI
import Contacts

struct ContactRow: View {
     @Environment(\.colorScheme) var colorScheme
    
    var strokeColor: Color {
        colorScheme == .dark ? .black : .white
    }
    
    var shadowColor: Color {
        colorScheme == .light ? .black : .white
    }
    
    var contact: CNContact
    var contactImage: Image {
        let defaultImage: Image = Image(systemName: "person.crop.circle")
        if !contact.imageDataAvailable {
            return defaultImage
        }
        guard
            let data = contact.thumbnailImageData,
            let image = UIImage(data: data) else {
                return defaultImage
        }
        return Image(uiImage: image)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            contactImage
                .resizable()
                .scaledToFill()
                .frame(width: 90, height: 90, alignment: .center)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(strokeColor, lineWidth: 4))
                .shadow(color: shadowColor.opacity(0.33), radius: 10)
                .padding(4)
            ContactInfo(contact: contact)
        }
    }
}

struct ContactInfo: View {
    var contact: CNContact
    
    var prettyName: String {
        contact.name.isEmpty ? "No name saved" : contact.name
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(prettyName).font(.headline)
            if contact.phoneNumbers.count != 0 {
                PhoneNumbersSection(phoneNumbers: contact.phoneNumbers)
            }
            if contact.emailAddresses.count != 0 {
                EmailAddressesSection(emailAddresses: contact.emailAddresses)
            }
            if contact.phoneNumbers.count == 0 && contact.emailAddresses.count == 0 {
                Text("No contact info found").fontWeight(.light)
            }
        }
        .frame(
            minWidth: 0, maxWidth: .infinity,
            minHeight: 0, maxHeight: .infinity,
            alignment: Alignment.topLeading
        )
    }
}

struct EmailRow: View {
    var email: CNLabeledValue<NSString>
    
    var prettyLabel: String {
        CNLabeledValue<NSString>
            .localizedString(forLabel: email.label ?? "default")
            .capitalized
    }
    
    var body: some View {
        HStack {
            Text("- \(prettyLabel):").font(.caption).bold()
            Text("\(email.value)").font(.caption)
        }
    }
}

struct PhoneRow: View {
    var phone: CNLabeledValue<CNPhoneNumber>
    var prettyLabel: String {
        return CNLabeledValue<CNPhoneNumber>
            .localizedString(forLabel: phone.label ?? "default")
            .capitalized
    }
    
    var body: some View {
        HStack {
            Text("- \(prettyLabel): ").font(.caption).bold()
            Text("\(phone.value.stringValue)").font(.caption)
        }
    }
}

struct PhoneNumbersSection: View {
    var phoneNumbers: [CNLabeledValue<CNPhoneNumber>]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Section(header:
                Text("Phone Numbers")
                    .font(.body)
                    .fontWeight(.light)
                    .padding([.top, .bottom], 10)
            ) {
                ForEach(phoneNumbers, id:\.identifier) { (phone: CNLabeledValue<CNPhoneNumber>) in
                    PhoneRow(phone: phone).padding(.leading, 8)
                }
            }
        }
    }
}

struct EmailAddressesSection: View {
    var emailAddresses: [CNLabeledValue<NSString>]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Section(header:
                Text("Emails")
                    .font(.body)
                    .fontWeight(.light)
                    .padding([.top, .bottom], 10)
            ) {
                ForEach(emailAddresses, id:\.identifier) { (email: CNLabeledValue<NSString> ) in
                    EmailRow(email: email).padding([.leading], 8)
                }
            }
        }
    }
}

struct ContactRow_Previews: PreviewProvider {
    static var goodContact: CNContact = {
        let contact = CNMutableContact()
        contact.imageData = UIImage(named: "turtlerock")?.pngData()
        contact.givenName = "John"
        contact.familyName = "Appleseed"
        contact.emailAddresses = [
            CNLabeledValue(label: CNContactEmailAddressesKey, value: "lecksfrawen@gmail.com")
        ]
        contact.phoneNumbers = [
            CNLabeledValue(
                label:CNLabelPhoneNumberiPhone,
                value:CNPhoneNumber(stringValue:"+52 1 55 55829010")
            ),
            CNLabeledValue(
                label:CNLabelSchool,
                value:CNPhoneNumber(stringValue:"+52 1 55 55829010")
            ),
        ]
        return contact
    }()
    
    static var badContact: CNContact = {
        let contact = CNMutableContact()
        contact.imageData = nil
        return contact
    }()
    
    static var previews: some View {
        Group {
            Group {
                ContactRow(contact: goodContact).previewLayout(.fixed(width: 400, height: 170))
                ContactRow(contact: badContact).previewLayout(.fixed(width: 400, height: 170))
            }.environment(\.colorScheme, .light)
                        
            Group {
                ContactRow(contact: goodContact).previewLayout(.fixed(width: 400, height: 170))
                ContactRow(contact: badContact).previewLayout(.fixed(width: 400, height: 170))
            }.environment(\.colorScheme, .dark)
            
        }
    }
}

