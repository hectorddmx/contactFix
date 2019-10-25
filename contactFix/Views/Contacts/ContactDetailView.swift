//
//  ContactDetailView.swift
//  contactFix
//
//  Created by Hector De Diego on 24/10/19.
//  Copyright © 2019 dediego. All rights reserved.
//

import SwiftUI
import Contacts

struct ContactDetailView: View {
    var contact: CNContact
    
    var body: some View {
        VStack {
            Image("turtlerock")
            Text("Hello, World!")
        }
    }
}

struct ContactDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ContactDetailView(contact: CNContact.goodExample)
    }
}
