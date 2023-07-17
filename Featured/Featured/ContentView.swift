//
//  ContentView.swift
//  Featured
//
//  Created by Joost van Grieken on 06/04/2023.
//

// MARK: Hantert de homepagina

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var settings: UserSettings
    @State var selection = 0
    
    var body: some View {
        TabView(selection: $selection) {
            MovieListView()
                .tabItem {
                    VStack {
                        if selection == 0 {
                            Image("Home Selected")
                        } else {
                            Image("Home")
                        }
                        Text("Home")
                    }
                }
                .tag(0)
            
            RandomiserView(totalPages: RandomMovieStore.shared)
                .tabItem {
                    VStack {
                        if selection == 1 {
                            Image("Randomiser Selected")
                        } else {
                            Image("Randomiser")
                        }
                        Text("Randomiser")
                            .font(.system(size: 30, weight: .bold))
                    }
                }
                .tag(1)
            
            UserView()
                .environmentObject(UserSettings())
                .tabItem {
                    VStack {
                        if selection == 2 {
                            Image("User Selected")
                        } else {
                            Image("User")
                        }
                        Text("Account")
                    }
                }
                .tag(2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
