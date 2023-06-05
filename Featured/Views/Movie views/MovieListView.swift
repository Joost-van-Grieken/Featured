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
    let isLoggedIn: Bool // Receive the isLoggedIn status
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    SearchBarView(placeholder: "Looking for something?", text: self.$movieSearchState.query)
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
                        NavigationLink(destination: MovieFullListView(title: "Popular", endpoint: .popular)) {
                            ZStack(alignment: .topTrailing) {
                                MoviePosterCarouselView(title: "Popular", movies: movies)
                                
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16))
                                    .fontWeight(.bold)
                                    .offset(x: -6, y: 12)
                            }
                        }
                        
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
                    if let movies = nowPlayingState.movies {
                        NavigationLink(destination: MovieFullListView(title: "Now Playing", endpoint: .nowPlaying)) {
                            ZStack(alignment: .topTrailing) {
                                MoviePosterCarouselView(title: "Now Playing", movies: movies)
                                
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16))
                                    .fontWeight(.bold)
                                    .offset(x: -6, y: 12)
                            }
                        }
                        
                    } else {
                        LoadingView(isLoading: self.nowPlayingState.isLoading, error: self.nowPlayingState.error as NSError?) {
                            self.nowPlayingState.loadMovies(from: .nowPlaying, page: 1)
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top:8, leading: 0, bottom: 8, trailing: 0))
                .listRowSeparator(.hidden)
                .padding(.top, 10)
                
                Section {
                    if let movies = topRatedState.movies {
                        NavigationLink(destination: MovieFullListView(title: "Top Rated", endpoint: .topRated)) {
                            ZStack(alignment: .topTrailing) {
                                MoviePosterCarouselView(title: "Top Rated", movies: movies)
                                
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16))
                                    .fontWeight(.bold)
                                    .offset(x: -6, y: 12)
                            }
                        }
                        .buttonStyle(.plain)
                        
                    } else {
                        LoadingView(isLoading: self.topRatedState.isLoading, error: self.topRatedState.error as NSError?) {
                            self.topRatedState.loadMovies(from: .topRated, page: 1)
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top:8, leading: 0, bottom: 8, trailing: 0))
                .listRowSeparator(.hidden)
                .padding(.top, 10)
                
                Section {
                    if let movies = upcomingState.movies {
                        NavigationLink(destination: MovieFullListView(title: "Upcoming", endpoint: .upcoming)) {
                            ZStack(alignment: .topTrailing) {
                                MoviePosterCarouselView(title: "Upcoming", movies: movies)
                                
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16))
                                    .fontWeight(.bold)
                                    .offset(x: -6, y: 12)
                            }
                        }
                        .buttonStyle(.plain)
                    } else {
                        LoadingView(isLoading: self.upcomingState.isLoading, error: self.upcomingState.error as NSError?) {
                            self.upcomingState.loadMovies(from: .upcoming, page: 1)
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top:8, leading: 0, bottom: 8, trailing: 0))
                .listRowSeparator(.hidden)
                .padding(.top, 10)
                
            }
            .navigationTitle(isLoggedIn ? "Welcome, stranger" : "Welcome, \(username)") // Use the showingLoginScreen status to show the navigation title
            
        }
        .onAppear {
            self.nowPlayingState.loadMovies(from: .nowPlaying, page: 1)
            self.upcomingState.loadMovies(from: .upcoming, page: 1)
            self.topRatedState.loadMovies(from: .topRated, page: 1)
            self.popularState.loadMovies(from: .popular, page: 1)
        }
    }
}

