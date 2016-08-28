//
//  PullRequest+CoreDataProperties.swift
//  Git Miles
//
//  Created by Shubham Agrawal on 28/08/16.
//  Copyright © 2016 Shubham Agrawal. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PullRequest {

    @NSManaged var number: NSNumber?
    @NSManaged var state: String?
    @NSManaged var title: String?
    @NSManaged var body: String?
    @NSManaged var userLogin: String?
    @NSManaged var createdAt: String?
    @NSManaged var updatedAt: String?
    @NSManaged var id: NSNumber?
    @NSManaged var milestoneId: NSNumber?
    @NSManaged var labels: NSSet?
    @NSManaged var assignees: NSSet?
    @NSManaged var milestone: Milestone?

}
