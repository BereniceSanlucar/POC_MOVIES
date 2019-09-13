//
//  Orientation.swift
//  Movie
//
//  Created by Berenice Mendoza on 2/15/18.
//  Copyright © 2018 Berenice Mendoza. All rights reserved.
//

import Foundation

extension UINavigationController {
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return (visibleViewController?.supportedInterfaceOrientations)!
    }
    
    open override var shouldAutorotate: Bool {
        return (visibleViewController?.shouldAutorotate)!
    }
}

extension UITabBarController {
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let selected = selectedViewController {
            return selected.supportedInterfaceOrientations
        }
        return super.supportedInterfaceOrientations
    }
    
    open override var shouldAutorotate: Bool {
        if let selected = selectedViewController {
            return selected.shouldAutorotate
        }
        return super.shouldAutorotate
    }
}
