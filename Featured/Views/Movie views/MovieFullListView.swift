//
//  MovieFullListView.swift
//  Featured
//
//  Created by Joost van Grieken on 23/05/2023.
//

// MARK: Hantert de volledige film lijst

import SwiftUI

struct MovieFullListView: View {
    
    @StateObject private var settings = UserSettings()
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
                                    if !settings.isLoggedIn, watchedOn {
                                        UserDefaults.standard.setWatchedMovieCount(value: false, movieId: movie.id, durationText: movie.durationText)
                                        settings.removeMovieID(movie.id)
                                    } else {
                                        UserDefaults.standard.setWatchedMovieCount(value: true, movieId: movie.id, durationText: movie.durationText)
                                        settings.addMovieID(movie.id)
                                    }
                                    watchedOn.toggle()
                                }) {
                                    VStack {
                                        if !settings.isLoggedIn {
                                            Image("Watch (locked)")
                                                .resizable()
                                                .frame(width: 25, height: 25)
                                        } else if watchedOn {
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
                                .disabled(!settings.isLoggedIn)
                                .onAppear {
                                    watchedOn = UserDefaults.standard.getWatchedState(movieId: movie.id)
                                }
                                
                                Spacer()
                                
                                Button(action: { // Save button
                                    if !settings.isLoggedIn, savedOn {
                                        UserDefaults.standard.setSavedState(value: false, movieId: movie.id)
                                        settings.unSaveMovieID(movie.id)
                                    } else {
                                        UserDefaults.standard.setSavedState(value: true, movieId: movie.id)
                                        settings.saveMovieID(movie.id)
                                    }
                                    savedOn.toggle()
                                }) {
                                    VStack {
                                        if !settings.isLoggedIn {
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
                                .disabled(!settings.isLoggedIn)
                                .onAppear {
                                    savedOn = UserDefaults.standard.getSavedState(movieId: movie.id)
                                }
                                
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
