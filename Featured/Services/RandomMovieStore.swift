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
    @Published var genres = [Genre]()
    @Published var selectedGenres = Set<Int>()
    
    static let shared = RandomMovieStore()
    private let apiKey = "ae1c9875a55b3f3d23c889e07b973920"
    let urlSession = URLSession.shared
    let jsonDecoder = Utils.jsonDecoder
    
    func discoverMovies(page: Int, genres: String, providers: String, completion: @escaping (Result<MovieResponse, MovieError>) -> ()) {
        guard let url = URL(string: "https://api.themoviedb.org/3/discover/movie?api_key=\(apiKey)&include_adult=false&page=\(page)&with_genres=\(genres)&watch_region=NL&vote_average.ite=1&with_watch_providers=\(providers)") else {
            completion(.failure(.invalidEndpoint))
            return
        }
        self.loadURLAndDecode(url: url, completion: completion)
        print(url)
    }
    
    private func loadURLAndDecode<D: Decodable>(url: URL, params: [String: String]? = nil, completion: @escaping (Result<D, MovieError>) -> ()) {
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            completion(.failure(.invalidEndpoint))
            return
        }
        
        var queryItems = [URLQueryItem(name: "api_key", value: apiKey)]
        if let params = params {
            queryItems.append(contentsOf: params.map { URLQueryItem(name: $0.key, value: $0.value) })
        }
        
        urlComponents.queryItems = queryItems
        
        guard let finalURL = urlComponents.url else {
            completion(.failure(.invalidEndpoint))
            return
        }
        
        urlSession.dataTask(with: finalURL) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            if error != nil {
                self.executeCompletionHandlerInMainThread(with: .failure(.apiError), completion: completion)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                self.executeCompletionHandlerInMainThread(with: .failure(.invalidResponse), completion: completion)
                return
            }
            guard let data = data else {
                self.executeCompletionHandlerInMainThread(with: .failure(.noData), completion: completion)
                return
            }
            
            do {
                let decodedResponse = try self.jsonDecoder.decode(D.self, from: data)
                self.executeCompletionHandlerInMainThread(with: .success(decodedResponse), completion: completion)
            } catch {
                self.executeCompletionHandlerInMainThread(with: .failure(.serializationError), completion: completion)
            }
        }.resume()
    }
    
    private func executeCompletionHandlerInMainThread<D: Decodable>(with result: Result<D, MovieError>, completion: @escaping (Result<D, MovieError>) -> ()) {
        DispatchQueue.main.async {
            completion(result)
        }
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

// MARK: fetch provider for single movie
struct MovieProviderResponse: Codable {
    let results: Results

    struct Results: Codable {
        let NL: NL

        struct NL: Codable {
            let flatrate: [MovieProvider]
        }
    }
}

struct MovieProvider: Codable {
    let provider_name: String
}

class MovieProviderViewModel: ObservableObject {
    @Published var flatrateProviders: [MovieProvider] = []
    
    func fetchProviderData(id: Int) {
        let apiKey = "ae1c9875a55b3f3d23c889e07b973920"
        let watchRegion = "NL"
        let urlString = "https://api.themoviedb.org/3/movie/\(id)/watch/providers?api_key=\(apiKey)&watch_region=\(watchRegion)"

        guard let url = URL(string: urlString) else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }

            if let data = data {
                do {
                    let response = try JSONDecoder().decode(MovieProviderResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.flatrateProviders = response.results.NL.flatrate
                    }
                } catch {
                    print("Error decoding data: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
}
