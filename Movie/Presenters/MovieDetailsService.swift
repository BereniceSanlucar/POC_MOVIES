//
//  MovieDetailsService.swift
//  Movie
//
//  Created by Berenice Mendoza on 2/6/18.
//  Copyright © 2018 Berenice Mendoza. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import RealmSwift
import UserNotifications

class MovieDetailsService: NSObject {
    
    //MARK: - Get an specific movie image from API method
    
    func getImageFromAPI(withPath: String, completion: @escaping (UIImage) -> Void) {
        
        var image = UIImage()
        
        let task = Alamofire.request("https://image.tmdb.org/t/p/original\(withPath)").responseImage { response in
            switch response.result {
                
            case .success:
                guard let poster = response.result.value else {
                    print("Malformed data received")
                    return
                }
                
                image = poster
                
            case .failure(let error):
                print("Error in request \(error.localizedDescription)")
            }
            
            DispatchQueue.main.async(execute: {
                completion(image)
            })
        }
        task.resume()
    }
    
    //MARK: - Get the video for an specific from API method
    
    func getVideoKeyFromAPI(withURL: String, completion: @escaping ([String]) -> Void) {
        
        var keys: [String] = []
        
        let task = Alamofire.request(withURL).responseJSON{(response) in
            
            switch response.result {
                
            case .success:
                
                guard let data = response.result.value as? [String: Any], let results = data["results"] as? [[String: Any]] else {
                    print("Malformed data received")
                    return
                }
                
                for result in results {
                    if result["site"] as? String == "YouTube" {
                        if  let newKey = (result["key"] as? String) {
                            keys.append(newKey)
                        }
                    }
                }
                
            case .failure(let error):
                print("Error in request \(error.localizedDescription)")
            }
            
            DispatchQueue.main.async(execute: {
                completion(keys)
            })
        }
        task.resume()
    }
    
    //MARK: - Save a selected movie method
    
    func saveMovieToDB(movie: MoviesData, completion: @escaping (Bool) -> Void) {
        
        var wasAdded: Bool = false
        
        do {
            
            let realm = try Realm()
            var movies = realm.objects(Movie.self).filter("id == %@", movie.id)
            
            if !(movies.count > 0) {
                
                let newMovie = Movie()
                newMovie.id = movie.id
                newMovie.title = movie.title
                newMovie.poster = movie.poster
                newMovie.voteAverage = movie.voteAverage
                newMovie.overView = movie.overView
                
                try realm.write {
                    realm.add(newMovie)
                }
                
                movies = realm.objects(Movie.self).filter("id == %@", newMovie.id)
                
                if movies.count > 0 {
                    wasAdded = true
                }
                
            }
            
            DispatchQueue.main.async(execute: {
                completion(wasAdded)
            })
            
        } catch let error as NSError {
            print(error)
        }
    }
    
    //MARK: - Create Notification for a movie method
    
    func scheduleLocalNotification(movie: MoviesData) {
        // Create Notification Content
        let notificationContent = UNMutableNotificationContent()
        
        // Configure Notification Content
        notificationContent.title = "Moviex"
        notificationContent.subtitle = "Release Date"
        notificationContent.body = "Today is release date for \(movie.title) movie."
        
        var releaseDateArray = (movie.releaseDate).components(separatedBy: "-")
        
        for i in 0..<releaseDateArray.count {
            print(releaseDateArray[i])
        }
        
        var dateComponents = DateComponents()
        dateComponents.year = Int(releaseDateArray[0])
        dateComponents.month = Int(releaseDateArray[1])
        dateComponents.day = Int(releaseDateArray[2])
        dateComponents.hour = 17
        dateComponents.minute = 59
        
        // Add Trigger
        let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create Notification Request
        let notificationRequest = UNNotificationRequest(identifier: "\(movie.title)-\(movie.id)", content: notificationContent, trigger: notificationTrigger)
        
        // Add Request to User Notification Center
        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
            if let error = error {
                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
            }
        }
    }
    
    //MARK: - Delete a selected movie method
    
    func deleteMovieFromDB(movieID: Int, completion: @escaping (Bool) -> Void) {
        
        var wasDeleted: Bool = false
        
        do {
            
            let realm = try Realm()
            var movie = realm.objects(Movie.self).filter("id == %@", movieID).first
            
            if let currentMovie = movie {
                
                try realm.write {
                    realm.delete(currentMovie)
                }
                
                var movies = realm.objects(Movie.self).filter("id == %@", movieID)
                
                if !(movies.count > 0) {
                    wasDeleted = true
                }
            }
            
            DispatchQueue.main.async(execute: {
                completion(wasDeleted)
            })
            
        } catch let error as NSError {
            print(error)
        }
    }
}
