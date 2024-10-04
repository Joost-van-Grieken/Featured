//
//  ContentView.swift
//  Featured
//
//  Created by Joost van Grieken on 06/04/2023.
//

// MARK: Hantert de homepagina

import SwiftUI

struct ContentView: View {
    @State private var tabSelection: Int = 0

    private var selectionBinding: Binding<Int> {
        Binding(get: {
            tabSelection
        }, set: {
            if $0 == tabSelection {
                // Reset the view when the current tab is tapped
                let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first
                let navigationController = window?.rootViewController?.recursiveChildren().first(where: { $0 is UINavigationController && $0.view.window != nil }) as? UINavigationController
                navigationController?.popToRootViewController(animated: true)
            }
            tabSelection = $0
        })
    }

    var body: some View {
        TabView(selection: selectionBinding) {
            // Home Tab
            MovieListView()
                .tabItem {
                    VStack {
                        Image(tabSelection == 0 ? "Home Selected" : "Home")
                        Text("Home")
                    }
                }
                .tag(0)

            // Randomiser Tab
            RandomiserView(totalPages: RandomMovieStore.shared)
                .tabItem {
                    VStack {
                        Image(tabSelection == 1 ? "Randomiser Selected" : "Randomiser")
                        Text("Randomiser")
                            .font(.system(size: 30, weight: .bold))
                    }
                }
                .tag(1)

            // User Tab
            UserView()
                .environmentObject(UserSettings()) // Use the same instance of UserSettings
                .tabItem {
                    VStack {
                        Image(tabSelection == 2 ? "User Selected" : "User")
                        Text("Account")
                    }
                }
                .tag(2)
        }
        .background(Color(.systemBackground)) // Set background color to system default
        .edgesIgnoringSafeArea(.all) // Optional: Extend background to edges
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(UserSettings()) // Provide UserSettings for the preview
    }
}

// Extension to allow recursive child retrieval in UIViewController
extension UIViewController {
    func recursiveChildren() -> [UIViewController] {
        return children + children.flatMap({ $0.recursiveChildren() })
    }
}
