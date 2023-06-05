//
//  FilterView.swift
//  Featured
//
//  Created by Joost van Grieken on 10/04/2023.
//

import SwiftUI

struct FilterView: View {
    @ObservedObject var genreModel = GenreViewModel()
    @ObservedObject var providerModel: ProviderViewModel
    
    @State private var selectedGenres: Set<Genre> = []
    @State private var selectedProvider: Set<Provider> = []

    var body: some View {
        NavigationView {
            VStack {
                List {
                    NavigationLink(destination: GenreView(viewModel: genreModel, selectedGenres: $selectedGenres)) {
                        HStack {
                            Text("Genres")
                            if !selectedGenres.isEmpty {
                                Text(selectedGenreNames())
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    NavigationLink(destination: ProviderView(viewModel: providerModel, selectedProviders: $selectedProvider)) {
                        HStack {
                            Text("Providers")
                            if !selectedProvider.isEmpty {
                                Text(selectedProviderNames())
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
                Spacer()
                
                Button(action: {
                    // Perform action with selected genres and providers
                    print(selectedGenres)
                    print(selectedProvider)
                }) {
                    Text("Done")
                        .foregroundColor(.white)
                        .frame(width: 300, height: 50)
                        .background(Color.accentColor)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Filter")
            .onAppear {
                genreModel.fetchGenres()
                providerModel.fetchProviders()
            }
        }
    }

    private func selectedGenreNames() -> String {
        return selectedGenres.map { $0.name }.joined(separator: ", ")
    }

    private func selectedProviderNames() -> String {
        return selectedProvider.map { $0.provider_name }.joined(separator: ", ")
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView(providerModel: ProviderViewModel())
    }
}

struct GenreView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: GenreViewModel
    @Binding var selectedGenres: Set<Genre>
    
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
                        if selectedGenres.contains(genre) {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color.accentColor)
                        }
                    }
                }
            }
            
            Button(action: {
                dismissGenreView()
            }) {
                Text("Submit")
                    .foregroundColor(.white)
                    .frame(width: 300, height: 50)
                    .background(Color.accentColor)
                    .cornerRadius(10)
            }
        }
    }
    
    private func toggleGenreSelection(_ genre: Genre) {
        if selectedGenres.contains(genre) {
            selectedGenres.remove(genre)
        } else {
            selectedGenres.insert(genre)
        }
    }
    
    private func dismissGenreView() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct ProviderView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ProviderViewModel
    @Binding var selectedProviders: Set<Provider>
    
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
                        if selectedProviders.contains(provider) {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color.accentColor)
                        }
                    }
                }
            }
            
            Button(action: {
                dismissProviderView()
            }) {
                Text("Submit")
                    .foregroundColor(.white)
                    .frame(width: 300, height: 50)
                    .background(Color.accentColor)
                    .cornerRadius(10)
            }
        }
    }
    
    private func toggleProviderSelection(_ provider: Provider) {
        if selectedProviders.contains(provider) {
            selectedProviders.remove(provider)
        } else {
            selectedProviders.insert(provider)
        }
    }
    
    private func dismissProviderView() {
        presentationMode.wrappedValue.dismiss()
    }
}
