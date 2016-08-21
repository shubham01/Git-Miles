//
//  Repository.swift
//  Git Miles
//
//  Created by Shubham Agrawal on 19/08/16.
//  Copyright © 2016 Shubham Agrawal. All rights reserved.
//

import Foundation

class Repository {
    var id : Int = 0
    var name : String = ""
    var url: String = ""
    
    init(id: Int, name: String, url: String) {
        self.id = id
        self.name = name
        self.url = url
    }
    
}