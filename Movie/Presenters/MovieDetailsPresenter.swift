//
//  MovieDetailsPresenter.swift
//  Movie
//
//  Created by Berenice Mendoza on 2/6/18.
//  Copyright © 2018 Berenice Mendoza. All rights reserved.
//

import Foundation

protocol MovieDetailsView {
    func startLoading()
    func finishLoading()
    func setImage(image: UIImage)
    func setKeys(keys: [String])
    func setResultOfInsert(result: Bool)
    func setResultOfDelete(result: Bool)
}

class MovieDetailsPresenter {
    private let movieDetailsService: MovieDetailsService
    private var movieDetailsView: MovieDetailsView?
    
    init(movieDetailsService: MovieDetailsService) {
        self.movieDetailsService = movieDetailsService
    }
    
    func attachView(view: MovieDetailsView) {
        movieDetailsView = view
    }
    
    func detachView() {
        movieDetailsView = nil
    }
    
    func prepareImage(posterPath: String) {
        self.movieDetailsView?.startLoading()
        movieDetailsService.getImageFromAPI(withPath: posterPath, completion: { poster  in
            self.movieDetailsView?.finishLoading()
            self.movieDetailsView?.setImage(image: poster)
        })
    }
    
    func prepareKeys(movieID: Int) {
        var url = "https://api.themoviedb.org/3/movie/\(movieID)/videos?api_key=c88d564d681c7792d3c013a8acd2befd&language=en-US"
        self.movieDetailsView?.startLoading()
        movieDetailsService.getVideoKeyFromAPI(withURL: url, completion: { keys  in
            self.movieDetailsView?.finishLoading()
            let mappedKeys = keys.map{ aux -> String in
                return aux
            }
            self.movieDetailsView?.setKeys(keys: mappedKeys)
        })
    }
    
    func connectWithDBToAdd(selectedMovie: MoviesData, allow: Bool) {
        self.movieDetailsView?.startLoading()
        movieDetailsService.saveMovieToDB(movie: selectedMovie, completion: { added  in
            self.movieDetailsView?.finishLoading()
            if selectedMovie.section == "Upcoming" && allow {
                if added {
                    self.movieDetailsService.scheduleLocalNotification(movie: selectedMovie)
                }
            }
            self.movieDetailsView?.setResultOfInsert(result: added)
        })
    }
    
    func connectWithDBToDelete(movieID: Int) {
        self.movieDetailsView?.startLoading()
        movieDetailsService.deleteMovieFromDB(movieID: movieID, completion: { deleted  in
            self.movieDetailsView?.finishLoading()
            self.movieDetailsView?.setResultOfDelete(result: deleted)
        })
    }
}
