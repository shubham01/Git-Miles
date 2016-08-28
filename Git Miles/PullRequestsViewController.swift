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
    var pullRequests: [PullRequest] = []
    
    var activityIndicator = UIActivityIndicatorView()
    
    var selectedPRIndex: Int!
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
        
        activityIndicator.center = self.view.center
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        tableView.registerNib(UINib(nibName: "PRMilestoneCellContent", bundle: nil), forCellReuseIdentifier: "prMilestoneCellContent")
        tableView.registerNib(UINib(nibName: "PullRequestCell", bundle: nil), forCellReuseIdentifier: "pullRequestCell")
        tableView.registerNib(UINib(nibName: "PRPullRequestHeaderCell", bundle: nil), forCellReuseIdentifier: "prPRHeaderCell")
        
        GitHubAPIManager.sharedInstance.getPullRequestsForMilestone(repo.url!, number: milestone.number!, state: prStateToShow) {
            response in
            
            self.activityIndicator.hidden = true
            
            let json = JSON(response.result.value!)
            CoreDataHelper.storePullRequest(json, milestone: self.milestone)
            
            self.activityIndicator.removeFromSuperview()
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
            target.pullRequest = pullRequests[selectedPRIndex]
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
            return milestoneDetailsCollapsed ? 44 : 150
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
            selectedPRIndex = indexPath.row - 2 //PRs start from third row
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
//            cell.titleLabel.text = pr.title
//            cell.usernameLabel.text = pr.userLogin
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
    
    // MARK: Member methods
    
    func setMilestoneCellContent(cell: PRMilestoneCellContent) {
        
        cell.titleLabel.text = milestone.title!
        cell.descriptionLabel.text = milestone.descriptionBody!
        
        //To make NSDate objects from ISO8601 timestamp
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        
        //To convert NSDate object to string
        let dateFormatterOut = NSDateFormatter()
        dateFormatterOut.locale = NSLocale(localeIdentifier: "en_IN")
        
        dateFormatterOut.dateFormat = "HH:mm, MMM d yyyy"
        let updatedDate = dateFormatter.dateFromString(milestone.updatedAt!)
        cell.lastUpdatedLabel.text = "Updated at \(dateFormatterOut.stringFromDate(updatedDate!))"
        
        if (milestone.dueOn == "") {
            cell.dueOnLabel.text = "No due date"
        } else {
            dateFormatterOut.dateFormat = "MMM d yyyy"
            let dueDate = dateFormatter.dateFromString(milestone.dueOn!)
            cell.dueOnLabel.text = "Due on \(dateFormatterOut.stringFromDate(dueDate!))"
        }
        
        let completed = (Double(milestone.closedIssues!) * 100.0) /
                        (Double(milestone.closedIssues!) + Double(milestone.openIssues!))
        cell.completedLabel.text = "\(round(completed))% completed"
        cell.openClosedLabel.text = "\(milestone.openIssues!) open | \(milestone.closedIssues!) closed"
    }

}
