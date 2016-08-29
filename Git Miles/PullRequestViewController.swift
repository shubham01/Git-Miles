//
//  PullRequestViewController.swift
//  Git Miles
//
//  Created by Shubham Agrawal on 24/08/16.
//  Copyright © 2016 Shubham Agrawal. All rights reserved.
//

import UIKit
import AlamofireImage

class PullRequestViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var updatedLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var pullRequestIcon: UIImageView!
    @IBOutlet weak var labelsTable: UITableView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var pullRequest: PullRequest!
    var labels: [Label]!
    var assignees: [Assignee]!
    
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    let sections: [String] = ["Labels", "Assignees"]
    
    var showAvatars: Bool!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        showAvatars = defaults.boolForKey("showAvatars")
        
        setPullRequestDetails()
        labels = pullRequest.labels?.allObjects as! [Label]
        assignees = pullRequest.assignees?.allObjects as! [Assignee]
        
        pullRequestIcon.image = ImageProvider.pullRequestImage
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setPullRequestDetails() {
        
        titleLabel.text = pullRequest.title!
        idLabel.text = "#\(pullRequest.number!)"
        
        stateLabel.text = "\(pullRequest.state!)"
        if pullRequest.state == "open" {
            let greenColor = UIColor(colorHex: 0x6cc644, alpha: 1.0)
            pullRequestIcon.tintColor = greenColor
            stateLabel.textColor = greenColor
        } else {
            let redColor = UIColor(colorHex: 0xbd2c00, alpha: 1.0)
            pullRequestIcon.tintColor = redColor
            stateLabel.textColor = redColor
        }
        
        usernameLabel.text = pullRequest.userLogin!
        
        //To make NSDate objects from ISO8601 timestamp
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        
        //To convert NSDate object to string
        let dateFormatterOut = NSDateFormatter()
        dateFormatterOut.locale = NSLocale(localeIdentifier: "en_IN")
        
        dateFormatterOut.dateFormat = "HH:mm, MMM d yyyy"
        
        let createdDate = dateFormatter.dateFromString(pullRequest.createdAt!)
        createdLabel.text = "Created on \(dateFormatterOut.stringFromDate(createdDate!))"
        
        let updatedDate = dateFormatter.dateFromString(pullRequest.updatedAt!)
        updatedLabel.text = "Updated on \(dateFormatterOut.stringFromDate(updatedDate!))"
        
        descriptionLabel.text = pullRequest.body
    }

}


extension PullRequestViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 27
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.section == 0) {
            return 25
        }
        if (indexPath.section == 1) {
            return 35
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return pullRequest.labels!.count
        } else if (section == 1) {
            return pullRequest.assignees!.count
        }
        return 0
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier("prLabelCell", forIndexPath:
                indexPath) as! PRLabelCell
            cell.setupCell(labels[indexPath.row])
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("prAssigneeCell", forIndexPath:
                indexPath)
            cell.textLabel?.text = assignees[indexPath.row].login
            
            if let show = showAvatars where show {
                let url = NSURL(string: (assignees[indexPath.row].avatar!))
                print(url)
                
                cell.imageView?.af_setImageWithURL(url!, placeholderImage: ImageProvider.userPlaceHolderImage)
            } else {
                cell.imageView?.image = ImageProvider.userPlaceHolderImage
            }
            
            return cell
        }
    }
    
}