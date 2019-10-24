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

/// Contains the main views of our application
struct ContentView: View {
    
    var body: some View {
        ContactsView()
            .environmentObject(ContactStore())
            .tabItem {
                Text("Contacts")
                Image(systemName: "person.crop.circle")}
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
