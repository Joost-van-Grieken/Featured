//
//  MovieFullListView.swift
//  Featured
//
//  Created by Joost van Grieken on 23/05/2023.
//

// MARK: Hantert de volledige film lijst

import SwiftUI

struct MovieFullListView: View {
    
    @EnvironmentObject var settings: UserSettings
    @ObservedObject private var movieListState: MovieListState
    
    let title: String
    let endpoint: MovieListEndpoint
    
    @State private var isLoggedIn = false
    
    @State var selection = 0
    
    @State private var watchedOn = false
    @State private var savedOn = false
    @State private var isScrolledToEnd = false
    
    var items: [GridItem] = [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)]
    
    init(title: String, endpoint: MovieListEndpoint) {
        self.title = title
        self.endpoint = endpoint
        self.movieListState = MovieListState()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: items, spacing: 30) {
                    ForEach(movieListState.movies) { movie in
                        VStack {
                            NavigationLink(destination: MovieDetailView(movieId: movie.id)) {
                                MoviePosterCard(movie: movie)
                                    .aspectRatio(contentMode: .fit)
                            }
                            .buttonStyle(.plain)
                            
                            HStack {
                                Spacer()
                                
                                Button(action: { // Watch button
                                    if !UserDefaults.standard.bool(forKey: "login") {
                                    } else {
                                        let watchedOn = UserDefaults.standard.getWatchedState(id: movie.id)
                                        UserDefaults.standard.setWatchedState(value: !watchedOn, id: movie.id)
                                    }
                                }) {
                                    VStack {
                                        if !UserDefaults.standard.bool(forKey: "login") {
                                            Image("Watch (locked)")
                                                .resizable()
                                                .frame(width: 25, height: 25)
                                        } else if UserDefaults.standard.getWatchedState(id: movie.id) {
                                            Image("Watched")
                                                .resizable()
                                                .frame(width: 25, height: 25)
                                        } else {
                                            Image("Watch")
                                                .resizable()
                                                .frame(width: 25, height: 25)
                                        }
                                    }
                                }
                                .disabled(!UserDefaults.standard.bool(forKey: "login"))
                                
                                Spacer()
                                
                                Button(action: { // Save button
                                    if !UserDefaults.standard.bool(forKey: "login") {
                                    } else {
                                        let savedOn = UserDefaults.standard.getSavedState(forMovieId: movie.id)
                                        UserDefaults.standard.setSavedState(value: !savedOn, forMovieId: movie.id)
                                    }
                                }) {
                                    VStack {
                                        if !UserDefaults.standard.bool(forKey: "login") {
                                            Image("Save (locked)")
                                                .resizable()
                                                .frame(width: 25, height: 25)
                                        } else if savedOn {
                                            Image("Saved")
                                                .resizable()
                                                .frame(width: 25, height: 25)
                                        } else {
                                            Image("Save")
                                                .resizable()
                                                .frame(width: 25, height: 25)
                                        }
                                    }
                                }
                                .onAppear {
                                    savedOn = UserDefaults.standard.getSavedState(forMovieId: movie.id)
                                }
                                .disabled(!UserDefaults.standard.bool(forKey: "login"))
                                
                                Spacer()
                            }
                            .padding(.bottom, 6)
                        }
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                Button(action: {
                    movieListState.fetchNextPage(from: endpoint)
                }) {
                    Text("Load More")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .onAppear {
            loadInitialMovies()
        }
    }
    
    private func loadInitialMovies() {
        movieListState.loadMovies(from: endpoint, page: 1)
    }
}

//struct MovieFullListView_Previews: PreviewProvider {
//    static var previews: some View {
//        MovieFullListView(title: "", endpoint: MovieListEndpoint)
//    }
//}
