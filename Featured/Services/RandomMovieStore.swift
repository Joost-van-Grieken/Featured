//
//  RandomMovieStore.swift
//  Featured
//
//  Created by Joost van Grieken on 23/04/2023.
//

import SwiftUI
import Combine

class RandomMovieStore: ObservableObject {
    @Published var randomMovie: Movie?
    
    static let shared = RandomMovieStore()

//    (page: Int, year: Int, voteCountGte: Int, genres: Int, originalLanguage: String, watchProviders: String, watchRegion: String, completion: @escaping (Result<MovieResponse, Error>) -> Void)
    
    func discoverMovies(page: Int, genres: Int, completion: @escaping (Result<MovieResponse, Error>) -> Void) {
        guard var urlComponents = URLComponents(string: "https://api.themoviedb.org/3/discover/movie") else {
            completion(.failure(Error.self as! Error))
            return
        }

        // Set query parameters
        urlComponents.queryItems = [
            URLQueryItem(name: "api_key", value: "ae1c9875a55b3f3d23c889e07b973920"),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "with_genres", value: String(genres))
//            URLQueryItem(name: "language", value: "en-US"),
//            URLQueryItem(name: "sort_by", value: "popularity.desc"),
//            URLQueryItem(name: "year", value: String(year)),
//            URLQueryItem(name: "vote_count.gte", value: String(voteCountGte)),
//            URLQueryItem(name: "with_original_language", value: originalLanguage),
//            URLQueryItem(name: "with_watch_providers", value: watchProviders),
//            URLQueryItem(name: "watch_region", value: watchRegion)
        ]

        guard let url = urlComponents.url else {
            completion(.failure(Error.self as! Error))
            return
        }

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(Error.self as! Error))
                return
            }

            do {
                let movieResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
                completion(.success(movieResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

struct Genre: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
}

class GenreViewModel: ObservableObject {
    @Published var genres = [Genre]()
    @Published var selectedGenres = Set<Int>()
    private var cancellable: AnyCancellable?
    
    func fetchGenres() {
        let url = URL(string: "https://api.themoviedb.org/3/genre/movie/list?api_key=ae1c9875a55b3f3d23c889e07b973920")!
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: GenreResponse.self, decoder: JSONDecoder())
            .replaceError(with: GenreResponse(genres: []))
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] response in
                self?.genres = response.genres
            })
    }
    
    func toggleGenre(_ genreId: Int) {
        if selectedGenres.contains(genreId) {
            selectedGenres.remove(genreId)
        } else {
            selectedGenres.insert(genreId)
        }
    }
}

struct GenreResponse: Decodable {
    let genres: [Genre]
}

struct Provider: Codable, Hashable {
    let provider_id: Int
    let provider_name: String
    let logo_path: String?
}

class ProviderViewModel: ObservableObject {
    @Published var providers: [Provider] = []
    
    func fetchProviders() {
        let apiKey = "ae1c9875a55b3f3d23c889e07b973920"
        let urlString = "https://api.themoviedb.org/3/watch/providers/movie?api_key=\(apiKey)&watch_region=NL"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching providers: \(error)")
                return
            }
            
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(ProviderResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.providers = response.results
                    }
                } catch {
                    print("Error decoding providers: \(error)")
                }
            }
        }.resume()
    }
}

struct ProviderResponse: Codable {
    let results: [Provider]
}

