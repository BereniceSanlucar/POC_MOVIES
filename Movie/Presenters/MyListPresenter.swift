//
//  MyListPresenter.swift
//  Movie
//
//  Created by Berenice Mendoza on 2/7/18.
//  Copyright © 2018 Berenice Mendoza. All rights reserved.
//

import Foundation

struct MyListData {
    let image: UIImage
    let movie: Movie
}

protocol MyListView {
    func startLoading()
    func finishLoading()
    func setMyList(movie: Movie, image: UIImage)
}

class MyListPresenter: NSObject {
    private let myListService: MyListService
    private let movieDetailsService: MovieDetailsService?
    private var myListView: MyListView?
    
    init(myListService: MyListService, movieDetailsService: MovieDetailsService) {
        self.myListService = myListService
        self.movieDetailsService = movieDetailsService
    }
    
    func attachView(view: MyListView) {
        myListView = view
    }
    
    func detachView() {
        myListView = nil
    }
    
    func prepareMovies() {
        var movies = myListService.getMoviesFromDB()
        
        for i in 0..<movies.count {
            prepareImage(movie: movies[i])
        }
    }
    
    func prepareImage(movie: Movie) {
        self.myListView?.startLoading()
        movieDetailsService?.getImageFromAPI(withPath: movie.poster, completion: { poster  in
            self.myListView?.finishLoading()
            self.myListView?.setMyList(movie: movie, image: poster)
        })
    }
}
