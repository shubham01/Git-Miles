//
//  MilestonesViewController.swift
//  Git Miles
//
//  Created by Shubham Agrawal on 21/08/16.
//  Copyright © 2016 Shubham Agrawal. All rights reserved.
//

import UIKit
import SwiftyJSON

class MilestonesViewController: UITableViewController {
    
    var milestones:[Milestone] = []
    var repo: Repository!
    let activityIndicator = UIActivityIndicatorView()
    
    var clickedItem: Int!
    
    // MARK: Outlets
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.center = self.view.center
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        let milestonesUrl = repo.url! + "/milestones"
        
        GitHubAPIManager.sharedInstance.getMilestones(milestonesUrl) {
            response in
            
            self.activityIndicator.hidden = true
            let statusCode = response.response?.statusCode
            
            if (statusCode >= 200 && statusCode < 300) {
                let json = JSON(response.result.value!)
                for (_, milestone) in json {
                    self.milestones.append(Milestone(json: milestone))
                }
            }
            self.activityIndicator.removeFromSuperview()
            self.tableView.reloadData()
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "milestoneToPullRequests") {
            let target = segue.destinationViewController as! PullRequestsViewController
            target.milestone = milestones[clickedItem]
            target.repo = repo
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return milestones.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("milestoneCell", forIndexPath: indexPath)
            let milestone = milestones[indexPath.row] as Milestone
            cell.textLabel?.text = milestone.title
            cell.detailTextLabel?.text = milestone.description
            
            return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        clickedItem = indexPath.row
        performSegueWithIdentifier("milestoneToPullRequests", sender: self)
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        print("Detail button clicked: \(indexPath.row)")
        
        let milestone = milestones[indexPath.row]
        
        let message = milestone.description + "Created at: \(milestone.createdAt)"
        
        let popup = UIAlertController(title: milestone.title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        popup.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
        
        presentViewController(popup, animated: true, completion: nil)
    }
    
    func prepareMilestoneDetails(milestone: Milestone) -> String {
        return ""
    }
    
    
}
