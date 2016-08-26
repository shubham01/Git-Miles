//
//  Repository+CoreDataProperties.swift
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

extension Repository {

    @NSManaged var id: NSNumber?
    @NSManaged var name: String?
    @NSManaged var ownerLogin: String?
    @NSManaged var url: String?
    @NSManaged var milestones: NSSet?

}
