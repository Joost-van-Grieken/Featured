//
//  FilterView.swift
//  Featured
//
//  Created by Joost van Grieken on 10/04/2023.
//

// MARK: Hantert de FilterView

import SwiftUI

struct FilterView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var settings = UserSettings()
    
    @Binding var isFilterPresented: Bool
    @Binding var numOption: Int
    @ObservedObject var selectedGenresViewModel = SelectedGenresViewModel()
    @ObservedObject var selectedProviderViewModel = SelectedProviderViewModel()
    @ObservedObject var selectedLanguageViewModel = SelectedLanguageViewModel()
    @ObservedObject var selectedEraViewModel = SelectedEraViewModel()
    @ObservedObject var selectedScoreViewModel = SelectedScoreViewModel()
    
    @State var savedForLater: Bool = false
    var randomizeAction: () -> Void
    
    struct CustomColor {
        static let textColor = Color("textColor")
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Picker("Number of options", selection: $numOption) {
                        ForEach(1...10, id: \.self) { value in
                            Text("\(value)")
                                .tag(value)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    NavigationLink(destination: GenreView(viewModel: GenreViewModel())
                        .environmentObject(selectedGenresViewModel)) {
                            HStack {
                                Text("Genres")
                                if !selectedGenresViewModel.selectedGenres.isEmpty {
                                    Text(selectedGenresViewModel.selectedGenreNames())
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    
                    NavigationLink(destination: ProviderView(viewModel: ProviderViewModel())
                        .environmentObject(selectedProviderViewModel)) {
                            HStack {
                                Text("Streaming on")
                                if !selectedProviderViewModel.selectedProvider.isEmpty {
                                    Text(selectedProviderViewModel.selectedProviderNames())
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    
                    NavigationLink(destination: LanguageView(viewModel: LanguageViewModel())
                        .environmentObject(selectedLanguageViewModel)) {
                            HStack {
                                Text("Languages")
                                if !selectedLanguageViewModel.selectedLanguages.isEmpty {
                                    Text(selectedLanguageViewModel.selectedLanguageNames())
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    
                    NavigationLink(destination: EraView(viewModel: EraViewModel())
                        .environmentObject(selectedEraViewModel)) {
                            HStack {
                                Text("Era's")
                                if !selectedEraViewModel.selectedEras().isEmpty {
                                    Text(selectedEraViewModel.selectedEras())
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    
                    NavigationLink(destination: ScoreView(viewModel: ScoreViewModel())
                        .environmentObject(selectedScoreViewModel)) {
                            HStack {
                                Text("Rating")
                                if !selectedScoreViewModel.selectedScoreItems.isEmpty {
                                    Text(selectedScoreViewModel.selectedScores())
                                        .foregroundColor(.gray)
                                }
                            }
                        }
//                    Section {
//                        if settings.isLoggedIn {
//                            Toggle(isOn: $savedForLater, label: {
//                                Text("Saved for later")
//                            })
//                        } else {
//                            Toggle(isOn: $savedForLater, label: {
//                                Image(systemName: "lock")
//                                Text("Saved for later")
//                            })
//                            .disabled(true)
//                        }
//                    }
                }
                .foregroundColor(CustomColor.textColor)
                
                Spacer()
                
                Button(action: {
                    isFilterPresented = false
                    randomizeAction()
                    print(selectedGenresViewModel.selectedGenres)
                    print(selectedProviderViewModel.selectedProvider)
                    print(selectedLanguageViewModel.selectedLanguages)
                    print(selectedScoreViewModel.selectedScores)
                }) {
                    Text("Randomise")
                        .foregroundColor(.white)
                        .frame(width: 300, height: 50)
                        .background(Color.accentColor)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Filter")
        }
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView(
            isFilterPresented: .constant(false),
            numOption: .constant(3),
            selectedGenresViewModel: SelectedGenresViewModel(),
            selectedProviderViewModel: SelectedProviderViewModel(),
            selectedLanguageViewModel: SelectedLanguageViewModel(),
            selectedEraViewModel: SelectedEraViewModel(),
            selectedScoreViewModel: SelectedScoreViewModel(),
            savedForLater: false,
            randomizeAction: { }
        )
    }
}


// MARK: Genre filter view
class SelectedGenresViewModel: ObservableObject {
    @Published var selectedGenres: Set<Genre> = []
    
    func selectedGenreNames() -> String {
        return selectedGenres.map { $0.name }.joined(separator: ",")
    }
}

struct GenreView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var selectedGenresViewModel: SelectedGenresViewModel
    @StateObject var viewModel: GenreViewModel
    
    struct CustomColor {
        static let textColor = Color("textColor")
    }
    
    var body: some View {
        VStack {
            List(viewModel.genres, id: \.id) { genre in
                Button(action: {
                    toggleGenreSelection(genre)
                }) {
                    HStack {
                        Text(genre.name)
                            .foregroundColor(CustomColor.textColor)
                        Spacer()
                        if selectedGenresViewModel.selectedGenres.contains(genre) {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color.accentColor)
                        }
                    }
                }
            }
            
            Button(action: {
                dismissGenreView()
                print(selectedGenresViewModel.selectedGenres)
            }) {
                Text("Submit")
                    .foregroundColor(.white)
                    .frame(width: 300, height: 50)
                    .background(Color.accentColor)
                    .cornerRadius(10)
            }
        }
        .onAppear {
            viewModel.fetchGenres()
        }
    }
    
    private func toggleGenreSelection(_ genre: Genre) {
        if selectedGenresViewModel.selectedGenres.contains(genre) {
            selectedGenresViewModel.selectedGenres.remove(genre)
        } else {
            selectedGenresViewModel.selectedGenres.insert(genre)
        }
    }
    
    private func dismissGenreView() {
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: provider filter view
class SelectedProviderViewModel: ObservableObject {
    @Published var selectedProvider: Set<Provider> = []
    
    func selectedProviderNames() -> String {
        return selectedProvider.map { $0.provider_name }.joined(separator: ",")
    }
}

struct ProviderView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var selectedProviderViewModel: SelectedProviderViewModel
    @StateObject var viewModel: ProviderViewModel
    
    struct CustomColor {
        static let textColor = Color("textColor")
    }
    
    var body: some View {
        VStack {
            List(viewModel.providers, id: \.provider_id) { provider in
                Button(action: {
                    toggleProviderSelection(provider)
                }) {
                    HStack {
                        Text(provider.provider_name)
                            .foregroundColor(CustomColor.textColor)
                        Spacer()
                        if selectedProviderViewModel.selectedProvider.contains(provider) {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color.accentColor)
                        }
                    }
                }
            }
            
            Button(action: {
                dismissProviderView()
                print(selectedProviderViewModel.selectedProvider)
            }) {
                Text("Submit")
                    .foregroundColor(.white)
                    .frame(width: 300, height: 50)
                    .background(Color.accentColor)
                    .cornerRadius(10)
            }
        }
        .onAppear {
            viewModel.fetchProviders()
        }
    }
    
    private func toggleProviderSelection(_ provider: Provider) {
        if selectedProviderViewModel.selectedProvider.contains(provider) {
            selectedProviderViewModel.selectedProvider.remove(provider)
        } else {
            selectedProviderViewModel.selectedProvider.insert(provider)
        }
    }
    
    private func dismissProviderView() {
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: language filter view
class SelectedLanguageViewModel: ObservableObject {
    @Published var selectedLanguages: Set<Language> = []
    
    func selectedLanguageNames() -> String {
        return selectedLanguages.map { $0.english_name }.joined(separator: ",")
    }
}

struct LanguageView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var selectedLanguageViewModel: SelectedLanguageViewModel
    @StateObject var viewModel: LanguageViewModel
    
    struct CustomColor {
        static let textColor = Color("textColor")
    }
    
    var body: some View {
        VStack {
            List(viewModel.languages, id: \.iso_639_1) { language in
                Button(action: {
                    toggleLanguageSelection(language)
                }) {
                    HStack {
                        Text(language.english_name)
                            .foregroundColor(CustomColor.textColor)
                        Spacer()
                        if selectedLanguageViewModel.selectedLanguages.contains(language) {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color.accentColor)
                        }
                    }
                }
            }
            
            Button(action: {
                dismissLanguageView()
                print(selectedLanguageViewModel.selectedLanguages)
            }) {
                Text("Submit")
                    .foregroundColor(.white)
                    .frame(width: 300, height: 50)
                    .background(Color.accentColor)
                    .cornerRadius(10)
            }
        }
        .onAppear {
            viewModel.fetchLanguages()
        }
    }
    
    private func toggleLanguageSelection(_ language: Language) {
        if selectedLanguageViewModel.selectedLanguages.contains(language) {
            selectedLanguageViewModel.selectedLanguages.remove(language)
        } else {
            selectedLanguageViewModel.selectedLanguages.insert(language)
        }
    }
    
    private func dismissLanguageView() {
        presentationMode.wrappedValue.dismiss()
    }
}


// MARK: Era filter view
struct EraItem: Codable, Identifiable, Hashable {
    let id: Int
    let value: [Int]

    static func ==(lhs: EraItem, rhs: EraItem) -> Bool {
        return lhs.id == rhs.id && lhs.value == rhs.value
    }
}

class EraViewModel: ObservableObject {
    @Published var eras: [EraItem]
    
    init() {
        let currentYear = Calendar.current.component(.year, from: Date())
        let startYear = ((currentYear / 10) * 10)
        let endYear = startYear + 10
        let startYearsOfDecades = stride(from: startYear - 10, through: 1920, by: -10)
        eras = startYearsOfDecades.compactMap { startDecade in
            let endDecade = startDecade + 9
            let years = Array(max(startDecade, 1920)...min(endDecade, currentYear))
            return EraItem(id: startDecade, value: years)
        }
        
        // voegt de huidige decenium als het nog niet is toegevoegd
        let currentDecade = Array(startYear...min(endYear, currentYear))
        let currentDecadeItem = EraItem(id: startYear, value: currentDecade)
        if eras.first?.id != startYear {
            eras.insert(currentDecadeItem, at: 0)
        }
    }
}

class SelectedEraViewModel: ObservableObject {
    @Published var selectedEraItems: Set<EraItem> = []
    
    func selectedEras() -> String {
        let selectedItemsArray = Array(selectedEraItems)
        let selectedEraNames = selectedItemsArray.map { "\(String($0.id))" }
        return selectedEraNames.joined(separator: ",")
    }
}

struct EraView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var selectedEraViewModel: SelectedEraViewModel
    @StateObject var viewModel: EraViewModel
    
    struct CustomColor {
        static let textColor = Color("textColor")
    }
    
    var body: some View {
        VStack {
            List(viewModel.eras) { eraItem in
                Button(action: {
                    toggleEraSelection(eraItem)
                }) {
                    HStack {
                        Text("\(eraItem.id)")
                            .foregroundColor(CustomColor.textColor)
                        Spacer()
                        if selectedEraViewModel.selectedEraItems.contains(eraItem) {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color.accentColor)
                        }
                    }
                }
            }
            
            Button(action: {
                dismissEraView()
                print(selectedEraViewModel.selectedEras())
            }) {
                Text("Submit")
                    .foregroundColor(.white)
                    .frame(width: 300, height: 50)
                    .background(Color.accentColor)
                    .cornerRadius(10)
            }
        }
    }
    
    private func toggleEraSelection(_ eraItem: EraItem) {
        if selectedEraViewModel.selectedEraItems.contains(eraItem) {
            selectedEraViewModel.selectedEraItems.remove(eraItem)
        } else {
            selectedEraViewModel.selectedEraItems.insert(eraItem)
        }
    }
    
    private func dismissEraView() {
        presentationMode.wrappedValue.dismiss()
    }
}


// MARK: Score filter view
struct ScoreItem: Codable, Identifiable, Hashable {
    let id: Int
    let value: Int

    static func ==(lhs: ScoreItem, rhs: ScoreItem) -> Bool {
        return lhs.id == rhs.id
        && lhs.value == rhs.value
    }
}

class ScoreViewModel: ObservableObject {
    @Published var scores: [ScoreItem]

    init() {
        scores = [
            ScoreItem(id: 1, value: 2),
            ScoreItem(id: 2, value: 4),
            ScoreItem(id: 3, value: 6),
            ScoreItem(id: 4, value: 7),
            ScoreItem(id: 5, value: 10)
        ]
    }
}

class SelectedScoreViewModel: ObservableObject {
    @Published var selectedScoreItems: Set<ScoreItem> = []
    
    func selectedScores() -> String {
        let selectedItemsArray = Array(selectedScoreItems)
        return selectedItemsArray.map { String($0.id) }.joined(separator: ",")
    }
}

struct ScoreView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var selectedScoreViewModel: SelectedScoreViewModel
    @StateObject var viewModel: ScoreViewModel

    struct CustomColor {
        static let textColor = Color("textColor")
    }

    var body: some View {
        VStack {
            List(viewModel.scores) { scoreItem in
                Button(action: {
                    toggleScoreSelection(scoreItem)
                }) {
                    HStack {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: index <= scoreItem.id ? "star.fill" : "star")
                                .foregroundColor(index <= scoreItem.id ? .accentColor : .gray)
                        }
                        Spacer()
                        if selectedScoreViewModel.selectedScoreItems.contains(scoreItem) {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color.accentColor)
                        }
                    }
                }
            }
            
            Button(action: {
                dismissScoreView()
            }) {
                Text("Submit")
                    .foregroundColor(.white)
                    .frame(width: 300, height: 50)
                    .background(Color.accentColor)
                    .cornerRadius(10)
            }
        }
    }

    private func toggleScoreSelection(_ scoreItem: ScoreItem) {
        if selectedScoreViewModel.selectedScoreItems.contains(scoreItem) {
            selectedScoreViewModel.selectedScoreItems.remove(scoreItem)
        } else {
            selectedScoreViewModel.selectedScoreItems.insert(scoreItem)
        }
    }

    private func dismissScoreView() {
        presentationMode.wrappedValue.dismiss()
    }
}
