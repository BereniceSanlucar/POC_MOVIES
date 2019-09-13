//
//  PlayViewController.swift
//  Movie
//
//  Created by Berenice Mendoza on 2/9/18.
//  Copyright © 2018 Berenice Mendoza. All rights reserved.
//

import UIKit

class PlayViewController: UIViewController {
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }
    
    open override var shouldAutorotate: Bool {
        return true
    }
    
    var url: URL?
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isToolbarHidden = true
        
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        setVideo()
    }
    
    func setVideo() {
        if let videoURL = url {
            webView.loadRequest(URLRequest(url: url!))
        }
    }
}

