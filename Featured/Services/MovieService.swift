//
//  MovieService.swift
//  Featured2
//
//  Created by Joost van Grieken on 06/04/2023.
//

import Foundation

protocol MovieService {
    
    func fetchMovies(from endpoint: MovieListEndpoint, completion: @escaping (Result<MovieResponse, MovieError>) -> ())
    func fetchMovie(id: Int, completion: @escaping (Result<Movie, MovieError>) -> ())
    func searchMovie(query: String, completion: @escaping (Result<MovieResponse, MovieError>) -> ())
//    func discoverMovies(from endpoint: dicoverEndpoint, completion: @escaping (Result<MovieResponse, MovieError>) -> ())
}

enum MovieListEndpoint: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    
    case nowPlaying = "now_playing"
    case popular
    case topRated = "top_rated"
    case upcoming

    
    var description: String {
        switch self {
        case .nowPlaying: return "Now Playing"
        case .upcoming: return "Upcoming"
        case .topRated: return "Top Rated"
        case .popular: return "Popular"

        }
    }
}

//enum dicoverEndpoint: String, CaseIterable, Identifiable {
//    var id: String { rawValue }
//
//    case withGenres
//
//    var description: String {
//        switch self {
//        case .withGenres: return "Genres"
//        }
//    }
//}

enum MovieError: Error, CustomNSError {
    
    case apiError
    case invalidEndpoint
    case invalidResponse
    case noData
    case serializationError
    
    var localizedDescription: String {
        switch self {
        case .apiError: return "Failed to fetch data"
        case .invalidEndpoint: return "Invalid endpoint"
        case .invalidResponse: return "Invalid response"
        case .noData: return "No data"
        case .serializationError: return "Failed to decode data"
        }
    }
    
    var errorUserInfo: [String : Any] {
        [NSLocalizedDescriptionKey: localizedDescription]
    }
}
