//
//  PullRequest.swift
//  Git Miles
//
//  Created by Shubham Agrawal on 28/08/16.
//  Copyright © 2016 Shubham Agrawal. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class PullRequest: NSManagedObject {
    
    static func isPullRequest(issue: JSON) -> Bool {
        let pullRequest = issue["pull_request"]
        return pullRequest.error == nil
    }
}
