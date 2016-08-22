//
//  Repository.swift
//  Git Miles
//
//  Created by Shubham Agrawal on 19/08/16.
//  Copyright © 2016 Shubham Agrawal. All rights reserved.
//

import SwiftyJSON

class Repository {
    var id : Int = 0
    var name : String = ""
    var url: String = ""
    var ownerLogin: String = ""
    
    init(repo: JSON) {
        self.id = repo["id"].intValue
        self.name = repo["name"].stringValue
        self.url = repo["url"].stringValue
        self.ownerLogin = repo["owner"]["login"].stringValue
    }
    
}