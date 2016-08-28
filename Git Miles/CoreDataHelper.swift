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
        let entityDescription = NSEntityDescription.entityForName("Repository", inManagedObjectContext: moc)
        
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
                    let newRepo = Repository(entity: entityDescription!,
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
    
    static func storeMilestones(milestones: JSON, repo: Repository) {
        let moc = DataController.sharedInstance.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Milestone")
        let entityDescription = NSEntityDescription.entityForName("Milestone", inManagedObjectContext: moc)
        
        for (_, milestone) in milestones {
            let predicate = NSPredicate(format: "%K == %i", "id", milestone["id"].intValue)
            fetchRequest.predicate = predicate
            
            do {
                let fetchedResults = try moc.executeFetchRequest(fetchRequest) as! [Milestone]
                
                if fetchedResults.count > 0 {
                    
                    let existingMilestone = fetchedResults[0]
                    
                    existingMilestone.setValue(milestone["id"].intValue, forKey: "id")
                    existingMilestone.setValue(milestone["number"].intValue, forKey: "number")
                    existingMilestone.setValue(milestone["title"].stringValue, forKey: "title")
                    existingMilestone.setValue(milestone["description"].stringValue, forKey: "descriptionBody")
                    existingMilestone.setValue(milestone["state"].stringValue, forKey: "state")
                    existingMilestone.setValue(milestone["created_at"].stringValue, forKey: "createdAt")
                    existingMilestone.setValue(milestone["updated_at"].stringValue, forKey: "updatedAt")
                    existingMilestone.setValue(milestone["closed_at"].stringValue, forKey: "closedAt")
                    existingMilestone.setValue(milestone["due_on"].stringValue, forKey: "dueOn")
                    existingMilestone.setValue(milestone["open_issues"].intValue, forKey: "openIssues")
                    existingMilestone.setValue(milestone["closed_issues"].intValue, forKey: "closedIssues")
                    
                    
                } else {
                    let newMilestone = Milestone(entity: entityDescription!,
                                             insertIntoManagedObjectContext: moc)
                    
                    newMilestone.id = milestone["id"].intValue
                    newMilestone.number = milestone["number"].intValue
                    newMilestone.title = milestone["title"].stringValue
                    newMilestone.descriptionBody = milestone["description"].stringValue
                    newMilestone.state = milestone["state"].stringValue
                    newMilestone.createdAt = milestone["created_at"].stringValue
                    newMilestone.updatedAt = milestone["updated_at"].stringValue
                    newMilestone.closedAt = milestone["closed_at"].stringValue
                    newMilestone.dueOn = milestone["due_on"].stringValue
                    newMilestone.openIssues = milestone["open_issues"].intValue
                    newMilestone.closedIssues = milestone["closed_issues"].intValue
                    
                    repo.mutableSetValueForKey("milestones").addObject(newMilestone)
                    
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
    
    static func storePullRequest(pullRequests: JSON, milestone: Milestone) {
        let moc = DataController.sharedInstance.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "PullRequest")
        let entityDescription = NSEntityDescription.entityForName("PullRequest", inManagedObjectContext: moc)
        let labelEntityDescription = NSEntityDescription.entityForName("Label",
                                                    inManagedObjectContext: moc)
        let assigneeEntityDescription = NSEntityDescription.entityForName("Assignee",
                                                    inManagedObjectContext: moc)
        
        for (_, issue) in pullRequests {
            
            if !PullRequest.isPullRequest(issue) {
                continue
            }
            
            let predicate = NSPredicate(format: "id == %i", issue["id"].intValue)
            fetchRequest.predicate = predicate
            
            do {
                let fetchedResults = try moc.executeFetchRequest(fetchRequest) as! [PullRequest]
                
                if fetchedResults.count > 0 {
                    
                    let pullRequest = fetchedResults[0]
                    
                    pullRequest.setValue(issue["id"].intValue, forKey: "id")
                    pullRequest.setValue(issue["number"].intValue, forKey: "number")
                    pullRequest.setValue(issue["title"].stringValue, forKey: "title")
                    pullRequest.setValue(issue["body"].stringValue, forKey: "body")
                    pullRequest.setValue(issue["state"].stringValue, forKey: "state")
                    pullRequest.setValue(issue["created_at"].stringValue, forKey: "createdAt")
                    pullRequest.setValue(issue["updated_at"].stringValue, forKey: "updatedAt")
                    pullRequest.setValue(issue["user"]["login"].stringValue, forKey: "userLogin")
            
                    pullRequest.setValue(issue["milestone"]["id"].intValue, forKey: "milestoneId")
                    
                    for (_,label) in issue["labels"] {
                        let newLabel = Label(entity: labelEntityDescription!, insertIntoManagedObjectContext: moc)
                        newLabel.name = label["name"].stringValue
                        newLabel.color = label["color"].stringValue
                        pullRequest.mutableSetValueForKey("labels").addObject(newLabel)
                    }
                    
                    for (_,assignee) in issue["assignees"] {
                        let newAssignee = Assignee(entity: assigneeEntityDescription!, insertIntoManagedObjectContext: moc)
                        newAssignee.login = assignee["login"].stringValue
                        newAssignee.avatar = assignee["avatar_url"].stringValue
                        pullRequest.mutableSetValueForKey("assignees").addObject(newAssignee)
                    }
                    
//                    milestone.mutableSetValueForKey("pullRequests").addObject(pullRequest)
                    
                    
                } else {
                    let newPR = PullRequest(entity: entityDescription!,
                                                    insertIntoManagedObjectContext: moc)
                    
                    newPR.id = issue["id"].intValue
                    newPR.number = issue["number"].intValue
                    newPR.title = issue["title"].stringValue
                    newPR.body = issue["body"].stringValue
                    newPR.state = issue["state"].stringValue
                    newPR.createdAt = issue["created_at"].stringValue
                    newPR.updatedAt = issue["updated_at"].stringValue
                    newPR.userLogin = issue["user"]["login"].stringValue
                    newPR.milestoneId = issue["milestone"]["id"].intValue
                    
                    for (_,label) in issue["labels"] {
                        let newLabel = Label(entity: labelEntityDescription!, insertIntoManagedObjectContext: moc)
                        newLabel.name = label["name"].stringValue
                        newLabel.color = label["color"].stringValue
                        newPR.mutableSetValueForKey("labels").addObject(newLabel)
                    }
                    
                    for (_,assignee) in issue["assignees"] {
                        let newAssignee = Assignee(entity: assigneeEntityDescription!, insertIntoManagedObjectContext: moc)
                        newAssignee.login = assignee["login"].stringValue
                        newAssignee.avatar = assignee["avatar_url"].stringValue
                        newPR.mutableSetValueForKey("assignees").addObject(newAssignee)
                    }
                    
                    milestone.mutableSetValueForKey("pullRequests").addObject(newPR)
                    
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
    
    static func setFavorite(repo: Repository, value: NSNumber) {
        let moc = DataController.sharedInstance.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Repository")
        fetchRequest.predicate = NSPredicate(format: "id == %@", repo.id!)
        do {
            let results = try moc.executeFetchRequest(fetchRequest) as! [Repository]
            print(results.count)
            if (results.count > 0) {
                results[0].setValue(value, forKey: "isFavorite")
            }
        } catch {
            fatalError("Could not fetch repo: \(error)")
        }
        do {
            try moc.save()
        } catch {
            fatalError("Could not save context: \(error)")
        }
    }
    
}
