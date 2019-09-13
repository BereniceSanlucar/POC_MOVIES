//
//  MoviesViewController.swift
//  Movie
//
//  Created by Berenice Mendoza on 2/2/18.
//  Copyright © 2018 Berenice Mendoza. All rights reserved.
//

import UIKit
import UserNotifications

class MoviesViewController: UIViewController {
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    open override var shouldAutorotate: Bool {
        return false
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let refreshControl = UIRefreshControl()
    let moviesPresenter = MoviesPresenter(moviesService: MoviesService())
    
    var selectedSection: Int?
    
    var sections: [SectionsData] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UNUserNotificationCenter.current().delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        self.moviesPresenter.attachView(view: self)
        self.moviesPresenter.prepareMovies()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.isToolbarHidden = true
        
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK: - ExpandableViewHeader Methods

extension MoviesViewController: ExpandableHeaderViewDelegate {
    
    func toggleSection(header: ExpandableHeaderView, section: Int) {
        sections[section].isExpanded = !sections[section].isExpanded
        
        if selectedSection != nil {
            if selectedSection != section  {
                sections[selectedSection!].isExpanded = false
            }
        }
        
        selectedSection = section
        
        tableView.beginUpdates()
        for item in 0..<sections[section].movies.count {
            tableView.reloadRows(at: [IndexPath(row: item, section: section)], with: .automatic)
        }
        tableView.endUpdates()
    }
}

//MARK: - TableView Methods

extension MoviesViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - TableView Datasource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].movies.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if sections[indexPath.section].isExpanded == true {
            return 44
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header  = ExpandableHeaderView()
        header.customInit(title: sections[section].name, section: section, delegate: self)
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.textLabel?.text = sections[indexPath.section].movies[indexPath.row].title
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToMovieDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! MovieDetailsViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedMovie = sections[indexPath.section].movies[indexPath.row]
            destinationVC.isToolBarHidden = false
            destinationVC.isImageSet = false
            destinationVC.isAddButtonEnable = true
        }
    }
}

//MARK: - Search bar methods

extension MoviesViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        sections.removeAll()
        tableView.reloadData()
        self.moviesPresenter.findMovie(searchWord: searchBar.text!)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            sections.removeAll()
            self.moviesPresenter.prepareMovies()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

//MARK: - MoviesView methods

extension MoviesViewController: MoviesView {
    
    func startLoading() {
        refreshControl.beginRefreshing()
    }
    
    func finishLoading() {
        refreshControl.endRefreshing()
    }
    
    func setMovies(movies: [MoviesData], section: String, isExpanded: Bool) {
        if movies.count > 0 {
            sections.append(SectionsData(name: section, movies: movies, isExpanded: isExpanded))
            
            self.tableView.reloadData()
            
        } else {
            let alert = UIAlertController(title: "Error retrieving movies", message: "Not results found for your search", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Ok", style: .default)
            
            alert.addAction(action)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension MoviesViewController: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }
    
}

