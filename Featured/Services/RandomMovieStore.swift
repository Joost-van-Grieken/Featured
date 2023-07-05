//
//  RandomMovieStore.swift
//  Featured
//
//  Created by Joost van Grieken on 23/04/2023.
//

// MARK: Hantert de API calls voor de RandomiserView

import SwiftUI
import Combine

class RandomMovieStore: ObservableObject {
    @Published var randomMovie: Movie?
    @Published var genres = [Genre]()
    @Published var selectedGenres = Set<Int>()
    @Published var totalPages = Int()
    
    static let shared = RandomMovieStore()
    private let apiKey = "ae1c9875a55b3f3d23c889e07b973920"
    let urlSession = URLSession.shared
    let jsonDecoder = Utils.jsonDecoder
    
    func fetchTotalPages(genres: [Int], providers: [Int], completion: @escaping (Result<Int, MovieError>) -> ()) {
        let genreIDs = genres.map(String.init).joined(separator: ",")
        let providerIDs = providers.map(String.init).joined(separator: ",")

        guard let url = URL(string: "https://api.themoviedb.org/3/discover/movie?api_key=\(apiKey)&include_adult=false&page=1&with_genres=\(genreIDs)&watch_region=NL&vote_average.ite=1&with_watch_providers=\(providerIDs)") else {
            completion(.failure(.invalidEndpoint))
            return
        }

        loadURLAndDecode(url: url) { (result: Result<MovieResponsePages, MovieError>) in
            switch result {
            case .success(let pagesResponse):
                completion(.success(pagesResponse.totalPages))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        print(totalPages)
    }

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

struct MovieResponsePages: Codable {
    let totalPages: Int
    
    enum CodingKeys: String, CodingKey {
        case totalPages = "total_pages"
    }
}

//class MovieData: ObservableObject {
//    @Published var randomMovie: Movie?
//    @Published var genres = [Genre]()
//    @Published var selectedGenres = Set<Int>()
//    @Published var totalPages: Int = 0
//
//    private let apiKey = "ae1c9875a55b3f3d23c889e07b973920"
//
//    func fetchMovieData(page: Int, genres: String, providers: String, completion: @escaping (Result<MovieResponse, MovieError>) -> ()) {
//        let urlString = "https://api.themoviedb.org/3/discover/movie?api_key=\(apiKey)&include_adult=false&page=\(page)&with_genres=\(genres)&watch_region=NL&vote_average.ite=1&with_watch_providers=\(providers)") else {
//            completion(.failure(.invalidEndpoint))
//            return
//        }
//
//        guard let url = URL(string: urlString) else {
//            print("Invalid URL")
//            return
//        }
//
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            if let error = error {
//                print("Error: \(error.localizedDescription)")
//                return
//            }
//
//            guard let httpResponse = response as? HTTPURLResponse,
//                  httpResponse.statusCode == 200,
//                  let data = data else {
//                print("Invalid response")
//                return
//            }
//
//            do {
//                let decoder = JSONDecoder()
//                let movieResponse = try decoder.decode(MovieResponse.self, from: data)
//
//                let movieResponsePages = try decoder.decode(MovieResponsePages.self, from: data)
//
//                DispatchQueue.main.async {
//                    self.totalPages = movieResponsePages.totalPages
//                }
//            } catch {
//                print("Error decoding JSON: \(error.localizedDescription)")
//            }
//        }.resume()
//    }
//}

// MARK: Hantert de filter api calls voor de filterView

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


// MARK: Hantert de provider call voor de detailView

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
