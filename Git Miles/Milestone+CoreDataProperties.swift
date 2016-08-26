//
//  Milestone+CoreDataProperties.swift
//  Git Miles
//
//  Created by Shubham Agrawal on 26/08/16.
//  Copyright © 2016 Shubham Agrawal. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Milestone {

    @NSManaged var closedAt: String?
    @NSManaged var closedIssues: NSNumber?
    @NSManaged var createdAt: String?
    @NSManaged var descriptionBody: String?
    @NSManaged var dueOn: String?
    @NSManaged var id: NSNumber?
    @NSManaged var number: NSNumber?
    @NSManaged var openIssues: NSNumber?
    @NSManaged var state: String?
    @NSManaged var title: String?
    @NSManaged var updatedAt: String?
    @NSManaged var repo: Repository?

}
