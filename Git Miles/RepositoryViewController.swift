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
import CoreData

class RepositoryViewController: UITableViewController, UISearchBarDelegate,
    NSFetchedResultsControllerDelegate {
    
    var filteredRepos: [Repository] = []
//    var shouldShowSearchResults = false
    var selectedRepo: Repository!
    
    let activityIndicator = UIActivityIndicatorView()
    
    var searchController: UISearchController!
    var fetchedResultsController: NSFetchedResultsController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib(nibName: "RepositoryCell", bundle: nil), forCellReuseIdentifier: "repositoryCell")
        
        configureFetchedResultsController()
        
        GitHubAPIManager.sharedInstance.getRepositories() {
            response in
            
            let statusCode = response.response?.statusCode
            print("status code: \(statusCode)")
            if (statusCode >= 200 && statusCode < 300) {
                let json = JSON(response.result.value!)
                
                //store repos
                CoreDataHelper.storeRepos(json)
//                self.repos = CoreDataHelper.fetchRepos()
            }
            
            self.activityIndicator.removeFromSuperview()
//            self.tableView.reloadData()
        }
        
        configureSearchController()
    }
    
    // MARK: User Interface
    
    func showActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    // MARK: FetchedResultsController
    
    func configureFetchedResultsController() {
        let fetchRequest = NSFetchRequest(entityName: "Repository")
        let fetchSort = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [fetchSort]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                    managedObjectContext: DataController.sharedInstance.managedObjectContext,
                    sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Controller could not perform fetch: \(error)")
        }
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        // 1
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
            
        default: break
            
        }
        
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        // 2
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
            
        }
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "repoToMilestones") {
            let target = segue.destinationViewController as! MilestonesViewController
            target.repo = selectedRepo
        }
    }
    
    // MARK: SearchController
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let searchString = searchBar.text! as NSString
        if searchString.length > 0 {
            let predicate = NSPredicate(
                format: "(name contains [cd] %@) || (ownerLogin contains [cd] %@)",
                searchString, searchString)
            fetchedResultsController.fetchRequest.predicate = predicate
            
        } else {
            fetchedResultsController.fetchRequest.predicate = nil
        }
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
        tableView.reloadData()
        
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        print("did end editing")
        searchBar.resignFirstResponder()
        fetchedResultsController.fetchRequest.predicate = nil
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
        
        tableView.reloadData()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        
        let repos = fetchedResultsController.fetchedObjects as! [Repository]
        
        filteredRepos = repos.filter({ (repo) -> Bool in
            if searchString == "" {
                return true
            }
            return (repo.name!.rangeOfString(searchString!, options: NSStringCompareOptions.CaseInsensitiveSearch)) != nil
        })
        
        tableView.reloadData()
    }
    
    func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search repositories..."
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        
        tableView.tableHeaderView = searchController.searchBar
    }
    
    // MARK: TableView
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard let sectionCount = fetchedResultsController.sections?.count else {
            return 0
        }
        return sectionCount
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionData = fetchedResultsController.sections?[section] else {
            return 0
        }
        return sectionData.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
    -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("repositoryCell", forIndexPath: indexPath) as! RepositoryCell
        let repo: Repository!
        
        repo = fetchedResultsController.objectAtIndexPath(indexPath) as! Repository
        
        cell.setupCell(repo)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        
        selectedRepo = fetchedResultsController.objectAtIndexPath(indexPath) as! Repository
        
        searchController.active = false
        
        performSegueWithIdentifier("repoToMilestones", sender: self)
    }
    
    
}
