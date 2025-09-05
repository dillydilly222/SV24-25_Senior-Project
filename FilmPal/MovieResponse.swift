//
//  MovieResponse.swift
//  FilmPal
//
//  Created by The Dude on 3/1/24.
//

import Foundation

struct MovieResponse: Decodable {
    //Array for API calls
    let results: [Movie]
}
