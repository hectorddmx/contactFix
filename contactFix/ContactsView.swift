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

struct SelectContactOperationView: View {
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        NavigationLink(destination: ContactsViewOrError()) {
                            Image(systemName: "person.crop.circle")
                            Text("View your current contacts")
                        }
                    }
                    
                    Section(header:
                        Text("Convert contacts to only have 10 digits as the ")
                            .font(.subheadline)
                    ) {
                        NavigationLink(destination: ContactsViewOrError()) {
                            Image(systemName: "person.crop.circle.badge.checkmark")
                            Text("Fix contacts phone numbers")
                        }
                    }
                    
                    //                    Section {
                    //                        NavigationLink(destination: Text("Destination")) {
                    //                            Image(systemName: "person.crop.circle.badge.minus")
                    //                            Text("Remove duplicated contacts")
                    //                        }
                    //                    }
                }
            }
            .navigationBarTitle(Text("Contacts manager"))
        }
    }
}

class ContactStore: ObservableObject {
    @Published var contacts: [CNContact] = []
    @Published var error: Error? = nil

    func fetch() {
        os_log("Fetching contacts")
        do {
            let store = CNContactStore()
            let keysToFetch = [CNContactGivenNameKey as CNKeyDescriptor,
                               CNContactMiddleNameKey as CNKeyDescriptor,
                               CNContactFamilyNameKey as CNKeyDescriptor,
                               CNContactImageDataAvailableKey as CNKeyDescriptor,
                               CNContactImageDataKey as CNKeyDescriptor]
            os_log("Fetching contacts: now")
            let containerId = store.defaultContainerIdentifier()
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
                List(store.contacts) { (contact: CNContact) in
                    return Text(contact.name)
                }.onAppear{
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

struct ContactsViewOrError: View {
    var body: some View {
        ContactsView().environmentObject(ContactStore())
    }
}


struct ContactsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContactsViewOrError()
        }
    }
}

struct ContactsTab: View {
    var body: some View {
        SelectContactOperationView().tabItem {
            Text("Contacts")
            Image(systemName: "person.crop.circle")
        }.tag(1)
    }
}

struct SelectContactOperationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SelectContactOperationView()
        }
    }
}


extension CNContact: Identifiable {
    var name: String {
        return [givenName, middleName, familyName].filter{ $0.count > 0}.joined(separator: " ")
    }
}
