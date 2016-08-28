//
//  SettingsViewController.swift
//  Git Miles
//
//  Created by Shubham Agrawal on 28/08/16.
//  Copyright © 2016 Shubham Agrawal. All rights reserved.
//

import UIKit
import TTGSnackbar

class SettingsViewController: UITableViewController {
    
    // MARK: Outlets
    @IBOutlet weak var showAvtarsSwitch: UISwitch!
    @IBOutlet weak var showOpenPRSwitch: UISwitch!
    @IBOutlet weak var loggedInAsLabel: UILabel!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loggedInAsLabel.text = DataHelper.username!
        
        showAvtarsSwitch.tag = 1
        showAvtarsSwitch.addTarget(self, action: #selector(SettingsViewController.showAvatarsChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        showOpenPRSwitch.tag = 2
        showOpenPRSwitch.addTarget(self, action: #selector(SettingsViewController.showAvatarsChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        setupViews()
    }
    
    func setupViews() {
        showAvtarsSwitch.on = defaults.boolForKey("showAvatars")
        showOpenPRSwitch.on = defaults.boolForKey("showOpenPRs")
    }
    
    func showAvatarsChanged(switchView: UISwitch) {
        switch switchView.tag {
        case showAvtarsSwitch.tag:
            defaults.setBool(showAvtarsSwitch.on, forKey: "showAvatars")
            break
        case showOpenPRSwitch.tag:
            defaults.setBool(showOpenPRSwitch.on, forKey: "showOpenPRs")
            break
        default: ()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    @IBAction func onClickLogout(sender: UIButton) {
        
        let alert = UIAlertController(title: "Logout", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .Default , handler: { (action: UIAlertAction!) in
            self.logout()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction!) in
//            alert.removeFromParentViewController()
        }))

        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func logout() {
        let snackbar = TTGSnackbar.init(message: "Logging out", duration: .Forever)
        snackbar.show()
        
        CoreDataHelper.deleteEntity("Repository")
        CoreDataHelper.deleteEntity("Milestone")
        CoreDataHelper.deleteEntity("Label")
        CoreDataHelper.deleteEntity("Assignee")
        CoreDataHelper.deleteEntity("PullRequest")
        
        DataHelper.deleteValues()
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewControllerWithIdentifier("loginViewController") as! ViewController
        UIApplication.sharedApplication().keyWindow?.rootViewController = viewController;
        
//        GitHubAPIManager.sharedInstance.logout() {
//            response in
//            snackbar.dismiss()
//            
//            let status = response.response?.statusCode
//            print(response)
//            if status >= 200 && status < 300 {
//                
//            } else {
//                let errorSnackBar = TTGSnackbar.init(message: "Oops! Please log out again", duration: .Long, actionText: "Retry") {
//                    snackbar in
//                    snackbar.dismiss()
//                    self.logout()
//                }
//                errorSnackBar.show()
//            }
//        }
    }

    

}
