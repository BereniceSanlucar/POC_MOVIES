//
//  MoviesPresenter.swift
//  Movie
//
//  Created by Berenice Mendoza on 2/4/18.
//  Copyright © 2018 Berenice Mendoza. All rights reserved.
//

import Foundation

struct MoviesData {
    let section: String
    let id: Int
    let title: String
    let poster: String
    let voteAverage: Float
    let overView: String
    let releaseDate: String
}

struct SectionsData {
    let name: String
    let movies: [MoviesData]
    var isExpanded: Bool 
}

protocol MoviesView {
    func startLoading()
    func finishLoading()
    func setMovies(movies:[MoviesData], section: String, isExpanded: Bool)
}

class MoviesPresenter: NSObject {
    private let moviesService: MoviesService
    private var moviesView: MoviesView?
    
    init(moviesService: MoviesService) {
        self.moviesService = moviesService
    }
    
    func attachView(view: MoviesView) {
        moviesView = view
    }
    
    func detachView() {
        moviesView = nil
    }
    
    func prepareMovies() {
        var url: String = " "
        var section: String = " "
        let isExpanded: Bool = false
        
        url = "https://api.themoviedb.org/3/movie/popular?&language=en-US&page=1&api_key=c88d564d681c7792d3c013a8acd2befd"
        section = "Popular"
        getData(url: url, section: section, isExpanded: isExpanded)
        
        url = "https://api.themoviedb.org/3/movie/top_rated?&language=en-US&page=1&api_key=c88d564d681c7792d3c013a8acd2befd"
        section = "Top Rated"
        getData(url: url, section: section, isExpanded: isExpanded)
        
        url = "https://api.themoviedb.org/3/movie/upcoming?&language=en-US&page=1&api_key=c88d564d681c7792d3c013a8acd2befd"
        section = "Upcoming"
        getData(url: url, section: section, isExpanded: isExpanded)
    }
    
    func findMovie(searchWord: String) {
        var searchWordArray = (searchWord).components(separatedBy: " ")
        var movieToSearch = searchWordArray[0]
        print(searchWordArray.count)
        for i in 1..<searchWordArray.count {
            movieToSearch += "%20\(searchWordArray[i])"
        }
        
        let url = "https://api.themoviedb.org/3/search/movie?api_key=c88d564d681c7792d3c013a8acd2befd&query=\(movieToSearch)&language=en-US&page=1"
        let section = "Results"
        let isExpanded = true
        getData(url: url, section: section, isExpanded: isExpanded)
    }
    
    func getData(url: String, section: String, isExpanded: Bool){
        self.moviesView?.startLoading()
        moviesService.getMoviesFromAPI(withURL: url, completion: { movies  in
            self.moviesView?.finishLoading()
            let mappedMovies = movies.map{ aux -> MoviesData in
                return MoviesData(section: section, id: aux.id, title: aux.title, poster: aux.poster, voteAverage: aux.voteAverage, overView: aux.overView, releaseDate: aux.releaseDate)
            }
            self.moviesView?.setMovies(movies: mappedMovies, section: section, isExpanded: isExpanded)
        })
    }
}
