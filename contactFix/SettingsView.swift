//
//  SettingsView.swift
//  contactFix
//
//  Created by Hector De Diego on 22/10/19.
//  Copyright © 2019 dediego. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            Section(header: Text("Section")) {
                Text("Hello, World!")
            }
        }
    }
}

struct SettingsTab: View {
    var body: some View {
        SettingsView().tabItem {
            Text("Settings")
            Image(systemName: "gear")
        }.tag(2)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
