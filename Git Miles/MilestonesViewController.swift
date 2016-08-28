//
//  MilestonesViewController.swift
//  Git Miles
//
//  Created by Shubham Agrawal on 21/08/16.
//  Copyright © 2016 Shubham Agrawal. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreData

class MilestonesViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var repo: Repository!
    let activityIndicator = UIActivityIndicatorView()
    
    var selectedMilestone: Milestone!
    
    var fetchedResultsController: NSFetchedResultsController!
    
    // MARK: Outlets
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureFetchedResultsController()
        
        let milestonesUrl = repo.url! + "/milestones"
        
        GitHubAPIManager.sharedInstance.getMilestones(milestonesUrl) {
            response in
            
            self.activityIndicator.hidden = true
            let statusCode = response.response?.statusCode
            
            if (statusCode >= 200 && statusCode < 300) {
                let milestones = JSON(response.result.value!)
                CoreDataHelper.storeMilestones(milestones, repo: self.repo)
            }
            
            self.activityIndicator.removeFromSuperview()
            self.tableView.reloadData()
        }
    }
    
    func showActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "milestoneToPullRequests") {
            let target = segue.destinationViewController as! PullRequestsViewController
            target.milestone = selectedMilestone
            target.repo = repo
        }
    }
    
    // MARK: TableView
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard let sectionCount = fetchedResultsController.sections?.count else {
            return 0
        }
        return sectionCount
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionData = fetchedResultsController.sections?[section] else {
            return 0
        }
        return sectionData.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("milestoneCell", forIndexPath: indexPath)
            let milestone = fetchedResultsController.objectAtIndexPath(indexPath) as! Milestone
            cell.textLabel?.text = milestone.title!
            cell.detailTextLabel?.text = milestone.descriptionBody!
            
            return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        selectedMilestone = fetchedResultsController.objectAtIndexPath(indexPath) as! Milestone
        performSegueWithIdentifier("milestoneToPullRequests", sender: self)
    }
    
    // MARK: FetchedResultsController
    
    func configureFetchedResultsController() {
        let fetchRequest = NSFetchRequest(entityName: "Milestone")
        let fetchSort = NSSortDescriptor(key: "dueOn", ascending: false)
        fetchRequest.sortDescriptors = [fetchSort]
        
        let predicate = NSPredicate(format: "repo == %@", repo)
        fetchRequest.predicate = predicate
        
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: DataController.sharedInstance.managedObjectContext,
                                                              sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Controller could not perform fetch: \(error)")
        }
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        // 1
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
            
        default: break
            
        }
        
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        // 2
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
            
        }
    }
    
    
}
