//
//  PullRequestsViewController.swift
//  Git Miles
//
//  Created by Shubham Agrawal on 23/08/16.
//  Copyright © 2016 Shubham Agrawal. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import CoreData

class PullRequestsViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: Member variables
    var milestone: Milestone!
    var repo: Repository!
    
    var selectedPR: PullRequest!
    var milestoneDetailsCollapsed: Bool = true
    
    let defaults = NSUserDefaults.standardUserDefaults()
    var prStateToShow: String!
    
    var fetchedResultsController: NSFetchedResultsController!
    
    // MARK: View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if defaults.boolForKey("showOpenPRs") {
            prStateToShow = "open"
        } else {
            prStateToShow = "all"
        }
        
        configureFetchedResultsController()
        
        tableView.registerNib(UINib(nibName: "PRMilestoneCellContent", bundle: nil), forCellReuseIdentifier: "prMilestoneCellContent")
        tableView.registerNib(UINib(nibName: "PullRequestCell", bundle: nil), forCellReuseIdentifier: "pullRequestCell")
        tableView.registerNib(UINib(nibName: "PRPullRequestHeaderCell", bundle: nil), forCellReuseIdentifier: "prPRHeaderCell")
        
        GitHubAPIManager.sharedInstance.getPullRequestsForMilestone(repo.url!, number: milestone.number!, state: prStateToShow) {
            response in
            
            let json = JSON(response.result.value!)
            CoreDataHelper.storePullRequest(json, milestone: self.milestone)
            
            self.tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "toPullRequestDetails") {
            let target = segue.destinationViewController as! PullRequestViewController
            target.pullRequest = selectedPR
        }
    }
    
    // MARK: TableView
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let initialCellCount = 2
        guard let sectionData = fetchedResultsController.sections?[section] else {
            return initialCellCount
        }
        return initialCellCount + sectionData.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            return milestoneDetailsCollapsed ? 46 : 178
        }
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if(indexPath.row == 0) {
            milestoneDetailsCollapsed = !milestoneDetailsCollapsed
            
            tableView.beginUpdates()
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! PRMilestoneCellContent
            cell.updateIndicator()
            
            tableView.endUpdates()
            
        } else if (indexPath.row > 1) {
            //PRs start from third row
            let index = NSIndexPath(forRow: indexPath.row - 2, inSection: indexPath.section)
            selectedPR = fetchedResultsController.objectAtIndexPath(index) as! PullRequest
            performSegueWithIdentifier("toPullRequestDetails", sender: self)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier("prMilestoneCellContent",
                                                                   forIndexPath: indexPath) as! PRMilestoneCellContent
            
            cell.setupCell(milestone)
            return cell
        }
        if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCellWithIdentifier("prPRHeaderCell", forIndexPath: indexPath) as! PRPullRequestHeaderCell
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        }
        if (indexPath.row > 1) {
            let cell = tableView.dequeueReusableCellWithIdentifier("pullRequestCell", forIndexPath: indexPath) as! PullRequestCell
            
            let adjustedIndex = NSIndexPath(forRow: indexPath.row - 2, inSection: indexPath.section)
            
            let pr = fetchedResultsController.objectAtIndexPath(adjustedIndex) as! PullRequest
            cell.setupCell(pr)
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: FetchedResultsController
    
    func configureFetchedResultsController() {
        let fetchRequest = NSFetchRequest(entityName: "PullRequest")
        let fetchSort = NSSortDescriptor(key: "createdAt", ascending: false)
        fetchRequest.sortDescriptors = [fetchSort]
        
        if prStateToShow != "all" {
            fetchRequest.predicate = NSPredicate(format: "(state == %@) AND (milestoneId == %@)", prStateToShow, milestone.id!)
        } else {
            fetchRequest.predicate = NSPredicate(format: "milestoneId == %@", milestone.id!)
        }
        
        print("for milestone: \(milestone.number!)")
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                        managedObjectContext: DataController.sharedInstance.managedObjectContext,
                        sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            print(fetchedResultsController.fetchedObjects?.count)
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
