//
//  MovieListView.swift
//  Featured2
//
//  Created by Joost van Grieken on 06/04/2023.
//

import SwiftUI

struct MovieListView: View {
    
    @ObservedObject private var nowPlayingState = MovieListState()
    @ObservedObject private var upcomingState = MovieListState()
    @ObservedObject private var topRatedState = MovieListState()
    @ObservedObject private var popularState = MovieListState()
    
    @ObservedObject var movieSearchState = MovieSearchState()
    
    @State private var isPresentingSearch = false
    
    let username: String
    let showingLoginScreen: Bool // Receive the isLoggedIn status
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    SearchBarView(placeholder: "Looking for something?", text: self.$movieSearchState.query)
                        .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                    
                    LoadingView(isLoading: self.movieSearchState.isLoading, error: self.movieSearchState.error) {
                        self.movieSearchState.search(query: self.movieSearchState.query)
                    }
                    
                    if self.movieSearchState.movies != nil {
                        ForEach(self.movieSearchState.movies!) { movie in
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
                    if popularState.movies != nil {
                        NavigationLink(destination: MovieFullListView(title: "Popular", movies: popularState.movies!), label: {
                            ZStack(alignment: .topTrailing) {
                                MoviePosterCarouselView(title: "Popular", movies: popularState.movies!)
                                
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16))
                                    .fontWeight(.bold)
                                    .offset(x: -6, y: 12)
                            }
                        })
                        .buttonStyle(.plain)
                    } else {
                        LoadingView(isLoading: self.popularState.isLoading, error: self.popularState.error) {
                            self.popularState.loadMovies(with: .popular)
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                .listRowSeparator(.hidden)
                
                Section {
                    if nowPlayingState.movies != nil {
                        NavigationLink(destination: MovieFullListView(title: "Now Playing", movies: nowPlayingState.movies!), label: {
                            ZStack(alignment: .topTrailing) {
                                MoviePosterCarouselView(title: "Now Playing", movies: nowPlayingState.movies!)
                                
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16))
                                    .fontWeight(.bold)
                                    .offset(x: -6, y: 12)
                            }
                        })
                        .buttonStyle(.plain)
                        
                    } else {
                        LoadingView(isLoading: self.nowPlayingState.isLoading, error: self.nowPlayingState.error) {
                            self.nowPlayingState.loadMovies(with: .nowPlaying)
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top:8, leading: 0, bottom: 8, trailing: 0))
                .listRowSeparator(.hidden)
                
                Section {
                    if topRatedState.movies != nil {
                        NavigationLink(destination: MovieFullListView(title: "Top Rated", movies: topRatedState.movies!), label: {
                            ZStack(alignment: .topTrailing) {
                                MoviePosterCarouselView(title: "Top Rated", movies: topRatedState.movies!)
                                
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16))
                                    .fontWeight(.bold)
                                    .offset(x: -6, y: 12)
                            }
                        })
                        .buttonStyle(.plain)
                        
                    } else {
                        LoadingView(isLoading: self.topRatedState.isLoading, error: self.topRatedState.error) {
                            self.topRatedState.loadMovies(with: .topRated)
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top:8, leading: 0, bottom: 8, trailing: 0))
                .listRowSeparator(.hidden)
                
                Section {
                    if upcomingState.movies != nil {
                        NavigationLink(destination: MovieFullListView(title: "Upcoming", movies: upcomingState.movies!), label: {
                            ZStack(alignment: .topTrailing) {
                                MoviePosterCarouselView(title: "Upcoming", movies: upcomingState.movies!)
                                
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16))
                                    .fontWeight(.bold)
                                    .offset(x: -6, y: 12)
                            }
                        })
                        .buttonStyle(.plain)
                    } else {
                        LoadingView(isLoading: self.upcomingState.isLoading, error: self.upcomingState.error) {
                            self.upcomingState.loadMovies(with: .upcoming)
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top:8, leading: 0, bottom: 8, trailing: 0))
                .listRowSeparator(.hidden)
                
            }
            .navigationTitle(showingLoginScreen ? "Welcome, stranger" : "Welcome, \(username)") // Use the showingLoginScreen status to show the navigation title
            
        }
        .onAppear {
            self.nowPlayingState.loadMovies(with: .nowPlaying)
            self.upcomingState.loadMovies(with: .upcoming)
            self.topRatedState.loadMovies(with: .topRated)
            self.popularState.loadMovies(with: .popular)
        }
    } 
}

struct MovieListView_Previews: PreviewProvider {
    static var previews: some View {
        MovieListView(username: "", showingLoginScreen: true)
    }
}

