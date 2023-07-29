//
//  RandomMovieStore.swift
//  Featured
//
//  Created by Joost van Grieken on 23/04/2023.
//

// MARK: Hantert de API calls voor de RandomiserView

import Foundation
import Combine

class RandomMovieStore: ObservableObject {
    @Published var randomMovie = [Movie]()
    @Published var totalPages: Int = 1
    
    static let shared = RandomMovieStore()
    init() {}
    
    private let apiKey = "ae1c9875a55b3f3d23c889e07b973920"
    let baseAPIURL = "https://api.themoviedb.org/3"
    let urlSession = URLSession.shared
    let jsonDecoder = Utils.jsonDecoder
    
    func fetchTotalPages(genres: [Int], providers: [Int], language: [String], era: [String], score: [Int], completion: @escaping (Result<Int, MovieError>) -> Void) {
        let genresString = genres.map { String($0) }.joined(separator: ",")
        let providersString = providers.map { String($0) }.joined(separator: ",")
        let languageString = language.joined(separator: ",")
        let eraString = era.map { String($0) }.joined(separator: ",")
        let scoreString = score.map { String($0) }.joined(separator: ",")
        
        guard let encodedGenres = genresString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedProviders = providersString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedLanguage = languageString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedEra = eraString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedScore = scoreString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(.failure(.invalidEndpoint))
            return
        }
        
        let urlString = "\(baseAPIURL)/discover/movie?api_key=\(apiKey)&page=1&with_genres=\(encodedGenres)&with_watch_providers=\(encodedProviders)&with_original_language=\(encodedLanguage)&primary_release_year=\(encodedEra)&vote_average.lte=\(encodedScore)&include_adult=false&watch_region=NL"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidEndpoint))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(apiResponse.totalPages))
                        print("total pages are: \(apiResponse.totalPages)")
                    }
                } catch {
                    print("Error decoding API response: \(error)")
                    completion(.failure(.serializationError))
                }
            } else if let error = error {
                print("Error fetching movies: \(error)")
                completion(.failure(.invalidResponse))
            }
        }.resume()
        print(urlString)
    }
    
    func discoverMovies(page: Int, genres: String, providers: String, language: String, era: String, score: String, completion: @escaping (Result<RandomMovieResponse, MovieError>) -> ()) {
        guard let url = URL(string: "\(baseAPIURL)/discover/movie?api_key=\(apiKey)&page=\(page)&with_genres=\(genres)&with_watch_providers=\(providers)&with_original_language=\(language)&primary_release_year=\(era)&vote_average.lte=\(score)&include_adult=false&watch_region=NL")
        else {
            completion(.failure(.invalidEndpoint))
            print("The page is", page)
            return
        }
           self.loadURLAndDecode(url: url, completion: completion)
           print(url)
    }

    private func loadURLAndDecode<RandomMovieResponse: Decodable>(url: URL, params: [String: String]? = nil, completion: @escaping (Result<RandomMovieResponse, MovieError>) -> ()) {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            completion(.failure(.invalidEndpoint))
            return
        }
        
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
                let decodedResponse = try self.jsonDecoder.decode(RandomMovieResponse.self, from: data)
                self.executeCompletionHandlerInMainThread(with: .success(decodedResponse), completion: completion)
            } catch {
                self.executeCompletionHandlerInMainThread(with: .failure(.serializationError), completion: completion)
            }
        }.resume()
    }
    
    private func executeCompletionHandlerInMainThread<RandomMovieResponse: Decodable>(with result: Result<RandomMovieResponse, MovieError>, completion: @escaping (Result<RandomMovieResponse, MovieError>) -> ()) {
        DispatchQueue.main.async {
            completion(result)
        }
    }
}

struct RandomMovieResponse: Decodable {
    let page: Int
    let results: [Movie]
}

struct APIResponse: Codable {
    let totalPages: Int
    
    enum CodingKeys: String, CodingKey {
        case totalPages = "total_pages"
    }
}


// MARK: Hantert de filter api calls voor de filterView
// Genres
class GenreViewModel: ObservableObject {
    @Published var genres: [Genre] = []
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

struct Genre: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
}

// providers
class ProviderViewModel: ObservableObject {
    @Published var providers: [Provider] = []
    
    func fetchProviders() {
        let urlString = "https://api.themoviedb.org/3/watch/providers/movie?api_key=ae1c9875a55b3f3d23c889e07b973920&watch_region=NL"
        
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

struct Provider: Codable, Hashable {
    let provider_id: Int
    let provider_name: String
}

// language
class LanguageViewModel: ObservableObject {
    @Published var languages: [Language] = []
    @Published var selectedLanguages = Set<String>()
    private var cancellable: AnyCancellable?
    
    func fetchLanguages() {
        let url = URL(string: "https://api.themoviedb.org/3/configuration/languages?api_key=ae1c9875a55b3f3d23c889e07b973920")!
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: LanguageResponse.self, decoder: JSONDecoder())
            .replaceError(with: LanguageResponse(languages: []))
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] response in
                self?.languages = response.languages
                print("Languages fetched: \(self?.languages ?? [])")
            })
    }
    
    func toggleLanguage(_ isoCode: String) {
        if selectedLanguages.contains(isoCode) {
            selectedLanguages.remove(isoCode)
        } else {
            selectedLanguages.insert(isoCode)
        }
    }
}

struct LanguageResponse: Decodable {
    let languages: [Language]
}

struct Language: Codable, Hashable {
    let iso639_1: String
    let english_name: String
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
        let urlString = "https://api.themoviedb.org/3/movie/\(id)/watch/providers?api_key=ae1c9875a55b3f3d23c889e07b973920&watch_region=NL"

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
