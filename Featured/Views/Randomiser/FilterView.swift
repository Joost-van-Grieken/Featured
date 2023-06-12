//
//  FilterView.swift
//  Featured
//
//  Created by Joost van Grieken on 10/04/2023.
//

import SwiftUI

struct FilterView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var numOption: Int
    @StateObject var selectedGenresViewModel = SelectedGenresViewModel()
    @StateObject var selectedProviderViewModel = SelectedProviderViewModel()
    
    struct CustomColor {
        static let textColor = Color("textColor")
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Picker("Number of options", selection: $numOption) {
                        ForEach(1...10, id: \.self) { value in
                            Text("\(value)").tag(value)
                                .foregroundColor(CustomColor.textColor)
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
                                    .environmentObject(selectedProviderViewModel)) { // Pass the SelectedProviderViewModel as an environment object
                        HStack {
                            Text("Providers")
                            if !selectedProviderViewModel.selectedProvider.isEmpty {
                                Text(selectedProviderViewModel.selectedProviderNames())
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
                Spacer()
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                    print(selectedGenresViewModel.selectedGenres)
                    print(selectedProviderViewModel.selectedProvider)
                }) {
                    Text("Done")
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
        FilterView(numOption: .constant(3))
    }
}

class SelectedGenresViewModel: ObservableObject {
    @Published var selectedGenres: Set<Genre> = []
    
    func selectedGenreNames() -> String {
        return selectedGenres.map { $0.name }.joined(separator: ", ")
    }
}

class SelectedProviderViewModel: ObservableObject {
    @Published var selectedProvider: Set<Provider> = []
    
    func selectedProviderNames() -> String {
        return selectedProvider.map { $0.provider_name }.joined(separator: ", ")
    }
}

struct GenreView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var selectedGenresViewModel: SelectedGenresViewModel
    @ObservedObject var viewModel: GenreViewModel
    
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

struct ProviderView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var selectedProviderViewModel: SelectedProviderViewModel
    @ObservedObject var viewModel: ProviderViewModel
    
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
