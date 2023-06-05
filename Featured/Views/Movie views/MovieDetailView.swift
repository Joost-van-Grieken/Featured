//
//  MovieDetailView.swift
//  Featured2
//
//  Created by Joost van Grieken on 06/04/2023.
//

import SwiftUI

struct MovieDetailView: View {
    let movieId: Int
    @ObservedObject private var movieDetailState = MovieDetailState()
    @State private var isLoggedIn = UserDefaults.standard.bool(forKey: UserDefaults.UserDefaultsKeys.isLoggedIn.rawValue) // Add the isLoggedIn property

    var body: some View {
        ZStack {
            LoadingView(isLoading: self.movieDetailState.isLoading, error: self.movieDetailState.error) {
                self.movieDetailState.loadMovie(id: self.movieId)
            }
            
            if movieDetailState.movie != nil {
                MovieDetailListView(movie: self.movieDetailState.movie!, provider: nil, username: "", isLoggedIn: false)
            }
        }
        .onAppear {
            self.movieDetailState.loadMovie(id: self.movieId)
        }
    }
}

struct MovieDetailListView: View {
    
    struct CustomColor {
        static let locked = Color("locked")
    }
    
    let movie: Movie
    @State private var selectedTrailer: MovieVideo?
//    let imageLoader = ImageLoader()
    
    let provider: Provider?
    @ObservedObject private var imageLoader = ImageLoader()
    
    let username: String
    @State var isLoggedIn: Bool

    @State private var selectedScore: Int = 1
    @State private var watchedOn = false
    @State private var savedOn = false
    @State private var isMovieSaved: Bool = false
    
    var body: some View {
        ScrollView {
            MovieBackdropCard(movie: movie)
            
            HStack {
                if let provider = provider {
                    if provider.logo_path != nil {
                        if self.imageLoader.image != nil {
                            Image(uiImage: self.imageLoader.image!)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 40)
                        }
                    }
                } else {
                    Text("No provider found")
                }
            }
            .onAppear {
                if let logoPath = provider?.logo_path {
                    let url = URL(string: "https://image.tmdb.org/t/p/original\(logoPath)")
                    self.imageLoader.loadImage(with: url!)
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    MoviePosterCard(movie: movie)
                        .frame(width: 160, height: 240)
                    
                    Spacer()
                        .frame(width: 20)
                    
                    VStack(alignment: .leading, spacing: 10){
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
                        
                        HStack {
                            Image("Heart (rated)")
                                .resizable()
                                .frame(width: 35, height: 35)
                                .padding(.trailing, -5)
                            HStack(alignment: .bottom) {
                                Text(movie.ratingText).foregroundColor(.accentColor)
                                    .font(.system(size: 18) .weight(.medium))
                                Text(movie.formattedVoteCount).foregroundColor(.accentColor)
                                    .font(.system(size: 12))
                            }
                        }
                        
                        Spacer()
                        
                        HStack {
                            if UserDefaults.standard.getLoggedIn() {
                                // Handle UI when user is logged in
                                Picker("Add a score", selection: $selectedScore) {
                                    ForEach(1...10, id: \.self) { score in
                                        Text("\(score)")
                                    }
                                }
                                .padding(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.accentColor, lineWidth: 2)
                                )
                            } else {
                                // Handle UI when user is not logged in
                                Text("Account required")
                                    .foregroundColor(CustomColor.locked)
                                    .padding(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(CustomColor.locked, lineWidth: 2)
                                    )
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
                        // Watch button
                        if UserDefaults.standard.getLoggedIn() {
                            if watchedOn {
                                UserDefaults.standard.setWatchedMovieCount(value: false, forMovieId: movie.id)
                            } else {
                                UserDefaults.standard.setWatchedMovieCount(value: true, forMovieId: movie.id)
                            }
                            watchedOn.toggle()
                        }
                    }) {
                        VStack {
                            if !UserDefaults.standard.getLoggedIn() {
                                Image("Watch (locked)")
                                Text("watch").foregroundColor(CustomColor.locked)
                            } else if watchedOn {
                                Image("Watched")
                                Text("watched")
                            } else {
                                Image("Watch")
                                Text("watch")
                            }
                        }
                    }
                    .onAppear {
                        watchedOn = UserDefaults.standard.getWatchedState(forMovieId: movie.id)
                    }
                    .disabled(!UserDefaults.standard.getLoggedIn())
                    
                    Spacer()
                    
                    Button(action: {
                        // Save button
                        if UserDefaults.standard.getLoggedIn() {
                            if savedOn {
                                UserDefaults.standard.setSavedState(value: false, forMovieId: movie.id)
                            } else {
                                UserDefaults.standard.setSavedState(value: true, forMovieId: movie.id)
                            }
                            savedOn.toggle()
                        }
                    }) {
                        VStack {
                            if !UserDefaults.standard.getLoggedIn() {
                                Image("Save (locked)")
                                Text("Save").foregroundColor(CustomColor.locked)
                            } else if savedOn {
                                Image("Saved")
                                Text("saved")
                            } else {
                                Image("Save")
                                Text("save")
                            }
                        }
                    }
                    .onAppear {
                        savedOn = UserDefaults.standard.getSavedState(forMovieId: movie.id)
                    }
                    .disabled(!UserDefaults.standard.getLoggedIn())

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
//                        .font(.system(size: 14))
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
