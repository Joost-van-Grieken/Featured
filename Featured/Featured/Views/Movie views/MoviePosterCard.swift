//
//  MoviePosterCard.swift
//  Featured2
//
//  Created by Joost van Grieken on 06/04/2023.
//

// MARK: Hantert de posters van de film

import SwiftUI

struct MoviePosterCard: View {
    
    let movie: Movie
    @ObservedObject var imageLoader = ImageLoader()
    
    var body: some View {
        ZStack {
            if let image = self.imageLoader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .cornerRadius(8)
                    .shadow(radius: 4)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .cornerRadius(8)
                    .shadow(radius: 4)
                
                Text(movie.title)
                    .multilineTextAlignment(.center)
            }
        }
        .onAppear {
            self.imageLoader.loadImage(with: self.movie.posterURL)
        }
    }
}

struct MoviePosterCard_Previews: PreviewProvider {
    static var previews: some View {
        MoviePosterCard(movie: Movie.stubbedMovie)
    }
}
