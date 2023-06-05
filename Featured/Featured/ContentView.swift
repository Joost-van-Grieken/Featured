//
//  ContentView.swift
//  Featured
//
//  Created by Joost van Grieken on 06/04/2023.
//

import SwiftUI

struct ContentView: View {
    
    @State var selection = 0
    
    var body: some View {
        TabView (selection: $selection) {
            MovieListView(username: "", isLoggedIn: false)
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
            
            RandomiserView(movie: Movie.stubbedMovie)
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