//struct MovieListView: View {
//
//    @ObservedObject private var nowPlayingState = MovieListState()
//    @ObservedObject private var upcomingState = MovieListState()
//    @ObservedObject private var topRatedState = MovieListState()
//    @ObservedObject private var popularState = MovieListState()
//
//    @ObservedObject var movieSearchState = MovieSearchState()
//
//    @State private var isPresentingSearch = false
//
//    let username: String
//    let isLoggedIn: Bool // Receive the isLoggedIn status
//
//    var body: some View {
//        NavigationView {
//            List {
//                Section {
//                    SearchBarView(placeholder: "Looking for something?", text: self.$movieSearchState.query)
//                        .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
//
//                    LoadingView(isLoading: self.movieSearchState.isLoading, error: self.movieSearchState.error) {
//                        self.movieSearchState.search(query: self.movieSearchState.query)
//                    }
//
//                    if self.movieSearchState.movies != nil {
//                        ForEach(self.movieSearchState.movies!) { movie in
//                            NavigationLink(destination: MovieDetailView(movieId: movie.id)) {
//                                VStack(alignment: .leading) {
//                                    Text(movie.title)
//                                    Text(movie.yearText)
//                                }
//                            }
//                        }
//                    }
//                }
//                .onAppear {
//                    self.movieSearchState.startObserve()
//                }
//
//                Section {
//                    if popularState.movies != nil {
//                        NavigationLink(destination: MovieFullListView(title: "Popular", movies: popularState.movies!), label: {
//                            ZStack(alignment: .topTrailing) {
//                                MoviePosterCarouselView(title: "Popular", movies: popularState.movies!)
//
//                                Image(systemName: "arrow.right")
//                                    .font(.system(size: 16))
//                                    .fontWeight(.bold)
//                                    .offset(x: -6, y: 12)
//                            }
//                        })
//                        .buttonStyle(.plain)
//                    } else {
//                        LoadingView(isLoading: self.popularState.isLoading, error: self.popularState.error) {
//                            self.popularState.loadMovies(with: .popular)
//                        }
//                    }
//                }
//                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
//                .listRowSeparator(.hidden)
//
//                Section {
//                    if nowPlayingState.movies != nil {
//                        NavigationLink(destination: MovieFullListView(title: "Now Playing", movies: nowPlayingState.movies!), label: {
//                            ZStack(alignment: .topTrailing) {
//                                MoviePosterCarouselView(title: "Now Playing", movies: nowPlayingState.movies!)
//
//                                Image(systemName: "arrow.right")
//                                    .font(.system(size: 16))
//                                    .fontWeight(.bold)
//                                    .offset(x: -6, y: 12)
//                            }
//                        })
//                        .buttonStyle(.plain)
//
//                    } else {
//                        LoadingView(isLoading: self.nowPlayingState.isLoading, error: self.nowPlayingState.error) {
//                            self.nowPlayingState.loadMovies(with: .nowPlaying)
//                        }
//                    }
//                }
//                .listRowInsets(EdgeInsets(top:8, leading: 0, bottom: 8, trailing: 0))
//                .listRowSeparator(.hidden)
//
//                Section {
//                    if topRatedState.movies != nil {
//                        NavigationLink(destination: MovieFullListView(title: "Top Rated", movies: topRatedState.movies!), label: {
//                            ZStack(alignment: .topTrailing) {
//                                MoviePosterCarouselView(title: "Top Rated", movies: topRatedState.movies!)
//
//                                Image(systemName: "arrow.right")
//                                    .font(.system(size: 16))
//                                    .fontWeight(.bold)
//                                    .offset(x: -6, y: 12)
//                            }
//                        })
//                        .buttonStyle(.plain)
//
//                    } else {
//                        LoadingView(isLoading: self.topRatedState.isLoading, error: self.topRatedState.error) {
//                            self.topRatedState.loadMovies(with: .topRated)
//                        }
//                    }
//                }
//                .listRowInsets(EdgeInsets(top:8, leading: 0, bottom: 8, trailing: 0))
//                .listRowSeparator(.hidden)
//
//                Section {
//                    if upcomingState.movies != nil {
//                        NavigationLink(destination: MovieFullListView(title: "Upcoming", movies: upcomingState.movies!), label: {
//                            ZStack(alignment: .topTrailing) {
//                                MoviePosterCarouselView(title: "Upcoming", movies: upcomingState.movies!)
//
//                                Image(systemName: "arrow.right")
//                                    .font(.system(size: 16))
//                                    .fontWeight(.bold)
//                                    .offset(x: -6, y: 12)
//                            }
//                        })
//                        .buttonStyle(.plain)
//                    } else {
//                        LoadingView(isLoading: self.upcomingState.isLoading, error: self.upcomingState.error) {
//                            self.upcomingState.loadMovies(with: .upcoming)
//                        }
//                    }
//                }
//                .listRowInsets(EdgeInsets(top:8, leading: 0, bottom: 8, trailing: 0))
//                .listRowSeparator(.hidden)
//
//            }
//            .navigationTitle(isLoggedIn ? "Welcome, stranger" : "Welcome, \(username)") // Use the isLoggedIn status to show the navigation title
//
//        }
//        .onAppear {
//            self.nowPlayingState.loadMovies(with: .nowPlaying)
//            self.upcomingState.loadMovies(with: .upcoming)
//            self.topRatedState.loadMovies(with: .topRated)
//            self.popularState.loadMovies(with: .popular)
//        }
//    }
//}

struct MovieListView_Previews: PreviewProvider {
    static var previews: some View {
        MovieListView(username: "", isLoggedIn: true)
    }
}

