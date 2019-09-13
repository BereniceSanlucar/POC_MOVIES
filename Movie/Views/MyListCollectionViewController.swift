//
//  MyListCollectionViewController.swift
//  Movie
//
//  Created by Berenice Mendoza on 2/7/18.
//  Copyright © 2018 Berenice Mendoza. All rights reserved.
//

import UIKit

private let reuseIdentifier = "movieCell"
private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
private let itemsPerRow: CGFloat = 3

class MyListCollectionViewController: UICollectionViewController {
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    open override var shouldAutorotate: Bool {
        return false
    }
    
    let refreshControl = UIRefreshControl()
    
    let myListPresenter = MyListPresenter(myListService: MyListService(), movieDetailsService: MovieDetailsService())
    var myList = [MyListData]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.isToolbarHidden = true
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView?.allowsMultipleSelection = false
        
        self.navigationController?.isToolbarHidden = true
        
        self.myList.removeAll()
        self.myListPresenter.attachView(view: self)
        self.myListPresenter.prepareMovies()
        self.collectionView?.reloadData()
        
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myList.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MovieImageCollectionViewCell
        
        cell.movieImage.image = myList[indexPath.row].image
        cell.movieImage.contentMode = .center
        cell.movieImage.contentMode = .scaleAspectFill
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToMovieDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! MovieDetailsViewController
        
        if let indexPath = collectionView?.indexPathsForSelectedItems?.first {
            var oldMovie = myList[indexPath.row].movie
            var newMovie = MoviesData(section: oldMovie.section, id: oldMovie.id, title: oldMovie.title, poster: oldMovie.poster, voteAverage: oldMovie.voteAverage, overView: oldMovie.overView, releaseDate: oldMovie.releaseDate)
            
            destinationVC.selectedMovie = newMovie
            destinationVC.image = myList[indexPath.row].image
            destinationVC.isToolBarHidden = false
            destinationVC.isImageSet = true
            destinationVC.isAddButtonEnable = false
        }
    }
}

//MARK: - CollectionViewDelegateFlowLayout methods

extension MyListCollectionViewController: UICollectionViewDelegateFlowLayout {
   
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem + 45)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

//MARK: - MoviesView methods

extension MyListCollectionViewController: MyListView {
    
    func startLoading() {
        refreshControl.beginRefreshing()
    }
    
    func finishLoading() {
        refreshControl.endRefreshing()
    }
    
    func setMyList(movie: Movie, image: UIImage) {
        myList.append(MyListData(image: image, movie: movie))
        collectionView?.reloadData()
    }
}

