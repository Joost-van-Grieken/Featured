//
//  RandomiserView.swift
//  Featured
//
//  Created by Joost van Grieken on 10/04/2023.
//

// MARK: Hantert de RandomiserView

import SwiftUI
import Combine

struct RandomiserView: View {
    
    struct CustomColor {
        static let textColor = Color("textColor")
    }
    
    @StateObject var store = RandomMovieStore()
    @StateObject private var imageLoader = ImageLoader()
    
    @State private var isShowingFilters = false
    @State private var filteredMovies: [Movie] = []
    @State private var movieTitles: [String] = []
    @State private var fetchedMovies = [Movie]()
    @State private var selectedEndpoint: MovieListEndpoint = .popular
    
    @State private var numOption: Int = 3
    @StateObject var selectedGenresViewModel = SelectedGenresViewModel()
    @StateObject var selectedProviderViewModel = SelectedProviderViewModel()
    
    var totalPages: RandomMovieStore
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                    .frame(height: 10)
                
                Button(action: {
                    isShowingFilters.toggle()
                }) {
                    Text("Filters")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width:300, height: 50)
                        .background(Color.accentColor)
                        .cornerRadius(10)
                        .sheet(isPresented: $isShowingFilters) {
                            FilterView(numOption: $numOption, selectedEndpoint: $selectedEndpoint, selectedGenresViewModel: selectedGenresViewModel, selectedProviderViewModel: selectedProviderViewModel)
                        }

                }
                
                Spacer()
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 30) {
                        Spacer()
                        ForEach(filteredMovies, id: \.self) { movie in
                            NavigationLink(destination: MovieDetailView(movieId: movie.id)) {
                                VStack(alignment: .leading) {
                                    Text(movie.title)
                                        .font(.system(size: 22).weight(.bold))
                                        .foregroundColor(CustomColor.textColor)
                                        .lineLimit(1)
                                    
                                    MoviePosterCard(movie: movie)
                                        .frame(width: 260, height: 390)
                                    
                                    Text(movie.genreText)
                                        .foregroundColor(CustomColor.textColor)
                                        .font(.system(size: 18).weight(.bold))
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                    Spacer()
                                        .frame(height: 5)
                                    HStack(alignment: .bottom, spacing: 20) {
                                        Text(movie.yearText)
                                            .foregroundColor(CustomColor.textColor)
                                        Text(movie.durationText)
                                            .foregroundColor(CustomColor.textColor)
                                    }
                                    HStack {
                                        Image("Heart (rated)")
                                            .resizable()
                                            .frame(width: 25, height: 25)
                                            .padding(.trailing, -5)
                                        HStack(alignment: .bottom) {
                                            Text(movie.ratingText).foregroundColor(.accentColor)
                                            Text(movie.formattedVoteCount)
                                                .font(.system(size: 14))
                                        }
                                    }
                                    .padding(.top, -10)
                                    .padding(.bottom, -10)
                                }
                                .frame(width: 260)
                                .padding(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.accentColor, lineWidth: 3)
                                )
                            }
                        }
                        Spacer()
                    }
                }
                
                Spacer()
                
                Button(action: {
                    Task {
                        performTask(
                            numOption: numOption, selectedEndpoint: selectedEndpoint,
                            selectedGenresViewModel: selectedGenresViewModel,
                            selectedProviderViewModel: selectedProviderViewModel
                        ) { movieIDs,arg  in
                            var fetchedMovies = [Movie]()
                            let dispatchGroup = DispatchGroup()
                            
                            // plaatst de id van de films om de infromatie eruit te halen
                            for id in movieIDs {
                                dispatchGroup.enter()
                                print("Fetching movie with ID: \(id)")
                                MovieStore.shared.fetchMovie(id: id) { result in
                                    switch result {
                                    case .success(let movie):
                                        fetchedMovies.append(movie)
                                    case .failure(let error):
                                        print(error.localizedDescription)
                                    }
                                    dispatchGroup.leave()
                                }
                            }
                            
                            dispatchGroup.notify(queue: .main) {
                                self.filteredMovies = fetchedMovies
                                self.movieTitles = fetchedMovies.map({ $0.title })
                                print(self.movieTitles)
                            }
                        }
                    }
                }) {
                    Text("Randomise")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width:300, height: 50)
                        .background(Color.accentColor)
                        .cornerRadius(10)
                }
                
                Spacer()
                    .frame(height: 10)
            }
        }
        .navigationTitle("Randomiser")
    }
}

