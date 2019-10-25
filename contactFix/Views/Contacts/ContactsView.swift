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
import Combine

class ContactViewModel: ObservableObject {
    
    enum FilterType: Int, CaseIterable, Identifiable {
        
        var id: Self { self }
        
        case all = 0
        case missingPhone
        case missingName
        
        var text: some View {
            let _text: Text
            switch self {
            case .all:
                _text = Text("All")
            case .missingPhone:
                _text = Text("No Phone")
            case .missingName:
                _text = Text("No Name")
            }
            return _text.tag(self)
        }
    }
    
    @Published var contacts: [CNContact] = []
    @Published var error: Error? = nil
    @Published var displayMode: FilterType = .all {
        didSet {
            if oldValue != self.displayMode {
                fetch()
            }
        }
    }
    @Published var isDisplayingLoader: Bool = true
    
    func fetch() {
        self.isDisplayingLoader = true
        self.contacts.removeAll(keepingCapacity: true)
        
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
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
            
            var newContacts: [CNContact] = []
            for container in allContainers {
                let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
                
                do {
                    os_log("Fetching contacts: for container: %{PUBLIC}@", log: OSLog.default, type: .info, container.name)
                    let containerResults = try store.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch)
                    newContacts.append(contentsOf: containerResults)
                } catch {
                    os_log("Error fetching containers")
                }
            }
            
            let filteredContacts: [CNContact]
            
            switch self.displayMode {
            case .all:
                filteredContacts = newContacts
            case .missingPhone:
                filteredContacts = newContacts.filter { $0.phoneNumbers.count == 0 }
            case .missingName:
                filteredContacts = newContacts.filter { $0.name.isEmpty }
            }
            
            DispatchQueue.main.async { [unowned self] in
                self.contacts = filteredContacts
                os_log("Fetching contacts: succesfull with count = %d", self.contacts.count)
                self.isDisplayingLoader = false
            }
        }
    }
}

struct ContactsView: View {
    
    @EnvironmentObject var viewModel: ContactViewModel
    
    var body: some View {
        VStack {
            Picker("Show all contacts?", selection: $viewModel.displayMode) {
                ForEach(ContactViewModel.FilterType.allCases, content: { type in
                    type.text
                })
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding([.leading, .trailing, .bottom, .top], 8)
            
            VStack {
                if $viewModel.isDisplayingLoader.wrappedValue {
                    Text("Loading contacts...")
                } else {
                    Text("Contacts: ").bold() + Text("\(self.viewModel.contacts.count)")
                }
                
            }.padding()
            
//            LoadingView(isShowing: .constant(true)) {

            if viewModel.error == nil {
                ContactsList(contacts: self.viewModel.contacts).onAppear{
                    DispatchQueue.main.async {
                        self.viewModel.fetch()
                    }
                }
            } else {
                Text("error: \(self.viewModel.error!.localizedDescription)")
            }
//            }
                        
            
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
            goodContact,
            goodContact,
            goodContact,
        ]
        return store
    }()
    
    static var goodContact: CNContact = {
        let contact = CNMutableContact()
        contact.imageData = UIImage(named: "turtlerock")?.pngData()
        contact.givenName = "John"
        contact.familyName = "Appleseed"
        contact.emailAddresses = [
            CNLabeledValue(label: CNContactEmailAddressesKey, value: "lecksfrawen@gmail.com"),
            CNLabeledValue(label: CNContactEmailAddressesKey, value: "lecksfrawen@gmail.com"),
        ]
        contact.phoneNumbers = [
            CNLabeledValue(
                label:CNLabelPhoneNumberiPhone,
                value:CNPhoneNumber(stringValue:"+52 1 55 55829010")
            ),
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
        ContactsView().environmentObject(contactStore)
    }
}


extension CNContact: Identifiable {
    /// Resulting name of searching givenName, middleName, familyName
    var name: String {
        return [givenName, middleName, familyName].filter{ $0.count > 0}.joined(separator: " ")
    }
}


struct ActivityIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

struct LoadingView<Content>: View where Content: View {

    @Binding var isShowing: Bool
    var content: () -> Content

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {

                self.content()
                    .disabled(self.isShowing)
                    .blur(radius: self.isShowing ? 3 : 0)

                VStack {
                    Text("Loading...")
                    ActivityIndicator(isAnimating: .constant(true), style: .large)
                }
                .frame(width: geometry.size.width / 2,
                       height: geometry.size.height / 5)
                .background(Color.secondary.colorInvert())
                .foregroundColor(Color.primary)
                .cornerRadius(20)
                .opacity(self.isShowing ? 1 : 0)

            }
        }
    }

}
