//
//  CoreDataHelper.swift
//  Git Miles
//
//  Created by Shubham Agrawal on 25/08/16.
//  Copyright © 2016 Shubham Agrawal. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData

class CoreDataHelper {
    
    static func storeRepos(repos: JSON) {
        let moc = DataController.sharedInstance.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Repository")
        let existingRepoDescription = NSEntityDescription.entityForName("Repository", inManagedObjectContext: moc)
        
        for (_, repo) in repos {
            let predicate = NSPredicate(format: "%K == %i", "id", repo["id"].intValue)
            fetchRequest.predicate = predicate
            
            do {
                let fetchedResults = try moc.executeFetchRequest(fetchRequest) as! [Repository]
                
                if fetchedResults.count > 0 {
                    
                    let existingRepo = fetchedResults[0]
                    existingRepo.setValue(repo["id"].intValue, forKey: "id")
                    existingRepo.setValue(repo["name"].stringValue, forKey: "name")
                    existingRepo.setValue(repo["url"].stringValue, forKey: "url")
                    existingRepo.setValue(repo["owner"]["login"].stringValue, forKey: "ownerLogin")
                    
                } else {
                    let newRepo = Repository(entity: existingRepoDescription!,
                                             insertIntoManagedObjectContext: moc)
                    newRepo.id = repo["id"].intValue
                    newRepo.name = repo["name"].stringValue
                    newRepo.url = repo["url"].stringValue
                    newRepo.ownerLogin = repo["owner"]["login"].stringValue
                }
                
                do {
                    try moc.save()
                } catch {
                    fatalError("Could not save context: \(error)")
                }
            } catch {
                fatalError("Could not fetch repository: \(error)")
            }
        }
        
        do {
            try moc.save()
        } catch {
            fatalError("Could not save context: \(error)")
        }
    }
    
    static func fetchRepos() -> [Repository]{
        let moc = DataController.sharedInstance.managedObjectContext
        let repoFetch = NSFetchRequest(entityName: "Repository")
        var repos: [Repository]!
        do {
            repos = try moc.executeFetchRequest(repoFetch) as! [Repository]
            
        } catch {
            fatalError("Failed to fetch repo \(error)")
        }
        return repos
    }
    
}
