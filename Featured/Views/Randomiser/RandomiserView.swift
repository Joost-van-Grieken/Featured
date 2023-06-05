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
    
    @ObservedObject var store = RandomMovieStore()
    @State private var isShowingFilters = false
//    @State private var shouldCancelRandomiseButton = true

    @Binding var numOptions: Int
    @Binding var year: Int?
    @Binding var voteCountGte: Double?
    @Binding var genres: String?
    @Binding var originalLanguage: String?
    @Binding var watchProviders: String?
    @Binding var watchRegion: String?
    
    let movie: Movie
    @StateObject private var imageLoader = ImageLoader()
    
//    @ObservedObject private var popularState = MovieListState()
    
    @State var selectedList: Set<Filter> = []
    @State private var filteredMovies: [Movie] = []
    @State private var movieTitles: [String] = []
    @State private var fetchedMovies = [Movie]()
    @State var randomNumber = [Int]()
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                    .frame(height: 10)
                Button("Filters") {
                    isShowingFilters.toggle()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(width:300, height: 50)
                .background(Color.accentColor)
                .cornerRadius(10)
                .sheet(isPresented: $isShowingFilters) {
                    FilterView(numOptions: $numOptions, genres: $genres, movie: Movie.stubbedMovie)
                                }

                Spacer()
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 30) {
                        Spacer()
                        ForEach(filteredMovies, id: \.self) { movie in
                            NavigationLink(destination: MovieDetailView(movieId: movie.id)) {
                                VStack(alignment: .leading) {
                                    HStack {
//                                        Text("\(numOptions / numOptions)")
                                        Text(movie.title)
                                            .font(.system(size: 22).weight(.bold))
                                            .foregroundColor(CustomColor.textColor)
                                            .lineLimit(1)
                                    }
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
//                    fetchRandomMovie(movieListState: MovieListState)
                
                    var randomNumbers = [Int]()
                    while randomNumbers.count < numOptions {
                        let randomNumber = Int.random(in: 1...2500)
                        randomNumbers.append(randomNumber)
                        print(randomNumber)
                    }

//                    var fetchedRandomMovies = [Movie]()

//                    for randomNumbers in randomNumber {
//                        MovieStore.shared.fetchMovies(from: .popular, page: 1) { result in
//                            switch result {
//                            case .success(let movies):
//                                fetchedRandomMovies.append(movie)
//                            case .failure(let error):
//                                print(error.localizedDescription)
//                            }
//                        }
//                    }

                    var fetchedMovies = [Movie]()
                    let dispatchGroup = DispatchGroup()

                    for id in randomNumbers {
                        dispatchGroup.enter()
                        print("Fetching movies from: randomiser")
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
    
//    func fetchRandomMovie(movieListState: MovieListState) {
//        let numberOfPages = 3
//        let resultsPerPage = 20
//        let totalResults = numberOfPages * resultsPerPage
//        let randomNumber = Int.random(in: 1...totalResults)
//
//        let dispatchGroup = DispatchGroup()
//
//        for pageNumber in 1...numberOfPages {
//            dispatchGroup.enter()
//            movieListState.loadMovies(from: .popular, page: pageNumber) { _ in
//                if let movieID = movieListState.movies.randomElement()?.id {
//                    movieListState.movieID = movieID
//                }
//                dispatchGroup.leave()
//            }
//        }
//
//        dispatchGroup.notify(queue: .main) {
//            print("All pages fetched and processed.")
//        }
//    }
}

struct RandomiserView_Previews: PreviewProvider {
    static var previews: some View {
        RandomiserView(numOptions: .constant(3),
                       year: .constant(nil),
                       voteCountGte: .constant(nil),
                       genres: .constant(nil),
                       originalLanguage: .constant(nil),
                       watchProviders: .constant(nil),
                       watchRegion: .constant(nil),
                       movie: Movie.stubbedMovie)
    }
}

//// Step 1: Get 3 random numbers from 1 to 50
//func getRandomPageNumbers() async -> [Int] {
//    return (1...50).randomSample(count: 3)
//}
//
//// Step 2: Link to a function that applies the numbers to the selected genres
//func applyFiltersToAPI(pages: [Int], genres: Int) async {
//    await RandomMovieStore.shared.discoverMovies(pages: pages, genres: genres) { result in
//        // Handle the API response here
//        switch result {
//        case .success(let movieResponse):
//            // Perform actions with the movie response
//            print("API call successful. Received movie response: \(movieResponse)")
//        case .failure(let error):
//            // Handle the API error
//            print("API call failed with error: \(error)")
//        }
//    }
//}

//// Step 3: Generate 3 random numbers from 1 to 20
//func getRandomMovieCounts() async -> [Int] {
//    return (1...20).randomSample(count: 3)
//}
//
//// Step 4: Find the ID of a movie
//func findMovieID() async -> Int {
//    let randomMovieID = // Generate a random movie ID based on your requirements
//    // Perform actions with the movie ID
//    print("Randomly selected movie ID: \(randomMovieID)")
//    return randomMovieID
//}
//
//// Helper function to generate random samples from a range
//extension Range where Bound == Int {
//    func randomSample(count: Int) -> [Int] {
//        guard count <= self.count else {
//            fatalError("Sample count exceeds range")
//        }
//        let shuffled = self.shuffled()
//        return Array(shuffled.prefix(count))
//    }
//}
//
//// Main async function
//func performTask() async {
//    let pageNumbers = await getRandomPageNumbers()
//    let selectedGenres = 123 // Provide the selected genre ID here
//
//    await applyFiltersToAPI(pages: pageNumbers, genres: selectedGenres)
//
//    let movieCounts = await getRandomMovieCounts()
//    let randomMovieID = await findMovieID()
//
//    // Perform further actions with the page numbers, movie counts, and random movie ID
//}
//
//// Execute the task
//Task {
//    await performTask()
//}
