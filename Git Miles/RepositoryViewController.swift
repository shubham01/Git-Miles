//
//  RepositoryViewController.swift
//  Git Miles
//
//  Created by Shubham Agrawal on 19/08/16.
//  Copyright © 2016 Shubham Agrawal. All rights reserved.
//

import UIKit
import SwiftyJSON

class RepositoryViewController: UITableViewController {
    
    var repos:[Repository] = []
    
    let activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debugPrint("Getting repositories")
        
        activityIndicator.center = self.view.center
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        GitHubAPIManager.sharedInstance.getRepositories() {
            response in
            
            self.activityIndicator.hidden = true
            
            debugPrint(response.result.value!)
            let statusCode = response.response?.statusCode
            print("status code: \(statusCode)")
            if (statusCode >= 200 && statusCode < 300) {
                let json = JSON(response.result.value!)
                for (_, repo) in json {
                    let repoId = repo["id"].int!
                    let repoName = repo["name"].string!
                    self.repos.append(Repository(id: repoId, name: repoName))
                }
            }
            
            self.tableView.reloadData()
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repos.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
    -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("repositoryCell", forIndexPath: indexPath)
        let repo = repos[indexPath.row] as Repository
        cell.textLabel?.text = repo.name
        cell.detailTextLabel?.text = String(repo.id)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let row = indexPath.row
        print("Row: \(row)")
        print(repos[row].name)
    }
    
    
}
