//
//  MoviePosterCarouselView.swift
//  Featured2
//
//  Created by Joost van Grieken on 06/04/2023.
//

import SwiftUI

struct MoviePosterCarouselView: View {
    
    let title: String
    let movies: [Movie]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: 16) {
                    ForEach(self.movies) { movie in
                        NavigationLink(destination: MovieDetailView(movieId: movie.id)) {
                            MoviePosterCard(movie: movie)
                                .frame(width: 204, height: 306)
                        }.buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
        
    }
}

struct MoviePosterCarouselView_Previews: PreviewProvider {
    static var previews: some View {
        MoviePosterCarouselView(title: "Now Playing", movies: Movie.stubbedMovies)
    }
}

