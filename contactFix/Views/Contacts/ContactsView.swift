//
//  ContactsView.swift
//  contactFix
//
//  Created by Hector De Diego on 22/10/19.
//  Copyright © 2019 dediego. All rights reserved.
//

import SwiftUI
import Contacts

struct ContactsView: View {
    
    @EnvironmentObject var viewModel: ContactViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Picker("Show all contacts?", selection: $viewModel.displayMode) {
                ForEach(ContactViewModel.FilterType.allCases, content: { type in
                    type.text
                })
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(8)
            
            VStack {
                if $viewModel.isDisplayingLoader.wrappedValue {
                    Text("Loading contacts...")
                } else {
                    Text("Contacts: ").bold() + Text("\(self.viewModel.contacts.count)")
                }
            }
            .padding()
            
            if viewModel.error == nil {
                ContactsList(contacts: self.viewModel.contacts).onAppear {
                    DispatchQueue.main.async {
                        self.viewModel.fetch()
                    }
                }
            } else {
                Text("error: \(self.viewModel.error!.localizedDescription)")
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

struct ContactsView_Previews: PreviewProvider {

    static var contactStore: ContactViewModel = {
        let store = ContactViewModel()
        store.contacts = [
            CNContact.goodExample,
            CNContact.goodExample,
            CNContact.goodExample,
        ]
        return store
    }()
    
    static var previews: some View {
        ContactsView().environmentObject(contactStore)
    }
}
