//
//  MovieDetailStata.swift
//  Featured2
//
//  Created by Joost van Grieken on 06/04/2023.
//

// MARK: Hantert de detail pagina 

import SwiftUI

class MovieDetailState: ObservableObject {
    
    private let searchService: SearchService
    @Published var movie: Movie?
    @Published var isLoading = false
    @Published var error: NSError?
    
    init(searchService: SearchService = SearchStore.shared) {
        self.searchService = searchService
    }
    
    func loadMovie(id: Int) {
        self.movie = nil
        self.isLoading = false
        self.searchService.fetchMovie(id: id) {[weak self] (result) in
            guard let self = self else { return }
            
            self.isLoading = false
            switch result {
            case .success(let movie):
                self.movie = movie
            case .failure(let error):
                self.error = error as NSError
            }
        }
    }
}
