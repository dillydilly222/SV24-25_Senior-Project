//
//  Movie.swift
//  FilmPal
//
//  Created by The Dude on 3/1/24.
//

import Foundation

struct Movie: Decodable {
    // all values stored for API call
    let id: Int
    let title: String
    let poster_path: String?
    let backdrop_path: String?
    let overview: String?
    let adult: Bool?
    let genre_ids: [Int]?
    let release_date: String?
    let original_language: String?
    
}
