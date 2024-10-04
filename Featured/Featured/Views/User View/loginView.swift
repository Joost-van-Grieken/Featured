//
//  LoginView.swift
//  Featured
//
//  Created by Joost van Grieken on 15/03/2023.
//

import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var wrongUsername = 0
    @State private var wrongPassword = 0
    @State private var showingLoginScreen = false
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Text("Login")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                    TextField("Username", text: $username)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.white.opacity(1))
                        .cornerRadius(10)
                        .border(.red, width: CGFloat(wrongUsername))
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.white.opacity(1))
                        .cornerRadius(10)
                        .border(.red, width: CGFloat(wrongPassword))
                    
                    Button("Login") {
                        authenticateUser(username: username, password: password)
                    }
                    .foregroundColor(.white)
                    .frame(width:300, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
                    
                    NavigationLink(
                        destination: AccountView(
                            username: username
//                            moviesSeen: 0,
//                            episodesSeen: 0,
//                            recentMovies: [],
//                            recentEpisodes: []
                        ) .navigationBarBackButtonHidden(true),
                        isActive: $showingLoginScreen
                    ) {
                        EmptyView()
                    }
                }
            }
        }
    }
    
    func authenticateUser(username: String, password: String) {
        if username.lowercased() == "joost2023" {
            wrongUsername = 0
            if password.lowercased() == "abc123" {
                wrongPassword = 0
                showingLoginScreen = true
            } else {
                wrongPassword = 2
            }
        } else {
            wrongUsername = 2
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

//struct LoginView: View {
//    @State private var username = ""
//    @State private var password = ""
//    @State private var wrongUsername = 0
//    @State private var wrongPassword = 0
//    @State private var showingLoginScreen = false
//
//    var body: some View {
//        NavigationView {
//            ZStack {
//                VStack {
//                    Text("Login")
//                        .font(.largeTitle)
//                        .bold()
//                        .padding()
//                    TextField("Username", text: $username)
//                        .padding()
//                        .frame(width: 300, height: 50)
//                        .background(Color.white.opacity(1))
//                        .cornerRadius(10)
//                        .border(.red, width: CGFloat(wrongUsername))
//
//                    SecureField("Password", text: $password)
//                        .padding()
//                        .frame(width: 300, height: 50)
//                        .background(Color.white.opacity(1))
//                        .cornerRadius(10)
//                        .border(.red, width: CGFloat(wrongPassword))
//
//                    Button("Login") {
//                        autheticateUser(username: username, password: password)
//                    }
//                    .foregroundColor(.white)
//                    .frame(width:300, height: 50)
//                    .background(Color.blue)
//                    .cornerRadius(10)
//
//                    NavigationLink(destination: Text("You are logged in @\(username)"), isActive: $showingLoginScreen) {
//                        EmptyView()
//                    }
//                }
//            }
//            .navigationBarHidden(true)
//        }
//    }
//
//    func autheticateUser(username: String, password: String) {
//        if username.lowercased() == "joost2023" {
//            wrongUsername = 0
//            if password.lowercased() == "abc123" {
//                wrongPassword = 0
//                showingLoginScreen = true
//            } else {
//                wrongPassword = 2
//            }
//        } else {
//            wrongUsername = 2
//        }
//    }
//}
//
//struct LoginView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginView()
//    }
//}
