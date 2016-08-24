//
//  PullRequestViewController.swift
//  Git Miles
//
//  Created by Shubham Agrawal on 24/08/16.
//  Copyright © 2016 Shubham Agrawal. All rights reserved.
//

import UIKit

class PullRequestViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var updatedLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var pullRequest: PullRequest!
    
    // MARK
    override func viewDidLoad() {
        super.viewDidLoad()

        setPullRequestDetails()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setPullRequestDetails() {
        titleLabel.text = pullRequest.title
        idLabel.text = "#\(pullRequest.number)"
        
        stateLabel.text = pullRequest.state
        if stateLabel.text == "open" {
            stateLabel.backgroundColor = UIColor(colorHex: 0x2ecc71)
        }
        
        createdLabel.text = pullRequest.createdAt
        updatedLabel.text = pullRequest.updatedAt
        descriptionLabel.text = pullRequest.body
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}