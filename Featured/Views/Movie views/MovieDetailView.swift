//
//  MovieDetailView.swift
//  Featured2
//
//  Created by Joost van Grieken on 06/04/2023.
//

// MARK: Hantert de detail pagina

import SwiftUI

struct MovieDetailView: View {
    let movieId: Int
    @ObservedObject private var movieDetailState = MovieDetailState()
    
    @EnvironmentObject var settings: UserSettings

    var body: some View {
        ZStack {
            LoadingView(isLoading: self.movieDetailState.isLoading, error: self.movieDetailState.error) {
                self.movieDetailState.loadMovie(id: self.movieId)
            }
            
            if movieDetailState.movie != nil {
                MovieDetailListView(movie: self.movieDetailState.movie!, provider: nil, username: "")
            }
        }
        .onAppear {
            self.movieDetailState.loadMovie(id: self.movieId)
        }
    }
}

// MARK: Hantert de stijl voor de Detail pagina

struct MovieDetailListView: View {
    
    @StateObject private var settings = UserSettings()
    
    struct CustomColor {
        static let locked = Color("locked")
    }
    
    let movie: Movie
    @State private var selectedTrailer: MovieVideo?
    
    let provider: Provider?
    @ObservedObject private var imageLoader = ImageLoader()
    
    let username: String

    @State private var selectedScore: Int?
    @State private var watchedOn = false
    @State private var savedOn = false
    
    @StateObject private var viewModel = MovieProviderViewModel()
    
    var body: some View {
        ScrollView {
            MovieBackdropCard(movie: movie)
            
            HStack {
                if !viewModel.flatrateProviders.isEmpty {
                    Text("Stream on: ")
                    + Text(viewModel.flatrateProviders.map { $0.provider_name }.joined(separator: ", "))
                        .font(.headline)
                } else {
                    Text("No provider available")
                }
            }
            .onAppear {
                viewModel.fetchProviderData(id: movie.id)
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    MoviePosterCard(movie: movie)
                        .frame(width: 160, height: 240)
                    
                    Spacer()
                        .frame(width: 20)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Spacer()
                        Text(movie.title)
                            .font(.system(size: 20).weight(.bold))
                        Text(movie.yearText)
                        if let director = movie.directors?.first?.name {
                            Text(director)
                                .font(
                                    .system(size: 16)
                                    .weight(.medium)
                                )
                        }
                        Text(movie.durationText)
                        
                        Spacer()
                        
                        HStack {
                            if settings.isLoggedIn {
                                VStack {
                                    Picker("Add a score", selection: $selectedScore) {
                                        Text("Add a score").tag(nil as Int?)
                                        ForEach(1...10, id: \.self) { score in
                                            Text("\(score)/10").tag(score as Int?)
                                        }
                                    }
                                    .pickerStyle(DefaultPickerStyle())
                                    .frame(width: 150)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.accentColor, lineWidth: 2)
                                    )
                                    .labelsHidden()
//                                    .onAppear() {
//                                        selectedScore = Int(UserDefaults.standard.getRatedState(movieId: movie.id))
//                                    }
                                }
                            } else {
                                Text("User not logged in")
                                    .foregroundColor(CustomColor.locked)
                                    .padding(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10).stroke(CustomColor.locked, lineWidth: 2))
                            }
                        }
                        
                        Divider()
                        
