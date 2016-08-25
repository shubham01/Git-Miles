//
//  PRLabelCell.swift
//  Git Miles
//
//  Created by Shubham Agrawal on 25/08/16.
//  Copyright © 2016 Shubham Agrawal. All rights reserved.
//

import UIKit

class PRLabelCell: UITableViewCell {

    // MARK: Outlets
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    func setupCell(label: PullRequest.Label) {
        
        let colorCode = Int(label.color, radix: 16) ?? 0
        
        var color = UIColor(colorHex: colorCode, alpha: 1.0)
        colorLabel.text = "  "
        colorLabel.backgroundColor = color
        
        color = UIColor(colorHex: colorCode, alpha: 0.1)
        nameLabel.text = " \(label.name) "//label.name
        nameLabel.backgroundColor = color
    }
    
}
