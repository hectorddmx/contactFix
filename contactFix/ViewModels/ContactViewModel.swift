//
//  ContactViewModel.swift
//  contactFix
//
//  Created by Hector De Diego on 24/10/19.
//  Copyright © 2019 dediego. All rights reserved.
//

import SwiftUI
import Combine
import Contacts
import os

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
    
    private func getAllContacts() -> [CNContact] {
        os_log("Fetching contacts")
        
        let contactStore = CNContactStore()
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
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            self.error = error
            os_log("Error fetching containers")
        }
        
        var newContacts: [CNContact] = []
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                os_log("Fetching contacts: for container: %{PUBLIC}@", container.name)
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch)
                newContacts.append(contentsOf: containerResults)
            } catch {
                os_log("Error fetching containers")
            }
        }
        return newContacts
    }
    
    private func filterContacts(_ allContacts: [CNContact]) -> [CNContact] {
        os_log("Fetching contacts: filtering for %{PUBLIC}@", "\(self.displayMode)")
        switch self.displayMode {
        case .all:
            return allContacts
        case .missingPhone:
            return allContacts.filter { $0.phoneNumbers.count == 0 }
        case .missingName:
            return allContacts.filter { $0.name.isEmpty }
        }
    }
    
    public func fetch() {
        self.isDisplayingLoader = true
        self.contacts.removeAll(keepingCapacity: true)
        
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            let allContacts = self.getAllContacts()
            let filteredContacts = self.filterContacts(allContacts)
            DispatchQueue.main.async { [unowned self] in
                self.contacts = filteredContacts
                os_log("Fetching contacts: succesfull with count = %d", self.contacts.count)
                self.isDisplayingLoader = false
            }
        }
    }
}