                        HStack {
                            Image("Heart (rated)")
                                .resizable()
                                .frame(width: 35, height: 35)
                                .padding(.trailing, -5)
                            HStack(alignment: .bottom) {
                                Text(movie.ratingText).foregroundColor(.accentColor)
                                    .font(.system(size: 18) .weight(.medium))
                                Text(movie.formattedVoteCount).foregroundColor(.accentColor)
                                    .font(.system(size: 16))
                            }
                        }
                    }
                }
                .frame(height: 240)
                
                Spacer()
                    .frame(height: 10)
                
                HStack(alignment: .center) {
                    Spacer()
                        .frame(width: 30)
                    
                    Button(action: {
                        if settings.isLoggedIn, watchedOn {
                            UserDefaults.standard.setWatchedMovieCount(value: false, movieId: movie.id, durationText: movie.durationText)
                            settings.removeMovieID(movieID: movie.id) // Remove movie ID from savedMovieIDs
                        } else {
                            UserDefaults.standard.setWatchedMovieCount(value: true, movieId: movie.id, durationText: movie.durationText)
                            settings.addMovieID(movieID: movie.id) // Save movie ID to savedMovieIDs
                        }
                        watchedOn.toggle()
                        print(settings.watchedMovieIDs)
                    }) {
                        VStack(spacing: 3) {
                            if !settings.isLoggedIn {
                                Image("Watch (locked)")
                                Text("Watch").foregroundColor(CustomColor.locked)
                            } else if watchedOn {
                                Image("Watched")
                                Text("Tracked")
                            } else {
                                Image("Watch")
                                Text("Track")
                            }
                        }
                    }
                    .disabled(!settings.isLoggedIn)
                    .onAppear {
                        watchedOn = UserDefaults.standard.getWatchedState(movieId: movie.id)
                    }
                    
                    Spacer()
                    
                    Button(action: { // Save button
                        if settings.isLoggedIn, savedOn {
                            UserDefaults.standard.setSavedState(value: false, movieId: movie.id)
                            settings.unSaveMovieID(movieID: movie.id)
                        } else {
                            UserDefaults.standard.setSavedState(value: true, movieId: movie.id)
                            settings.saveMovieID(movieID: movie.id)
                        }
                        savedOn.toggle()
                    }) {
                        VStack(spacing: 3) {
                            if !settings.isLoggedIn {
                                Image("Save (locked)")
                                Text("Save").foregroundColor(CustomColor.locked)
                            } else if savedOn {
                                Image("Saved")
                                Text("saved")
                            } else {
                                Image("Save")
                                Text("Save")
                            }
                        }
                    }
                    .disabled(!settings.isLoggedIn)
                    .onAppear {
                        savedOn = UserDefaults.standard.getSavedState(movieId: movie.id)
                    }

                    Spacer()
                    
                    if let trailers = movie.youtubeTrailers, !trailers.isEmpty {
                        let trailer = trailers[0]
                        
                        Button(action: {
                            self.selectedTrailer = trailer
                        }) {
                            HStack {
                                Text("Trailer")
                                Image(systemName: "play.fill")
                                    .foregroundColor(Color.accentColor)
                            }
                        }
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    Spacer()
                        .frame(width: 20)
                }
                .sheet(item: self.$selectedTrailer) { trailer in
                    SafariView(url: trailer.youtubeURL!)
                }
                
                Divider()
                    .frame(height: 20)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Genres:")
                        .font(.system(size: 16) .weight(.bold))
                    Text(movie.genreText)
                }
                
                Divider()
                    .frame(height: 20)
                
                VStack {
                    Text(movie.overview)
                }
                
                Spacer()
                    .frame(height: 30)
                
                HStack(alignment: .top, spacing: 6) {
                    Spacer()
                    if movie.cast != nil && movie.cast!.count > 0 {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Cast").font(.headline)
                            ForEach(self.movie.cast!.prefix(9)) { cast in
                                Text(cast.name)
                            }
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        Spacer()
                        
                    }
                    
                    if movie.crew != nil && movie.crew!.count > 0 {
                        VStack(alignment: .leading, spacing: 6) {
                            if movie.directors != nil && movie.directors!.count > 0 {
                                Text("Director(s)").font(.headline)
                                ForEach(self.movie.directors!.prefix(2)) { crew in
                                    Text(crew.name)
                                }
                            }
                            
                            if movie.producers != nil && movie.producers!.count > 0 {
                                Text("Producer(s)").font(.headline)
                                    .padding(.top)
                                ForEach(self.movie.producers!.prefix(2)) { crew in
                                    Text(crew.name)
                                }
                            }
                            
                            if movie.screenWriters != nil && movie.screenWriters!.count > 0 {
                                Text("Screenwriter(s)").font(.headline)
                                    .padding(.top)
                                ForEach(self.movie.screenWriters!.prefix(2)) { crew in
                                    Text(crew.name)
                                }
                            }
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding()
        }
        .environmentObject(settings)
        .edgesIgnoringSafeArea(.top)
    }
}

struct MovieDetailImage: View {
    
    @ObservedObject var imageLoader: ImageLoader
    let imageURL: URL
    
    var body: some View {
        ZStack {
            Rectangle().fill(Color.gray.opacity(0.3))
            if self.imageLoader.image != nil {
                Image(uiImage: self.imageLoader.image!)
                    .resizable()
            }
        }
        .aspectRatio(16/9, contentMode: .fit)
        .onAppear {
            self.imageLoader.loadImage(with: self.imageURL)
        }
    }
}

struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MovieDetailView(movieId: Movie.stubbedMovie.id)
        }
    }
}
