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
    
    @IBOutlet weak var labelsTable: UITableView!
    @IBOutlet weak var assigneesTable: UITableView!
    
    var pullRequest: PullRequest!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var showAvatars: Bool!
    var showOpenPRs: Bool!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        showAvatars = defaults.boolForKey("showAvatars")
        showOpenPRs = defaults.boolForKey("showOpenPRs")
        
        setPullRequestDetails()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setPullRequestDetails() {
        titleLabel.text = pullRequest.title
        idLabel.text = "#\(pullRequest.number)"
        
        stateLabel.text = " \(pullRequest.state) "
        if stateLabel.text == " open " {
            stateLabel.backgroundColor = UIColor(colorHex: 0x2ecc71, alpha: 0.8)
        }
        
        //To make NSDate objects from ISO8601 timestamp
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        
        //To convert NSDate object to string
        let dateFormatterOut = NSDateFormatter()
        dateFormatterOut.locale = NSLocale(localeIdentifier: "en_IN")
        
        dateFormatterOut.dateFormat = "HH:mm, MMM d yyyy"
        
        let createdDate = dateFormatter.dateFromString(pullRequest.createdAt)
        createdLabel.text = "Created on \(dateFormatterOut.stringFromDate(createdDate!))"
        
        let updatedDate = dateFormatter.dateFromString(pullRequest.updatedAt)
        updatedLabel.text = "Updated on \(dateFormatterOut.stringFromDate(updatedDate!))"
        
        descriptionLabel.text = pullRequest.body
    }

}


//For table view
extension PullRequestViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == labelsTable {
            return pullRequest.labels.count
        }
        return pullRequest.assignees.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(tableView == labelsTable) {
            let cell = tableView.dequeueReusableCellWithIdentifier("prLabelCell", forIndexPath:
                indexPath) as! PRLabelCell
            cell.setupCell(pullRequest.labels[indexPath.row])
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("prAssigneeCell", forIndexPath:
                indexPath)
            cell.textLabel?.text = pullRequest.assignees[indexPath.row].login
            
            if let show = showAvatars where show {
                let url = NSURL(string: (pullRequest.assignees[indexPath.row].avatar))
                print(url)
                
                cell.imageView?.af_setImageWithURL(url!, placeholderImage: ImageProvider.userPlaceHolderImage)
            } else {
                cell.imageView?.image = ImageProvider.userPlaceHolderImage
            }
            
            return cell
        }
    }
    
}