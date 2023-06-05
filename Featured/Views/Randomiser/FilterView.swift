//
//  FilterView.swift
//  Featured
//
//  Created by Joost van Grieken on 10/04/2023.
//

import SwiftUI

let allMedia: [Filter] = [Filter(name: "Movies"), Filter(name: "Tv Show")]
let allList: [Filter] = [Filter(name: "Popular"), Filter(name: "Top rated")]
let allEras: [Filter] = [Filter(name: "1930"), Filter(name: "1940"), Filter(name: "1950"), Filter(name: "1960"), Filter(name: "1970"), Filter(name: "1980"), Filter(name: "1990"), Filter(name: "2000"), Filter(name: "2010"), Filter(name: "2020")]
let allScore: [Filter] = [Filter(name: "1.0"), Filter(name: "2.0"), Filter(name: "3.0"), Filter(name: "4.0"), Filter(name: "5.0")]

let allGenres: [FilterGenres] = [FilterGenres(name: "Action", number: 28), FilterGenres(name: "Adventure", number: 12), FilterGenres(name: "Animation", number: 16), FilterGenres(name: "Comedy", number: 35), FilterGenres(name: "Crime", number: 80), FilterGenres(name: "Documentary", number: 99), FilterGenres(name: "Drama", number: 18), FilterGenres(name: "Family", number: 10751), FilterGenres(name: "Fantasy", number: 14), FilterGenres(name: "History", number: 36), FilterGenres(name: "Horror", number: 27), FilterGenres(name: "Music", number: 10402), FilterGenres(name: "Mystery", number: 9648), FilterGenres(name: "Romance", number: 10749), FilterGenres(name: "Sciencee Fiction", number: 878), FilterGenres(name: "Thriller", number: 53), FilterGenres(name: "War", number: 10752), FilterGenres(name: "Western", number: 37)]

let allLanguages: [Filter] = [Filter(name: "Dutch"), Filter(name: "English"), Filter(name: "French"), Filter(name: "German"), Filter(name: "Japanese"), Filter(name: "Korean"), Filter(name: "Spanish")]
let allProviders: [Filter] = [Filter(name: "Netflix"), Filter(name: "Amazon Prime"), Filter(name: "Disney+"), Filter(name: "Apple TV"), Filter(name: "HBO Max"), Filter(name: "Videoland")]
let allRegions: [Filter] = [Filter(name: "NL"), Filter(name: "UK"), Filter(name: "US"), Filter(name: "AU"), Filter(name: "DE"), Filter(name: "FR"), Filter(name: "JP"), Filter(name: "KR")]

struct FilterView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var numOptions: Int
    @Binding var genres: String?
    
    let movie: Movie
    
    @StateObject private var movieGenres = MovieGenres()
    
    let optionRange = 1...10
    @State var selectedGenre: Set<FilterGenres> = []
    
    @State private var selectedGenreIds: Set<Int> = []

    @State private var showRandomiser = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    VStack {
                        Picker("Nr. of options", selection: $numOptions) {
                            ForEach(optionRange, id: \.self) { option in
                                Text("\(option)")
                            }
                        }
                    }
                    
                    VStack {
                        MultiSelector(
                            label: Text("Genre"),
                            options: allGenres,
                            optionToString: { $0.name },
                            selected: $selectedGenre
                        )
                    }
                }
                
                Button(action: {
                    saveSelectedValues(genres: selectedGenre)
                    
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Done")
                        .foregroundColor(.white)
                        .frame(width:300, height: 50)
                        .background(Color.accentColor)
                        .cornerRadius(10)
                })
            }
            .navigationTitle("Filter")
        }
    }
}

func saveSelectedValues(genres: Set<FilterGenres>) {
// Convert the selected options to an array of their names
    let selectedGenres = genres.map { $0.name }
    
// Save the selected values to UserDefaults, database, or any other storage mechanism
    UserDefaults.standard.set(selectedGenres, forKey: "selectedGenre")
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView(numOptions: .constant(3),
                   genres: .constant(nil),
                   movie: Movie.stubbedMovie)
    }
}


