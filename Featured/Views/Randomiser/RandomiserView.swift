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
                                    HStack{
//                                        Text("\(numOptions / numOptions)")
                                        Text(movie.title)
                                            .font(
                                                .system(size: 22)
                                                .weight(.bold)
                                            )
                                            .foregroundColor(CustomColor.textColor)
                                    }
                                    MoviePosterCard(movie: movie)
                                        .frame(width: 260, height: 390)
                                    Text(movie.genreText)
                                        .foregroundColor(CustomColor.textColor)
                                    HStack {
                                        Image("Heart")
                                            .resizable()
                                            .frame(width: 25, height: 25)
                                            .padding(.trailing, -5)
                                        Text(movie.ratingText).foregroundColor(.accentColor)
                                    }
                                    .padding(.top, -10)
                                    .padding(.bottom, -10)
                                }
                                .frame(width: 260)
                                .padding(20)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                            }
                        }
                        Spacer()
                    }
                }

                Spacer()

                Button(action: {
                    var randomNumbers = [Int]()
                    while randomNumbers.count < numOptions {
                        let randomNumber = Int.random(in: 1...1000)
                        randomNumbers.append(randomNumber)
                        print(randomNumber)
                    }

                    var fetchedRandomMovies = [Movie]()

                    for randomNumbers in randomNumber {
                        MovieStore.shared.fetchMovies(from: .popular) { result in
                            switch result {
                            case .success(let movies):
                                fetchedRandomMovies.append(movie)
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                    }

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