struct RandomiserView_Previews: PreviewProvider {
    static var previews: some View {
        RandomiserView(totalPages: RandomMovieStore.shared)
    }
}

// MARK: Hantert de randomiser
// Voert de actie in stappen uit. Stap 1: Roept eerst de totaal aantal pagina's op. Bij succes gaat die over naar stap 2: random nummer genereren tussen 1 en de totaal pagina's. Stap 3: Voert die random nummer samen met de filters (mocht die er zijn) in de uiteindelijke api call.
func performTask(numOption: Int, selectedEndpoint: MovieListEndpoint, selectedGenresViewModel: SelectedGenresViewModel, selectedProviderViewModel: SelectedProviderViewModel, completion: @escaping ([Int], Int?) -> Void) {
    let genreIDs = selectedGenresViewModel.selectedGenres.map { $0.id }
    let providerIDs = Array(selectedProviderViewModel.selectedProvider.map { $0.provider_id }.shuffled().prefix(1))
    
    RandomMovieStore.shared.fetchTotalPages(from: selectedEndpoint, genres: genreIDs, providers: providerIDs) { result in
        switch result {
        case .success(let totalPages):
            let pageNumbers = getRandomPageNumbers(numOption: numOption, totalPages: totalPages)
            applyFiltersAndFindMovieIDs(selectedEndpoint: selectedEndpoint, pages: pageNumbers, genres: genreIDs, providers: providerIDs) { ids in
                completion(ids, totalPages)
            }
        case .failure(let error):
            print("Failed to fetch total pages: \(error)")
            completion([], nil)
        }
    }
    
    // kiest een random pagina nummer tussen 1 en de totaal pagina's
    func getRandomPageNumbers(numOption: Int, totalPages: Int) -> [Int] {
        let limitedTotalPages = min(totalPages, 50)  // Limiet van 50 pagina's
        let randomNumbers = Array(1...limitedTotalPages).shuffled().prefix(numOption)
        print("number of options: \(numOption)")
        print(randomNumbers)
        return Array(randomNumbers)
    }
    
    // Voegt filters toe aan de API call (mocht die er zijn), voegt de pagina in de api call. Bij succes kiest die 1 random film van de resultaten en pakt de film id.
    func applyFiltersAndFindMovieIDs(selectedEndpoint: MovieListEndpoint, pages: [Int], genres: [Int], providers: [Int], completion: @escaping ([Int]) -> Void) {
        var movieIDs = [Int]()
        let group = DispatchGroup()

        for page in pages {
            group.enter()

            let genreIDs = genres.map(String.init).joined(separator: ",")
            let providerIDs = Array(providers.shuffled().prefix(1)) // Limiet van 1 provider id per api call.

            RandomMovieStore.shared.discoverMovies(from: selectedEndpoint, page: page, genres: genreIDs, providers: providerIDs.map(String.init).joined()) { result in
                switch result {
                case .success(let response):
                    print("this is page", page)
                    if !response.results.isEmpty {
//                        print("API response:", response)
                        let randomIndex = Int.random(in: 1..<response.results.count)
                        print("this is randomIndex", randomIndex)
                        let randomMovie = response.results[randomIndex]
                        let randomMovieID = randomMovie.id
                        print("Random movie ID:", randomMovieID)
                        movieIDs.append(randomMovieID)
                    }
                case .failure(let error):
                    print("API call failed with error: \(error)")
                }
                
                group.leave()
            }
        }

        group.notify(queue: .main) {
            print("All API calls completed")
            completion(movieIDs)
        }
    }
}
