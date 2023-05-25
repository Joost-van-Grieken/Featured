//
//  GenreId's.swift
//  Featured
//
//  Created by Joost van Grieken on 04/05/2023.
//

import Foundation

class MovieGenres: ObservableObject {
    
    let MovieGenres: [(name: String, id: Int)] = [
            ("Action", 28),
            ("Adventure", 12),
            ("Animation", 16),
            ("Comedy", 35),
            ("Crime", 80),
            ("Documentary", 99),
            ("Drama", 18),
            ("Family", 10751),
            ("Fantasy", 14),
            ("History", 36),
            ("Horror", 27),
            ("Music", 10402),
            ("Mystery", 9648),
            ("Romance", 10749),
            ("Science Fiction", 878),
            ("TV Movie", 10770),
            ("Thriller", 53),
            ("War", 10752),
            ("Western", 37)
        ]
}

class TVShowsGenres: ObservableObject {
    
    let TVGenres: [(name: String, id: Int)] = [
        ("Action & Adventure", 10759),
        ("Animation", 16),
        ("Comedy", 35),
        ("Crime", 80),
        ("Documentary", 99),
        ("Drama", 18),
        ("Family", 10751),
        ("Kids", 10762),
        ("Mystery", 9648),
        ("News", 10763),
        ("Reality", 10764),
        ("Sci-Fi & Fantasy", 10765),
        ("Soap", 10766),
        ("Talk", 10767),
        ("War & Politics", 10768),
        ("Western", 37)]
}
