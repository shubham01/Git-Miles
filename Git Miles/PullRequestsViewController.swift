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

class PullRequestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var milestone: Milestone!
    var repo: Repository!
    var pullRequests: [PullRequest] = []
    var activityIndicator = UIActivityIndicatorView()
    
    // MARK: Outlets
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var descriptionView: UILabel!
    @IBOutlet weak var lastUpdatedView: UILabel!
    @IBOutlet weak var completedView: UILabel!
    @IBOutlet weak var stateView: UILabel!
    @IBOutlet weak var dueOnView: UILabel!
    @IBOutlet weak var openAndClosedView: UILabel!
    @IBOutlet weak var pullRequestsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViews()
        
//        pullRequestsTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "pullRequestCell")
        
        activityIndicator.center = self.pullRequestsTable.center
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
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
            self.pullRequestsTable.reloadData()
            print(self.pullRequests.count)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pullRequests.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(pullRequests[indexPath.row].title)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = pullRequestsTable.dequeueReusableCellWithIdentifier("pullRequestCell", forIndexPath: indexPath) as UITableViewCell
        let pr = pullRequests[indexPath.row]
        
        cell.textLabel?.text = pr.title
        cell.detailTextLabel?.text = pr.userLogin
        
        return cell
    }
    
    func setViews() {
        titleView.text = milestone.title
        descriptionView.text = milestone.description
        
        //To make NSDate objects from ISO8601 timestamp
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        
        //To convert NSDate object to string
        let dateFormatterOut = NSDateFormatter()
        dateFormatterOut.locale = NSLocale(localeIdentifier: "en_IN")
        
        dateFormatterOut.dateFormat = "HH:mm, MMM d yyyy"
        let updatedDate = dateFormatter.dateFromString(milestone.updatedAt)
        lastUpdatedView.text = "Updated at \(dateFormatterOut.stringFromDate(updatedDate!))"
        
        
        if (milestone.dueOn == "") {
            dueOnView.text = "No due date"
        } else {
            dateFormatterOut.dateFormat = "MMM d yyyy"
            let dueDate = dateFormatter.dateFromString(milestone.dueOn)
            dueOnView.text = "Due on \(dateFormatterOut.stringFromDate(dueDate!))"
        }
        
        let completed = Double(milestone.closedIssues * 100) / Double(milestone.closedIssues + milestone.openIssues)
        completedView.text = "\(round(completed))% completed"
        
        openAndClosedView.text = "\(milestone.openIssues) open | \(milestone.closedIssues) closed"
        stateView.text = milestone.state
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
