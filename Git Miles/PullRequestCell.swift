//
//  PullRequestCell.swift
//  Git Miles
//
//  Created by Shubham Agrawal on 24/08/16.
//  Copyright © 2016 Shubham Agrawal. All rights reserved.
//

import UIKit

class PullRequestCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var pullRequestIcon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(pr: PullRequest) {
        
        self.accessoryType = .DisclosureIndicator
        
        titleLabel.text = pr.title
        usernameLabel.text = pr.userLogin
        
        pullRequestIcon.image = ImageProvider.pullRequestImage
        if pr.state == "closed" {
            pullRequestIcon.tintColor = UIColor(colorHex: 0xbd2c00, alpha: 1.0)
        }
        else {
            pullRequestIcon.tintColor = UIColor(colorHex: 0x6cc644, alpha: 1.0)
        }
    }
    
    
    
}
