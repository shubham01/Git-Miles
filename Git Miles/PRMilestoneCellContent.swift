//
//  PRMilestoneCellContent.swift
//  Git Miles
//
//  Created by Shubham Agrawal on 23/08/16.
//  Copyright © 2016 Shubham Agrawal. All rights reserved.
//

import UIKit

class PRMilestoneCellContent: UITableViewCell {

    // MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dueOnLabel: UILabel!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    @IBOutlet weak var completedLabel: UILabel!
    @IBOutlet weak var dropdownIndicator: UIImageView!
    @IBOutlet weak var openLabel: UILabel!
    @IBOutlet weak var closedLabel: UILabel!
    @IBOutlet weak var progressIndicator: UIProgressView!
    
    // MARK: Member variables
    var downIndicator: UIImage!
    var upIndicator: UIImage!
    
    var collapsed = true
    
    
    // MARK: UITableViewCell methods
    override func awakeFromNib() {
        super.awakeFromNib()
        
        downIndicator = UIImage(named: "arrow_indicator")
        upIndicator = UIImage(CGImage: downIndicator!.CGImage!, scale: 1.0, orientation: .DownMirrored)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: Member functions
    
    func setupCell(milestone: Milestone) {
        titleLabel.text = milestone.title!
        descriptionLabel.text = milestone.descriptionBody!
        
        //To make NSDate objects from ISO8601 timestamp
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        
        //To convert NSDate object to string
        let dateFormatterOut = NSDateFormatter()
        dateFormatterOut.locale = NSLocale(localeIdentifier: "en_IN")
        
        dateFormatterOut.dateFormat = "HH:mm, MMM d yyyy"
        let updatedDate = dateFormatter.dateFromString(milestone.updatedAt!)
        lastUpdatedLabel.text = "Updated at \(dateFormatterOut.stringFromDate(updatedDate!))"
        
        if (milestone.dueOn == "") {
            dueOnLabel.text = "No due date"
        } else {
            dateFormatterOut.dateFormat = "MMM d yyyy"
            let dueDate = dateFormatter.dateFromString(milestone.dueOn!)
            dueOnLabel.text = "Due on \(dateFormatterOut.stringFromDate(dueDate!))"
        }
        
        let completed = (Double(milestone.closedIssues!) * 100.0) /
            (Double(milestone.closedIssues!) + Double(milestone.openIssues!))
        
        completedLabel.text = "\(round(completed))% completed"
        progressIndicator.setProgress(Float(completed / 100.0), animated: true)
        
        
        
        openLabel.text = "\(milestone.openIssues!) open"
        closedLabel.text = "\(milestone.closedIssues!) closed"
        
        dropdownIndicator.image = downIndicator
    }
    
    func updateIndicator() {
        collapsed = !collapsed
        if collapsed {
            dropdownIndicator.image = downIndicator
        } else {
            dropdownIndicator.image = upIndicator
        }
    }
    
}
