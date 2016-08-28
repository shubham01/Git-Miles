//
//  RepositoryCell.swift
//  Git Miles
//
//  Created by Shubham Agrawal on 26/08/16.
//  Copyright © 2016 Shubham Agrawal. All rights reserved.
//

import UIKit
import TTGSnackbar

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
        
        favoriteButton.setImage(ImageProvider.getFavoriteImage(repo.isFavorite),
                                forState: UIControlState.Normal)
        
    }
    
    @IBAction func onClickFav(sender: UIButton) {
        
        if (repo.isFavorite == nil || repo.isFavorite == 0) {
            //Add to favorite
            CoreDataHelper.setFavorite(repo, value: 1)
        } else {
            //Remove from favorite
            CoreDataHelper.setFavorite(repo, value: 0)
            let snackbar = TTGSnackbar.init(message: "Removed from favorites", duration: .Middle, actionText: "Undo") { (snackbar) in
                CoreDataHelper.setFavorite(self.repo, value: 1)
            }
            
            snackbar.bottomMargin = 52.0
            snackbar.show()
        }
    }
    
    
}
