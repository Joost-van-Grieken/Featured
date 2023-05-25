//
//  AccountView.swift
//  Featured
//
//  Created by Joost van Grieken on 21/04/2023.
//

import SwiftUI

struct AccountView: View {
    let username: String
//    let moviesSeen: Int
//    let episodesSeen: Int
//    let recentMovies: [String]
//    let recentEpisodes: [String]
    
    var body: some View {
        NavigationView {
            List {
                HStack {
                    Image("User")
                    Text("Welcome, \(username)")
                        .font(.system(size: 22, weight: .semibold))
                }
                .listRowBackground(Color.clear)
                                
                Section {
                    HStack {
                        Spacer()
                        VStack {
                            Text("0")
                                .font(.system(size: 42, weight: .semibold))
    //                        Text("\(moviesSeen)")
    //                            .font(.headline)
                            Text("Movies Seen")
                                .font(.system(size: 14))
                            Text("0 min")
                                .font(.system(size: 14))
                        }
                        Spacer()
                            .frame(maxWidth: 60)
                        VStack {
                            Text("0")
                                .font(.system(size: 42, weight: .semibold))
    //                        Text("\(episodesSeen)")
    //                            .font(.headline)
                            Text("Episodes Seen")
                                .font(.system(size: 16))
                            Text("0 min")
                                .font(.system(size: 14))
                        }
                        Spacer()
                    }
                    .padding()
                }
                .padding(.vertical)
                
                Section {
                    Text("Saved for later")
                }
                
                Section {
                    Text("Recent Movies")
                        .font(.headline)
//                    ScrollView(.horizontal) {
//                        HStack(spacing: 16) {
//                            ForEach(recentMovies, id: \.self) { movieTitle in
//                                VStack {
//                                    Image(systemName: "film.fill")
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(width: 80, height: 80)
//
//                                    Text(movieTitle)
//                                        .multilineTextAlignment(.center)
//                                }
//                            }
//                        }
//                        .padding(.horizontal)
//                    }
                }

                Section {
                    Text("Recent Episodes")
                        .font(.headline)
//                    ScrollView(.horizontal) {
//                        HStack(spacing: 16) {
//                            ForEach(recentEpisodes, id: \.self) { episodeTitle in
//                                VStack {
//                                    Image(systemName: "tv.fill")
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(width: 80, height: 80)
//
//                                    Text(episodeTitle)
//                                        .multilineTextAlignment(.center)
//                                }
//                            }
//                        }
//                        .padding(.horizontal)
//                    }
                }
            }
        }
    }
}


struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView(username: "")
    }
}
