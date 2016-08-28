//
//  ImageProvider.swift
//  Git Miles
//
//  Created by Shubham Agrawal on 27/08/16.
//  Copyright © 2016 Shubham Agrawal. All rights reserved.
//

import Foundation
import UIKit

class ImageProvider {
    
    static let favoriteImage = UIImage(named: "star_selected")!
    static let notFavoriteImage = UIImage(named: "star_unselected")!
    static let userPlaceHolderImage = UIImage(named: "avatar_placeholder")
    
    static func getFavoriteImage(isFavorite: NSNumber?) -> UIImage {
        if isFavorite == nil || isFavorite == 0 {
            return notFavoriteImage
        } else {
            return favoriteImage
        }
    }
    
}