//struct FilterView: View {
//    @Environment(\.presentationMode) var presentationMode
//
//    @Binding var numOptions: Int
//    @Binding var year: Int?
//    @Binding var voteCountGte: Double?
//    @Binding var genres: String?
//    @Binding var originalLanguage: String?
//    @Binding var watchProviders: String?
//    @Binding var watchRegion: String?
//
//    let movie: Movie
//
//    @StateObject private var movieGenres = MovieGenres()
//
//    let optionRange = 1...10
//    @State var selectedMedia: Filter?
//    @State var selectedList: Filter?
//    @State var selectedEra: Set<Filter> = []
//    @State var selectedScore: Set<Filter> = []
//    @State var selectedGenre: Set<FilterGenres> = []
//    @State var selectedLanguage: Set<Filter> = []
//    @State var selectedProvider: Set<Filter> = []
//    @State var selectedRegion: Filter?
//
//    @State private var selectedGenreIds: Set<Int> = []
//
//    @State private var showRandomiser = false
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                List {
//                    VStack {
//                        Picker("Choose your poison", selection: $selectedMedia) {
//                            ForEach(allMedia, id: \.name) { media in
//                                Text(media.name)
//                            }
//                        }
//                    }
//
//                    VStack {
//                        Picker("Nr. of options", selection: $numOptions) {
//                            ForEach(optionRange, id: \.self) { option in
//                                Text("\(option)")
//                            }
//                        }
//                    }
//
//                    VStack {
//                        Picker("List", selection: $selectedList) {
//                            ForEach(allList, id: \.name) { list in
//                                Text(list.name)
//                            }
//                        }
//                        .onChange(of: selectedList) { newList in
//                            var fetchedRandomMovies = [Movie]()
//
//                            if let selected = newList {
//                                switch selected.name {
//                                case "Popular":
//                                    print("Fetching movies from: Popular")
//                                    MovieStore.shared.fetchMovies(from: .popular) { result in
//                                        switch result {
//                                        case .success(let movies):
//                                            fetchedRandomMovies.append(movie)
//                                        case .failure(let error):
//                                            print(error.localizedDescription)
//                                        }
//                                    }
//
//                                case "Top rated":
//                                    print("Fetching movies from: Top rated")
//                                    MovieStore.shared.fetchMovies(from: .topRated) { result in
//                                        switch result {
//                                        case .success(let movies):
//                                            fetchedRandomMovies.append(movie)
//                                        case .failure(let error):
//                                            print(error.localizedDescription)
//                                        }
//                                    }
//                                default:
//                                    break
//                                }
//                            }
//                        }
//                    }
//
//
//                    VStack {
//                        MultiSelector(
//                            label: Text("Era"),
//                            options: allEras,
//                            optionToString: { $0.name },
//                            selected: $selectedEra
//                        )
//                    }
//
//                    VStack {
//                        MultiSelector(
//                            label: Text("Rating"),
//                            options: allScore,
//                            optionToString: { $0.name },
//                            selected: $selectedScore
//                        )
//                    }
//
//                    VStack {
//                        MultiSelector(
//                            label: Text("Genre"),
//                            options: allGenres,
//                            optionToString: { $0.name },
//                            selected: $selectedGenre
//                        )
//                    }
//
//                    VStack {
//                        MultiSelector(
//                            label: Text("Language"),
//                            options: allLanguages,
//                            optionToString: { $0.name },
//                            selected: $selectedLanguage
//                        )
//                    }
//
//                    VStack {
//                        MultiSelector(
//                            label: Text("Provider"),
//                            options: allProviders,
//                            optionToString: { $0.name },
//                            selected: $selectedProvider
//                        )
//                    }
//
//                    VStack {
//                        Picker("Region", selection: $selectedRegion) {
//                            ForEach(allRegions, id: \.name) { region in
//                                Text(region.name)
//                            }
//                        }
//                    }
//                }
//
//                Button(action: {
//                    saveSelectedValues(genres: selectedGenre)
//
//                    self.presentationMode.wrappedValue.dismiss()
//                }, label: {
//                    Text("Done")
//                        .foregroundColor(.white)
//                        .frame(width:300, height: 50)
//                        .background(Color.accentColor)
//                        .cornerRadius(10)
//                })
//            }
//            .navigationTitle("Filter")
//        }
//    }
//}
//
//func saveSelectedValues(genres: Set<FilterGenres>) {
//    (media: Filter?, list: Filter?, era: Set<Filter>, genres: Set<Filter>, language: Set<Filter>, provider: Set<Filter>, region: Filter?)
////     Convert the selected options to an array of their names
//    let selectedMedia = media.map { $0.name }
//    let selectedNumOptions = numOptions.map { $0.name }
//    let selectedList = list.map { $0.name }
//    let selectedEra = era.map { $0.name }
//    let selectedRating = rating.map { $0.name }
//    let selectedGenres = genres.map { $0.name }
//    let selectedLanguage = language.map { $0.name }
//    let selectedProvider = provider.map { $0.name }
//    let selectedRegion = region.map { $0.name }
//
//    // Save the selected values to UserDefaults, database, or any other storage mechanism
//    UserDefaults.standard.set(selectedMedia, forKey: "selectedMedia")
//    UserDefaults.standard.set(selectedNumOptions, forKey: "selectedNumOptions")
//    UserDefaults.standard.set(selectedList, forKey: "selectedList")
//    UserDefaults.standard.set(selectedEra, forKey: "selectedEra")
//    UserDefaults.standard.set(selectedRating, forKey: "selectedRating")
//    UserDefaults.standard.set(selectedGenres, forKey: "selectedGenre")
//    UserDefaults.standard.set(selectedLanguage, forKey: "selectedLanguages")
//    UserDefaults.standard.set(selectedProvider, forKey: "selectedProviders")
//    UserDefaults.standard.set(selectedRegion, forKey: "selectedRegions")
//}
//
//struct FilterView_Previews: PreviewProvider {
//    static var previews: some View {
//        FilterView(numOptions: .constant(3),
//                   year: .constant(nil),
//                   voteCountGte: .constant(nil),
//                   genres: .constant(nil),
//                   originalLanguage: .constant(nil),
//                   watchProviders: .constant(nil),
//                   watchRegion: .constant(nil),
//                   movie: Movie.stubbedMovie))
//    }
//}
