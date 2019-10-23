//
//  ContentView.swift
//  contactFix
//
//  Created by Hector De Diego on 22/10/19.
//  Copyright © 2019 dediego. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedView = 1
    
    var body: some View {
        TabView(selection: $selectedView) {
            ContactsTab()
            SettingsTab()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
