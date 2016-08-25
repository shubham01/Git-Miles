//
//  PullRequest.swift
//  Git Miles
//
//  Created by Shubham Agrawal on 23/08/16.
//  Copyright © 2016 Shubham Agrawal. All rights reserved.
//

import Foundation
import SwiftyJSON

class PullRequest {
    var number: Int
    var state: String
    var title: String
    var body: String
    var userLogin: String
    var labels: [Label] = []
    var assignees: [Assignee] = []
    var milestoneNumber: Int = 0
    var createdAt: String
    var updatedAt: String
    
    init(pr: JSON) {
        number = pr["number"].intValue
        state = pr["state"].stringValue
        title = pr["title"].stringValue
        body = pr["body"].stringValue
        userLogin = pr["user"]["login"].stringValue
        createdAt = pr["created_at"].stringValue
        updatedAt = pr["updated_at"].stringValue
        
        for (_, label) in pr["labels"] {
            labels.append(Label(name: label["name"].stringValue, color: label["color"].stringValue))
        }
        
        for (_, assignee) in pr["assignees"] {
            assignees.append(Assignee(login: assignee["login"].stringValue, avatar: assignee["avatar_url"].stringValue))
        }
    }
    
    struct Label {
        var name: String
        var color: String
        
        init(name: String, color: String) {
            self.name = name
            self.color = color
        }
    }
    
    struct Assignee {
        var login: String
        var avatar: String
        
        init(login: String, avatar: String) {
            self.login = login
            self.avatar = avatar
        }
    }
    
    static func isPullRequest(issue: JSON) -> Bool {
        let pullRequest = issue["pull_request"]
        return pullRequest.error == nil
    }
    
}