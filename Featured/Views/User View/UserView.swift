//
//  AccountView.swift
//  Featured
//
//  Created by Joost van Grieken on 18/04/2023.
//

import SwiftUI

struct UserView: View {
    var body: some View {
        TabView {
            LoginView()
        }
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView()
    }
}
