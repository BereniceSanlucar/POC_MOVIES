//
//  MyListService.swift
//  Movie
//
//  Created by Berenice Mendoza on 2/7/18.
//  Copyright © 2018 Berenice Mendoza. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import RealmSwift

class MyListService {
    
    func getMoviesFromDB() -> [Movie]{
        
        var list: [Movie] = []
        var newMovie = Movie()
     
        do {
     
            let realm = try Realm()
            let movies = realm.objects(Movie.self)
     
            for movie in movies {
                newMovie.id = movie.id
                newMovie.title = movie.title
                newMovie.poster = movie.poster
                newMovie.voteAverage = movie.voteAverage
                newMovie.overView = movie.overView
                list.append(newMovie)
                newMovie = Movie()
            }
            
        } catch let error as NSError {
            print(error)
        }
        return list
    }
}
    


