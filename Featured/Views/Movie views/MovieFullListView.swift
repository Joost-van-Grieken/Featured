//
//  MovieFullListView.swift
//  Featured
//
//  Created by Joost van Grieken on 23/05/2023.
//

import SwiftUI

struct MovieFullListView: View {
    @ObservedObject private var movieListState = MovieListState()
    
    let title: String
    let movies: [Movie]
    
    @State var selection = 0
    
    var items: [GridItem] = [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: items, spacing: 30) {
                    ForEach(self.movies) { movie in
                        VStack {
                            NavigationLink(destination: MovieDetailView(movieId: movie.id)) {
                                MoviePosterCard(movie: movie)
                                    .aspectRatio(contentMode: .fit)
                            }
                            .buttonStyle(.plain)
                            
                            HStack {
                                Spacer()
                                    
                                Button(action: {
                                    // Action code here
                                }) {
                                    VStack {
                                        if selection == 0 {
                                            Image("Watched")
                                                .resizable()
                                                .frame(width: 28, height: 28)
                                        } else {
                                            Image("watch")
                                                .resizable()
                                                .frame(width: 28, height: 28)
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
                                                .resizable()
                                                .frame(width: 25, height: 25)
                                        } else {
                                            Image("Save")
                                                .resizable()
                                                .frame(width: 25, height: 25)
                                        }
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding(.bottom, 6)
                        }
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                .padding(.leading, 8)
                .padding(.trailing, 8)
            }
        }
    }
}

struct MovieFullListView_Previews: PreviewProvider {
    static var previews: some View {
        MovieFullListView(title: "Now Playing", movies: Movie.stubbedMovies)
    }
}
