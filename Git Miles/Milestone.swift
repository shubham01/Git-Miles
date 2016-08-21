//
//  Milestone.swift
//  Git Miles
//
//  Created by Shubham Agrawal on 21/08/16.
//  Copyright © 2016 Shubham Agrawal. All rights reserved.
//

import SwiftyJSON

class Milestone {
    
    var id: Int
    var number: Int
    var title: String
    var description: String
    var state: String
    var createdAt: String
    var updatedAt: String
    var closedAt: String
    var dueOn: String
    
    init(json: JSON) {
        id = json["id"].intValue
        number = json["number"].intValue
        title = json["title"].stringValue
        description = json["description"].stringValue
        state = json["state"].stringValue
        createdAt = json["created_at"].stringValue
        updatedAt = json["updated_at"].stringValue
        closedAt = json["closed_at"].stringValue
        dueOn = json["due_on"].stringValue
    }
    
}
