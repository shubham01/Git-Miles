//
//  RepositoryViewController.swift
//  Git Miles
//
//  Created by Shubham Agrawal on 19/08/16.
//  Copyright © 2016 Shubham Agrawal. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class RepositoryViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    var repos: [Repository] = []
    var filteredRepos: [Repository] = []
    var shouldShowSearchResults = false
    var selectedRepo: Repository!
    
    let activityIndicator = UIActivityIndicatorView()
    
    var searchController: UISearchController!
    
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
            
            let statusCode = response.response?.statusCode
            print("status code: \(statusCode)")
            if (statusCode >= 200 && statusCode < 300) {
                let json = JSON(response.result.value!)
                for (_, repo) in json {
                    self.repos.append(Repository(repo: repo))
                }
            }
            
            self.activityIndicator.removeFromSuperview()
            self.tableView.reloadData()
        }
        
        configureSearchController()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        shouldShowSearchResults = true
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        shouldShowSearchResults = false
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            tableView.reloadData()
        }
        searchController.searchBar.resignFirstResponder()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        
        filteredRepos = repos.filter({ (repo) -> Bool in
            if searchString == "" {
                return true
            }
            return (repo.name.rangeOfString(searchString!, options: NSStringCompareOptions.CaseInsensitiveSearch)) != nil
        })
        
        tableView.reloadData()
    }
    
    func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search repositories..."
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        
        tableView.tableHeaderView = searchController.searchBar
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "repoToMilestones") {
            let target = segue.destinationViewController as! MilestonesViewController
            target.repo = selectedRepo
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shouldShowSearchResults ? filteredRepos.count : repos.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
    -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("repositoryCell", forIndexPath: indexPath)
        let repo = (shouldShowSearchResults ? filteredRepos[indexPath.row] : repos[indexPath.row])
            as Repository
        cell.textLabel?.text = repo.name
        cell.detailTextLabel?.text = String(repo.ownerLogin)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        selectedRepo = shouldShowSearchResults ? filteredRepos[indexPath.row] : repos[indexPath.row]
        
        searchController.active = false
        
        performSegueWithIdentifier("repoToMilestones", sender: self)
    }
    
    
}
