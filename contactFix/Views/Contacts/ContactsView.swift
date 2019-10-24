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

enum ContactFilterType: Int, CaseIterable, Identifiable {
    
    var id: Self { self }
    
    case all = 0
    case missingPhone
    case missingName
    case badPhoneFormat
    
    var text: some View {
        let _text: Text
        switch self {
        case .all:
            _text = Text("All")
        case .missingPhone:
            _text = Text("No Phone")
        case .missingName:
            _text = Text("No Name")
        case .badPhoneFormat:
            _text = Text("Bad Format")
        }
        return _text.tag(self)
    }
}

class ContactStore: ObservableObject {
    @Published var contacts: [CNContact] = []
    @Published var error: Error? = nil
    
    func fetch() {
        os_log("Fetching contacts")
        
        let store = CNContactStore()
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName) as CNKeyDescriptor,
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactMiddleNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactThumbnailImageDataKey as CNKeyDescriptor,
            CNContactImageDataAvailableKey as CNKeyDescriptor,
            CNContactImageDataKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor,
        ]
        
        var allContainers: [CNContainer] = []
        do {
            allContainers = try store.containers(matching: nil)
        } catch {
            self.error = error
            os_log("Error fetching containers")
        }
        
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)

            do {
                os_log("Fetching contacts: for container: %{PUBLIC}@", log: OSLog.default, type: .info, container.name)
                let containerResults = try store.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch)
                contacts.append(contentsOf: containerResults)
            } catch {
                os_log("Error fetching containers")
            }
        }
        os_log("Fetching contacts: succesfull with count = %d", contacts.count)
    }
}

struct ContactsView: View {
    
    @EnvironmentObject var store: ContactStore
    
    @State private var displayMode: ContactFilterType = .all
    
    var body: some View {
        VStack{
            Text("Contacts")
            
            Picker("Show all contacts?", selection: $displayMode) {
                ForEach(ContactFilterType.allCases, content: { type in
                    type.text
                })
            }.pickerStyle(SegmentedPickerStyle())
            
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

extension CNContact: Identifiable {
    /// Resulting name of searching givenName, middleName, familyName
    var name: String {
        return [givenName, middleName, familyName].filter{ $0.count > 0}.joined(separator: " ")
    }
}

