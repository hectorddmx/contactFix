//
//  ContentView.swift
//  contactFix
//
//  Created by Hector De Diego on 22/10/19.
//  Copyright © 2019 dediego. All rights reserved.
//

import SwiftUI

struct AppState {
    
}

enum MainTabs {
    case contacts
    case settings
}


/// Contains the main views of our application
struct ContentView: View {
    @State private var selectedView: MainTabs = .contacts
    
    var body: some View {
        TabView(selection: $selectedView) {
            ContactsTab().tag(MainTabs.contacts)
            SettingsTab().tag(MainTabs.settings)
        }
    }
}

/// Contructs the main tab for the contacts flow
struct ContactsTab: View {
    var body: some View {
        ContactsView()
            .environmentObject(ContactStore())
            .tabItem {
                Text("Contacts")
                Image(systemName: "person.crop.circle")}
    }
}

/// Contructs the main tab for the settings flow
struct SettingsTab: View {
    var body: some View {
        SettingsView().tabItem {
            Text("Settings")
            Image(systemName: "gear")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
