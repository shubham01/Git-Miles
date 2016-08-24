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

class PullRequestsViewController: UITableViewController {
    
    // MARK: Data variables
    var milestone: Milestone!
    var repo: Repository!
    var pullRequests: [PullRequest] = []
    
    // MARK: Views
    var activityIndicator = UIActivityIndicatorView()
    
    // MARK: Member variables
    var selectedPRIndex: Int!
    var milestoneDetailsCollapsed: Bool = true
    
    // MARK: View Controller
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.center = self.view.center
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        tableView.registerNib(UINib(nibName: "PRMilestoneCellContent", bundle: nil), forCellReuseIdentifier: "prMilestoneCellContent")
        
        tableView.registerNib(UINib(nibName: "PullRequestCell", bundle: nil), forCellReuseIdentifier: "pullRequestCell")

        
        GitHubAPIManager.sharedInstance.getPullRequestsForMilestone(repo.url, number: milestone.number) {
            response in
            
            self.activityIndicator.hidden = true
            
            print(response.response?.statusCode)
            
            let json = JSON(response.result.value!)
            for (_,issue) in json {
                if(PullRequest.isPullRequest(issue)) {
                    self.pullRequests.append(PullRequest(pr: issue))
                }
            }
            
            self.activityIndicator.removeFromSuperview()
            self.tableView.reloadData()
            print(self.pullRequests.count)
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
        return 1 + pullRequests.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
        if (indexPath.row == 0) {
            return milestoneDetailsCollapsed ? 44 : 140
        }
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if(indexPath.row == 0) {
            milestoneDetailsCollapsed = !milestoneDetailsCollapsed
            
            tableView.beginUpdates()
            tableView.endUpdates()
        } else if (indexPath.row >= 1) {
            selectedPRIndex = indexPath.row - 1 //PRs start from second row
            performSegueWithIdentifier("toPullRequestDetails", sender: self)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier("prMilestoneCellContent",
                                                                   forIndexPath: indexPath) as! PRMilestoneCellContent
            
            cell.accessoryType = .DisclosureIndicator
            setMilestoneCellContent(cell)
            return cell
        }
        if (indexPath.row == 1) {
            let cell = tableView.dequeueReusableCellWithIdentifier("pullRequestCell", forIndexPath: indexPath) as! PullRequestCell
            let pr = pullRequests[indexPath.row - 1]
            cell.titleLabel.text = pr.title
            cell.usernameLabel.text = pr.userLogin
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: Member methods
    
    func setMilestoneCellContent(cell: PRMilestoneCellContent) {
        
        cell.titleLabel.text = milestone.title
        cell.descriptionLabel.text = milestone.description
        
        //To make NSDate objects from ISO8601 timestamp
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        
        //To convert NSDate object to string
        let dateFormatterOut = NSDateFormatter()
        dateFormatterOut.locale = NSLocale(localeIdentifier: "en_IN")
        
        dateFormatterOut.dateFormat = "HH:mm, MMM d yyyy"
        let updatedDate = dateFormatter.dateFromString(milestone.updatedAt)
        cell.lastUpdatedLabel.text = "Updated at \(dateFormatterOut.stringFromDate(updatedDate!))"
        
        if (milestone.dueOn == "") {
            cell.dueOnLabel.text = "No due date"
        } else {
            dateFormatterOut.dateFormat = "MMM d yyyy"
            let dueDate = dateFormatter.dateFromString(milestone.dueOn)
            cell.dueOnLabel.text = "Due on \(dateFormatterOut.stringFromDate(dueDate!))"
        }
        
        let completed = Double(milestone.closedIssues * 100) / Double(milestone.closedIssues + milestone.openIssues)
        cell.completedLabel.text = "\(round(completed))% completed"
        cell.openClosedLabel.text = "\(milestone.openIssues) open | \(milestone.closedIssues) closed"
    }

}
