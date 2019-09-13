//
//  Movie.swift
//  Movie
//
//  Created by Berenice Mendoza on 2/2/18.
//  Copyright © 2018 Berenice Mendoza. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class Movie: Object {
    @objc dynamic var section: String = "Not available"
    @objc dynamic var id: Int = 0
    @objc dynamic var title: String = "Not available"
    @objc dynamic var poster: String = "Not available"
    @objc dynamic var voteAverage: Float = 0.0
    @objc dynamic var overView: String = "Not available"
    @objc dynamic var releaseDate: String = "Not available"
}
