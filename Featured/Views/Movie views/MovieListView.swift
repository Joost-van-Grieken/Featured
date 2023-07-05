//
//  MovieListView.swift
//  Featured2
//
//  Created by Joost van Grieken on 06/04/2023.
//

// MARK: Hantert de mini lijsten view. Deze view is gelinkt aan de home pagina

import SwiftUI

struct MovieListView: View {
    
    @ObservedObject private var nowPlayingState = MovieListState()
    @ObservedObject private var upcomingState = MovieListState()
    @ObservedObject private var topRatedState = MovieListState()
    @ObservedObject private var popularState = MovieListState()
    
    @ObservedObject var movieSearchState = MovieSearchState()
    
    @State private var isPresentingSearch = false
    
    let username: String
    var isLoggedIn: Bool = false
    
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
            .navigationTitle(getWelcomeMessage())
        }
        .onAppear {
            self.nowPlayingState.loadMovies(from: .nowPlaying, page: 1)
            self.upcomingState.loadMovies(from: .upcoming, page: 1)
            self.topRatedState.loadMovies(from: .topRated, page: 1)
            self.popularState.loadMovies(from: .popular, page: 1)
        }
    }
    
    private func getWelcomeMessage() -> String {
        if isLoggedIn == false {
            return "Welcome, stranger"
        } else {
            return "Welcome, joost2023"
        }
    }
}

struct MovieListView_Previews: PreviewProvider {
    static var previews: some View {
        MovieListView(username: "joost2023", isLoggedIn: false)
    }
}

