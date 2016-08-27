//
//  RepositoryCell.swift
//  Git Miles
//
//  Created by Shubham Agrawal on 26/08/16.
//  Copyright © 2016 Shubham Agrawal. All rights reserved.
//

import UIKit

class RepositoryCell: UITableViewCell {
    
    var repo: Repository!
    
    // MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.accessoryType = .DisclosureIndicator
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(repo: Repository) {
        self.repo = repo
        titleLabel.text = repo.name!
        subtitleLabel.text = repo.ownerLogin!
        let buttonImage = UIImage(named: "star_black")
        favoriteButton.setImage(buttonImage, forState: UIControlState.Normal)
    }
    
    @IBAction func onClickFav(sender: UIButton) {
        print("fav clicked")
        if (repo.isFavorite == nil || repo.isFavorite == 0) {
            print("adding to fav")
            CoreDataHelper.setFavorite(repo, value: 1)
        } else {
            print("removing from fav")
            CoreDataHelper.setFavorite(repo, value: 0)
        }
    }
    
    
}
