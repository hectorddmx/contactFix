//
//  ContactsErrorView.swift
//  contactFix
//
//  Created by hdb on 25/10/19.
//  Copyright © 2019 dediego. All rights reserved.
//

import SwiftUI

struct ContactsErrorView: View {
    var body: some View {
        
        VStack {
            Text("Fail").font(.largeTitle)
            Text("No access granted for contacts")
                .padding()
            Button(action: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }                
            }) {
                Text("Open settings")
            }
                
        }
        
    }
}

struct ContactsErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ContactsErrorView()
    }
}
