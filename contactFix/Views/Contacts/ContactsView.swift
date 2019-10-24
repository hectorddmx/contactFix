//
//  ContactsView.swift
//  contactFix
//
//  Created by Hector De Diego on 22/10/19.
//  Copyright © 2019 dediego. All rights reserved.
//

import SwiftUI
import Contacts
import os

class ContactStore: ObservableObject {
    @Published var contacts: [CNContact] = []
    @Published var error: Error? = nil
    
    func fetch() {
        os_log("Fetching contacts")
        do {
            let store = CNContactStore()
            let keysToFetch = [
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactMiddleNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor,
                CNContactImageDataAvailableKey as CNKeyDescriptor,
                CNContactImageDataKey as CNKeyDescriptor,
                CNContactPhoneNumbersKey as CNKeyDescriptor,
                CNContactEmailAddressesKey as CNKeyDescriptor,
            ]
            os_log("Fetching contacts: now")
            let containerId = store.defaultContainerIdentifier()
            // Fix predicate to only gring contacts that have phone numbers
            let predicate = CNContact.predicateForContactsInContainer(withIdentifier: containerId)
            let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
            os_log("Fetching contacts: succesfull with count = %d", contacts.count)
            self.contacts = contacts
        } catch {
            os_log("Fetching contacts: failed with %@", error.localizedDescription)
            self.error = error
        }
    }
}

struct ContactsView: View {
    
    @EnvironmentObject var store: ContactStore
    
    var body: some View {
        VStack{
            Text("Contacts")
            if store.error == nil {
                ContactsList(contacts: store.contacts).onAppear{
                    DispatchQueue.main.async {
                        self.store.fetch()
                    }
                }
            } else {
                Text("error: \(store.error!.localizedDescription)")
            }
        }.navigationBarTitle(
            Text("Contact list")
        )
    }
}

struct ContactsList: View {
    
    var contacts: [CNContact]
    
    var body: some View {
        List(contacts, id:\.identifier) { (contact: CNContact) in
            ContactRow(contact: contact)
        }
    }
}

struct ContactRow: View {
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
        }
        .frame(
            minWidth: 0, maxWidth: .infinity,
            minHeight: 0, maxHeight: .infinity,
            alignment: Alignment.topLeading
        ).background(contact.phoneNumbers.count == 0 ? Color.red : Color.clear)
            
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
    static var sampleContact: CNContact = {
        let contact = CNMutableContact()
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
    
    static var previews: some View {
        ContactRow(contact: sampleContact).previewLayout(.fixed(width: 400, height: 170))
    }
}

struct ContactsList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContactsList(contacts: [
                {
                    let contact = CNMutableContact()
                    contact.givenName = "John"
                    contact.familyName = "Appleseed"
                    contact.phoneNumbers = [
                        CNLabeledValue(
                            label:CNLabelPhoneNumberiPhone,
                            value:CNPhoneNumber(stringValue:"+52 1 55 55829010")
                        ),
                        CNLabeledValue(
                            label:CNLabelOther,
                            value:CNPhoneNumber(stringValue:"+52 1 55 55829010")
                        ),
                    ]
                    return contact
                }(),
                {
                    let contact = CNMutableContact()
                    contact.givenName = "Jennifer"
                    contact.familyName = "Appleseed"
                    contact.phoneNumbers = [
                        CNLabeledValue(
                            label:CNLabelPhoneNumberiPhone,
                            value:CNPhoneNumber(stringValue:"+52 1 55 55829010")
                        ),
                        CNLabeledValue(
                            label:CNLabelOther,
                            value:CNPhoneNumber(stringValue:"+52 1 55 55829010")
                        ),
                    ]
                    return contact
                }(),
            ])
        }
    }
}



extension CNContact: Identifiable {
    /// Resulting name of searching givenName, middleName, familyName
    var name: String {
        return [givenName, middleName, familyName].filter{ $0.count > 0}.joined(separator: " ")
    }
}

