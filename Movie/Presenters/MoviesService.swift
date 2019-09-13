//
//  MoviesService.swift
//  Movie
//
//  Created by Berenice Mendoza on 2/4/18.
//  Copyright © 2018 Berenice Mendoza. All rights reserved.
//

import Foundation
import Alamofire

class MoviesService: NSObject {
    
    //MARK: - Get Movies From API method
    
    func getMoviesFromAPI(withURL: String, completion: @escaping ([Movie]) -> Void) {
        
        var movies: [Movie] = []
        var newMovie = Movie()
        
        let task = Alamofire.request(withURL).responseJSON{(response) in
            
            switch response.result {
                
            case .success:
                
                guard let data = response.result.value as? [String: Any], let films = data["results"] as? [[String: Any]] else {
                    print("Malformed data received")
                    return
                }
                
                for film in films {
                    newMovie.id = (film["id"] as? Int)!
                    newMovie.title = (film["title"] as? String)!
                    
                    if let poster = (film["poster_path"] as? String) {
                        newMovie.poster = poster
                    }
                    newMovie.overView = (film["overview"] as? String)!
                    newMovie.releaseDate = (film["release_date"] as? String)!
                    movies.append(newMovie)
                    newMovie = Movie()
                }
                
            case .failure(let error):
                print("Error in request \(error.localizedDescription)")
            }
            
            DispatchQueue.main.async(execute: {
                completion(movies)
            })
        }
        task.resume()
    }
}
