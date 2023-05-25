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
    
    var body: some View {
        ZStack {
            LoadingView(isLoading: self.movieDetailState.isLoading, error: self.movieDetailState.error) {
                self.movieDetailState.loadMovie(id: self.movieId)
            }
            
            if movieDetailState.movie != nil {
                MovieDetailListView(movie: self.movieDetailState.movie!)
                
            }
        }
        .onAppear {
            self.movieDetailState.loadMovie(id: self.movieId)
        }
    }
}

struct MovieDetailListView: View {
    
    let movie: Movie
    @State private var selectedTrailer: MovieVideo?
    let imageLoader = ImageLoader()
    
    @State var selection = 0
    
    var body: some View {
        ScrollView {
            MovieBackdropCard(movie: movie)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    MoviePosterCard(movie: movie)
                        .frame(width: 160, height: 240)
                    
                    Spacer()
                        .frame(width: 20)
                    
                    VStack(alignment: .leading, spacing: 10){
                        Spacer()
                        Text(movie.title)
                            .font(
                                .system(size: 20)
                                .weight(.bold)
                            )
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
                            Text(movie.ratingText).foregroundColor(.accentColor)
                                .font(.system(size: 18) .weight(.medium))
                        }
                        
                        Spacer()
                        
                        HStack(alignment: .center) {
                            Button(action: {
                                
                            }) {
                                Text("add a score")
                                    .padding(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.accentColor, lineWidth: 2)
                                    )
                            }
                        }
                    }
                }
                
                Spacer()
                    .frame(height: 30)
                
                HStack {
                    Spacer()
                        .frame(width: 30)
                    Button(action: {
                        // Action code here
                    }) {
                        VStack {
                            if selection == 0 {
                                Image("Watched")
                                Text("watched")
                            } else {
                                Image("watch")
                                Text("watch")
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // Action code here
                    }) {
                        VStack {
                            if selection == 1 {
                                Image("Saved")
                                Text("Saved")
                            } else {
                                Image("Save")
                                Text("Save")
                            }
                        }
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
                
                Spacer()
                    .frame(height: 30)
                
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
        
//        List {
//            MovieDetailImage(imageLoader: imageLoader, imageURL: self.movie.backdropURL)
//                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//
//            HStack {
//                Text(movie.genreText)
//                Text("·")
//                Text(movie.yearText)
//                Text(movie.durationText)
//            }
//
//            Text(movie.overview)
//            HStack {
//                Image("Heart")
//                    .resizable()
//                    .frame(width: 25, height: 25)
//                    .padding(.trailing, -5)
//                Text(movie.ratingText).foregroundColor(.accentColor)
//            }
////            .onTapGesture(count: 1) {
////                Picker(selection: $selectedTheme) {
////                    ForEach(themes, id: \.self) {
////                        Text($0)
////                    }
////                }
////                .pickerStyle(.wheel)
////            }
//
//            Divider()
//
//            HStack(alignment: .top, spacing: 4) {
//                if movie.cast != nil && movie.cast!.count > 0 {
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text("Starring").font(.headline)
//                        ForEach(self.movie.cast!.prefix(9)) { cast in
//                            Text(cast.name)
//                        }
//                    }
//                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
//                    Spacer()
//
//                }
//
//                if movie.crew != nil && movie.crew!.count > 0 {
//                    VStack(alignment: .leading, spacing: 4) {
//                        if movie.directors != nil && movie.directors!.count > 0 {
//                            Text("Director(s)").font(.headline)
//                            ForEach(self.movie.directors!.prefix(2)) { crew in
//                                Text(crew.name)
//                            }
//                        }
//
//                        if movie.producers != nil && movie.producers!.count > 0 {
//                            Text("Producer(s)").font(.headline)
//                                .padding(.top)
//                            ForEach(self.movie.producers!.prefix(2)) { crew in
//                                Text(crew.name)
//                            }
//                        }
//
//                        if movie.screenWriters != nil && movie.screenWriters!.count > 0 {
//                            Text("Screenwriter(s)").font(.headline)
//                                .padding(.top)
//                            ForEach(self.movie.screenWriters!.prefix(2)) { crew in
//                                Text(crew.name)
//                            }
//                        }
//                    }
//                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
//                }
//            }
//
//            Divider()
//
//            if let trailers = movie.youtubeTrailers, !trailers.isEmpty {
//                let trailer = trailers[0] // Get the first trailer
//
//                Button(action: {
//                    self.selectedTrailer = trailer
//                }) {
//                    HStack {
//                        Text(trailer.name)
//                        Spacer()
//                        Image(systemName: "play.circle.fill")
//                            .foregroundColor(Color(UIColor.systemBlue))
//                    }
//                }
//            }
//        }
//
//        .sheet(item: self.$selectedTrailer) { trailer in
//            SafariView(url: trailer.youtubeURL!)
//        }
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
