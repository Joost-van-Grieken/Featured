//
//  AccountView.swift
//  Featured
//
//  Created by Joost van Grieken on 21/04/2023.
//

// MARK: Hantert de accountView

import SwiftUI

struct AccountView: View {
    let username: String
    @State private var isLoggedIn = true
    
    @State private var savedMovies: [Movie] = []
    @State private var watchedMovies: [Movie] = []
    
    @State private var isMovieSaved: Bool = false
    @State private var setWatchedMovieCount = 0
    
    let movie: Movie
    var movieListState = MovieListState()
    
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
                            Text("\(UserDefaults.standard.getWatchedMovieCount())")
                                .font(.system(size: 42, weight: .semibold))
                            Text("Movies Seen")
                                .font(.system(size: 14))
                            Text("\(UserDefaults.standard.totalWatchedMinutes) min")
                                .font(.system(size: 14))
                        }
                        Spacer()
                    }
                }
                .padding(.vertical)
                
                Section {
                    Text("Saved for later")
                        .font(.headline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: 30) {
                            ForEach(savedMovies, id: \.self) { movie in
                                NavigationLink(destination: MovieDetailView(movieId: movie.id)) {
                                    VStack(alignment: .leading) {
                                        MoviePosterCard(movie: movie)
                                            .frame(width: 204, height: 306)
                                            .font(.system(size: 18).weight(.bold))
                                        Spacer().frame(height: 5)
                                        Text(movie.title)
                                            .lineLimit(1)
                                    }
                                    .frame(width: 260)
                                    .padding(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.accentColor, lineWidth: 3)
                                    )
                                }
                            }
                        }
                    }
                }
                
                Section {
                    Text("Recently watched")
                        .font(.headline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: 30) {
                            ForEach(watchedMovies, id: \.self) { movie in
                                NavigationLink(destination: MovieDetailView(movieId: movie.id)) {
                                    VStack(alignment: .leading) {
                                        MoviePosterCard(movie: movie)
                                            .frame(width: 204, height: 306)
                                            .font(.system(size: 18).weight(.bold))
                                        Spacer().frame(height: 5)
                                        Text(movie.title)
                                            .lineLimit(1)
                                    }
                                    .frame(width: 260)
                                    .padding(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.accentColor, lineWidth: 3)
                                    )
                                }
                            }
                        }
                    }
                    .onAppear {
                        let watchedState = UserDefaults.standard.getWatchedState(id: movie.id)
                        if watchedState {
                            // Fetch the movie using its ID and add it to the watchedMovies array
                            if let watchedMovie = movieListState.movies.first(where: { $0.id == movie.id }) {
                                watchedMovies = [watchedMovie]
                            } else {
                                watchedMovies = []
                            }
                        } else {
                            watchedMovies = []
                        }
                    }
                }
            }
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView(username: "joost2023", movie: Movie.stubbedMovie)
    }
}
