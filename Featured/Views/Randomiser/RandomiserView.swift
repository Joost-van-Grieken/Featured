//
//  RandomiserView.swift
//  Featured
//
//  Created by Joost van Grieken on 10/04/2023.
//

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
    @State var randomNumber = [Int]()
    
    @State private var numOption: Int = 3
    @StateObject var selectedGenresViewModel = SelectedGenresViewModel()
    @StateObject var selectedProviderViewModel = SelectedProviderViewModel()
    
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
                            FilterView(numOption: $numOption, selectedGenresViewModel: selectedGenresViewModel, selectedProviderViewModel: selectedProviderViewModel)
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
                        await performTask(numOption: numOption, selectedGenresViewModel: selectedGenresViewModel, selectedProviderViewModel: selectedProviderViewModel) { movieIDs in
                            var fetchedMovies = [Movie]()
                            let dispatchGroup = DispatchGroup()
                            
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
        RandomiserView()
    }
}

// Step 1: Get random page numbers
func getRandomPageNumbers(count: Int) -> [Int] {
    let randomNumbers = Array(1...50).shuffled().prefix(count)
    return Array(randomNumbers)
}

// Step 2: Link to a function that applies the numbers to the selected genres
func applyFiltersAndFindMovieIDs(pages: [Int], genres: [Int], providers: [Int], completion: @escaping ([Int]) -> Void) {
    var movieIDs = [Int]()
    let group = DispatchGroup()
    
    for page in pages {
        group.enter()
        
        let genreIDs = genres.map(String.init).joined(separator: ",")
        let providerIDs = providers.map(String.init).joined(separator: ",")
        
        RandomMovieStore.shared.discoverMovies(page: page, genres: genreIDs, providers: providerIDs) { result in
            switch result {
            case .success(let response):
                if let randomMovie = response.results.randomElement() {
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

// Step 3: Perform task
func performTask(numOption: Int, selectedGenresViewModel: SelectedGenresViewModel, selectedProviderViewModel: SelectedProviderViewModel, completion: @escaping ([Int]) -> Void) {
    let pageNumbers = getRandomPageNumbers(count: numOption)
    print("number of options", numOption)
    print("Generated random page numbers:", pageNumbers)
    
    let genreIDs = selectedGenresViewModel.selectedGenres.map { $0.id }
    let providerIDs = selectedProviderViewModel.selectedProvider.map { $0.provider_id }
    
    applyFiltersAndFindMovieIDs(pages: pageNumbers, genres: genreIDs, providers: providerIDs) { ids in
        print("Task completed")
        completion(ids)
    }
}

// Main function
func main() {
    let selectedGenresViewModel = SelectedGenresViewModel()
    let selectedProviderViewModel = SelectedProviderViewModel()
    
    performTask(numOption: 3, selectedGenresViewModel: selectedGenresViewModel, selectedProviderViewModel: selectedProviderViewModel) { movieIDs in
        // Handle the movieIDs result here
    }
}
