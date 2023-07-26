//
//  MovieListState.swift
//  Featured2
//
//  Created by Joost van Grieken on 06/04/2023.
//

// MARK: Hantert de film lijsten: Popular, Top rated & Upcomming

import SwiftUI

class MovieListState: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var isLoading: Bool = false
    @Published var error: MovieError?
    
    private let movieService: MovieService
    private var currentPage: Int = 1
    
    init(movieService: MovieService = MovieStore.shared) {
        self.movieService = movieService
    }
    
    func loadMovies(from endpoint: MovieListEndpoint, page: Int) {
        self.isLoading = true
        self.movieService.fetchMovies(from: endpoint, page: page) { [weak self] (result) in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let response):
                self.movies = response.results
                
            case .failure(let error):
                self.error = error
            }
        }
    }
    
    func fetchNextPage(from endpoint: MovieListEndpoint) {
        guard !isLoading else { return }
        let nextPage = currentPage + 1
        loadMovies(from: endpoint, page: nextPage)
        currentPage = nextPage
        print("current page is", currentPage)
    }
}
