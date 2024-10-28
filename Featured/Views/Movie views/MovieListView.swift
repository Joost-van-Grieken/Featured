//
//  MovieListView.swift
//  Featured2
//
//  Created by Joost van Grieken on 06/04/2023.
//

// MARK: Hantert de mini lijsten view. Deze view is gelinkt aan de home pagina

import SwiftUI

struct MovieListView: View {
    @StateObject private var settings = UserSettings()
    
    @ObservedObject private var nowPlayingState = MovieListState()
    @ObservedObject private var upcomingState = MovieListState()
    @ObservedObject private var topRatedState = MovieListState()
    @ObservedObject private var popularState = MovieListState()
    @ObservedObject var movieSearchState = MovieSearchState()
    
    @State private var navigateToPopular = false
    @State private var navigateToTopRated = false
    @State private var navigateToUpcoming = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    SearchBarView(placeholder: "Looking for a movie?", text: self.$movieSearchState.query)
                        .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                    
                    LoadingView(isLoading: self.movieSearchState.isLoading, error: self.movieSearchState.error) {
                        self.movieSearchState.search(query: self.movieSearchState.query)
                    }
                    
                    if let movies = self.movieSearchState.movies {
                        ForEach(movies) { movie in
                            NavigationLink(destination: MovieDetailView(movieId: movie.id)) {
                                VStack(alignment: .leading) {
                                    Text(movie.title)
                                    Text(movie.yearText)
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    self.movieSearchState.startObserve()
                }
                
                Section {
                    if let movies = popularState.movies {
                        Button(action: {
                            // Trigger navigation to Popular movies
                            navigateToPopular = true
                        }) {
                            ZStack(alignment: .topTrailing) {
                                MoviePosterCarouselView(title: "Popular", movies: movies)
                                
                                Text("See all")
                                    .font(.system(size: 16))
                                    .fontWeight(.bold)
                                    .offset(x: -6, y: 12)
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .background(
                            NavigationLink(destination: MovieFullListView(title: "Popular", endpoint: .popular), isActive: $navigateToPopular) {
                                EmptyView()
                            }
                            .hidden()
                        )
                    } else {
                        LoadingView(isLoading: self.popularState.isLoading, error: self.popularState.error as NSError?) {
                            self.popularState.loadMovies(from: .popular, page: 1)
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                .listRowSeparator(.hidden)
                .padding(.top, 10)
                
                Section {
                    if let movies = topRatedState.movies {
                        Button(action: {
                            // Trigger navigation to Top Rated movies
                            navigateToTopRated = true
                        }) {
                            ZStack(alignment: .topTrailing) {
                                MoviePosterCarouselView(title: "Top Rated", movies: movies)
                                
                                Text("See all")
                                    .font(.system(size: 16))
                                    .fontWeight(.bold)
                                    .offset(x: -6, y: 12)
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .background(
                            NavigationLink(destination: MovieFullListView(title: "Top Rated", endpoint: .topRated), isActive: $navigateToTopRated) {
                                EmptyView()
                            }
                            .hidden()
                        )
                    } else {
                        LoadingView(isLoading: self.topRatedState.isLoading, error: self.topRatedState.error as NSError?) {
                            self.topRatedState.loadMovies(from: .topRated, page: 1)
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                .listRowSeparator(.hidden)
                .padding(.top, 20)
                
                Section {
                    if let movies = upcomingState.movies {
                        Button(action: {
                            // Trigger navigation to Upcoming movies
                            navigateToUpcoming = true
                        }) {
                            ZStack(alignment: .topTrailing) {
                                MoviePosterCarouselView(title: "Upcoming", movies: movies)
                                
                                Text("See all")
                                    .font(.system(size: 16))
                                    .fontWeight(.bold)
                                    .offset(x: -6, y: 12)
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .background(
                            NavigationLink(destination: MovieFullListView(title: "Upcoming", endpoint: .upcoming), isActive: $navigateToUpcoming) {
                                EmptyView()
                            }
                            .hidden()
                        )
                    } else {
                        LoadingView(isLoading: self.upcomingState.isLoading, error: self.upcomingState.error as NSError?) {
                            self.upcomingState.loadMovies(from: .upcoming, page: 1)
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                .listRowSeparator(.hidden)
                .padding(.top, 20)
                
            }
            .listStyle(.plain)
            .navigationTitle(settings.isLoggedIn ? "Welcome, \(settings.username)" : "Welcome, stranger")
            .navigationBarTitleDisplayMode(.inline)
        }
        .environmentObject(settings)
        .onAppear {
            self.upcomingState.loadMovies(from: .upcoming, page: 1)
            self.topRatedState.loadMovies(from: .topRated, page: 1)
            self.popularState.loadMovies(from: .popular, page: 1)
        }
    }
}
                                            

struct MovieListView_Previews: PreviewProvider {
    static var previews: some View {
        MovieListView()
    }
}

