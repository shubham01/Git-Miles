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
    
    var milestone: Milestone!
    var repo: Repository!
    var pullRequests: [PullRequest] = []
    var activityIndicator = UIActivityIndicatorView()
    
    var milestoneDetailsCollapsed: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.center = self.view.center
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        tableView.registerNib(UINib(nibName: "PRMilestoneCellContent", bundle: nil), forCellReuseIdentifier: "prMilestoneCellContent")
        
        tableView.registerNib(UINib(nibName: "PRMilestoneCellHeader", bundle: nil), forCellReuseIdentifier: "prMilestoneCellHeader")
        
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
            self.tableView.reloadData()
            print(self.pullRequests.count)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
        if (indexPath.section == 0 && indexPath.row == 1) {
            return milestoneDetailsCollapsed ? 0 : 100
        }
        return UITableViewAutomaticDimension
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 1) {
            return "Pull Requests"
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 2
        }
        return pullRequests.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if(indexPath.section == 0) {
            milestoneDetailsCollapsed = !milestoneDetailsCollapsed
            tableView.beginUpdates()
            tableView.endUpdates()
        }
//        print(pullRequests[indexPath.row].title)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                let cell = tableView.dequeueReusableCellWithIdentifier("prMilestoneCellHeader", forIndexPath: indexPath) as! PRMilestoneCellHeader
                cell.milestoneTitleLabel.text = milestone.title
                cell.accessoryType = .DisclosureIndicator
                return cell
            }
            if (indexPath.row == 1) {
                let cell = tableView.dequeueReusableCellWithIdentifier("prMilestoneCellContent",
                                                                       forIndexPath: indexPath) as! PRMilestoneCellContent
                
                setMilestoneCellContent(cell)
                return cell
            }
        }
        if (indexPath.section == 1) {
            let cell = tableView.dequeueReusableCellWithIdentifier("pullRequestCell", forIndexPath: indexPath) as! PullRequestCell
            let pr = pullRequests[indexPath.row]
            cell.titleLabel.text = pr.title
            cell.usernameLabel.text = pr.userLogin
            return cell
        }
        return UITableViewCell()
    }
    
    func setMilestoneCellContent(cell: PRMilestoneCellContent) {
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
