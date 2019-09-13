//
//  MovieDetailsViewController.swift
//  Movie
//
//  Created by Berenice Mendoza on 2/4/18.
//  Copyright © 2018 Berenice Mendoza. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import Social
import UserNotifications

class MovieDetailsViewController: UIViewController {
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    open override var shouldAutorotate: Bool {
        return false
    }

    var selectedMovie: MoviesData?
    var image: UIImage!
    var keys: [String] = []
    var isToolBarHidden: Bool?
    var isImageSet: Bool?
    var isAddButtonEnable: Bool?
    var url: URL?
    
    let refreshControl = UIRefreshControl()
    let movieDetailsPresenter = MovieDetailsPresenter(movieDetailsService: MovieDetailsService())
    
    var addBarButtonItem = UIBarButtonItem()
    var deleteBarButtonItem = UIBarButtonItem()
    var flexibleSpaceBarButtonItem = UIBarButtonItem()
    var actionBarButtonItem = UIBarButtonItem()
    var buttons = [UIBarButtonItem]()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var start1Image: UIImageView!
    @IBOutlet weak var start2Image: UIImageView!
    @IBOutlet weak var start3Image: UIImageView!
    @IBOutlet weak var start4Image: UIImageView!
    @IBOutlet weak var start5Image: UIImageView!
    @IBOutlet weak var start6Image: UIImageView!
    @IBOutlet weak var start7Image: UIImageView!
    @IBOutlet weak var start8Image: UIImageView!
    @IBOutlet weak var start9Image: UIImageView!
    @IBOutlet weak var start10Image: UIImageView!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var overViewLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.movieDetailsPresenter.attachView(view: self)
        self.movieDetailsPresenter.prepareKeys(movieID: (selectedMovie?.id)!)
        initializeBarButtonsItems()
        wayToSetImage()
        setUserInterface()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.isToolbarHidden = isToolBarHidden!
        
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Set UI Methods
    
    func initializeBarButtonsItems() {
        
        addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
        
        flexibleSpaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        deleteBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteButtonPressed))
        
        actionBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(actionButtonPressed))
        
        buttons.append(addBarButtonItem)
        buttons.append(flexibleSpaceBarButtonItem)
        buttons.append(actionBarButtonItem)
        
        if !isAddButtonEnable! {
            buttons.remove(at: 0)
            buttons.insert(deleteBarButtonItem, at: 0)
        }
        self.setToolbarItems(buttons, animated: false)
    }

    func wayToSetImage() {
        if isImageSet! {
            self.imageView.image = image
        } else {
            guard let poster = selectedMovie?.poster else { return }
            self.movieDetailsPresenter.prepareImage(posterPath: poster)
        }
    }
    
    func setUserInterface() {
        adjustImage()
        setStarsRaiting()
        setLabel(myLabel: overViewLabel)
        overViewLabel.text = selectedMovie?.overView
        setLabel(myLabel: titleLabel)
        titleLabel.text = selectedMovie?.title
    }
    
    func setLabel(myLabel: UILabel) {
        myLabel.numberOfLines = 0
        myLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
    }
    
    func setStarsRaiting(){
        guard let average = selectedMovie?.voteAverage else { return }
        var averageInt = Int(average)
        let image: UIImage = UIImage(named:"star_icon_filled")!
        
        for i in 0...averageInt {
            switch i {
            case 0:
                start1Image.image = UIImage(named:"star_icon")!
            case 1:
                start1Image.image = image
            case 2:
                start2Image.image = image
            case 3:
                start3Image.image = image
            case 4:
                start4Image.image = image
            case 5:
                start5Image.image = image
            case 6:
                start6Image.image = image
            case 7:
                start7Image.image = image
            case 8:
                start8Image.image = image
            case 9:
                start9Image.image = image
            case 10:
                start10Image.image = image
            default:
                break
            }
        }
    }
    
    func adjustImage() {
        self.imageView.contentMode = .center
        self.imageView.contentMode = .scaleAspectFit
    }
    
    //MARK: - Add movies to Bookmarks method
    
    @objc func addButtonPressed() {
        activateNotifications()
    }
    
    //MARK: - Delete movies from Bookmarks method
    
    @objc func deleteButtonPressed() {
        self.movieDetailsPresenter.connectWithDBToDelete(movieID: (selectedMovie?.id)!)
    }
    
    @objc func actionButtonPressed() {
        guard let movie = selectedMovie else { return }
        
        displayShareSheet(shareContent: movie)
    }
    
    func displayShareSheet(shareContent: MoviesData) {
        guard let video = url else { return }
        let activityViewController = UIActivityViewController(activityItems: [shareContent.title as NSString, imageView.image ?? UIImage(), video as URL], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func activateNotifications() {
        UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
            switch notificationSettings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization(completionHandler: { (success) in
                    guard success else { return }
                    self.movieDetailsPresenter.connectWithDBToAdd(selectedMovie: self.selectedMovie!, allow: true)
                })
            case .authorized:
                self.movieDetailsPresenter.connectWithDBToAdd(selectedMovie: self.selectedMovie!, allow: true)
                return
            case .denied:
                self.movieDetailsPresenter.connectWithDBToAdd(selectedMovie: self.selectedMovie!, allow: false)
            case .provisional:
              return
          }
        }
    }
    
    func requestAuthorization(completionHandler: @escaping (_ success: Bool) -> ()) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if let error = error {
                print("Request Authorization Failed (\(error), \(error.localizedDescription))")
            }
            completionHandler(success)
        }
    }
    
    //MARK: - Go To Play Movie method
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToPlayMovie", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPlayMovie" {
            let destinationVC = segue.destination as! PlayViewController
            if let videoURL = url {
            destinationVC.url = videoURL
            }
        }
    }
}

//MARK: - MovieDetailsView methods

extension MovieDetailsViewController: MovieDetailsView {
    
    func startLoading() {
        refreshControl.beginRefreshing()
    }
    
    func finishLoading() {
        refreshControl.endRefreshing()
    }
    
    func setImage(image: UIImage) {
        self.imageView.image = image
    }
    
    func setKeys(keys: [String]) {
        self.keys = keys
        
        if self.keys.count <= 0 {
            playButton.isHidden = true
        } else {
            guard let videoCode = keys.first else { return }
            url = URL(string: "https://www.youtube.com/embed/\(videoCode)")
        }
    }
    
    func setResultOfInsert(result: Bool) {
        if result {
            ProgressHUD.showSuccess("Saved")
        } else {
            ProgressHUD.showSuccess("Already Saved")
        }
    }
    
    func setResultOfDelete(result: Bool) {
        if result {
            ProgressHUD.showSuccess("Deleted")
        } else {
            ProgressHUD.showSuccess("Already Deleted")
        }
    }
}
