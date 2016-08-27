//
//  FavoriteRepositoryViewController.swift
//  Git Miles
//
//  Created by Shubham Agrawal on 27/08/16.
//  Copyright © 2016 Shubham Agrawal. All rights reserved.
//

import UIKit
import CoreData

class FavoriteRepositoryViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var selectedRepo: Repository!

    var fetchedResultsController: NSFetchedResultsController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib(nibName: "RepositoryCell", bundle: nil), forCellReuseIdentifier: "repositoryCell")
        configureFetchedResultsController()

//        self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "favToMilestones") {
            let target = segue.destinationViewController as! MilestonesViewController
            target.repo = selectedRepo
        }
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
        return 60.0
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
        
        performSegueWithIdentifier("favToMilestones", sender: self)
    }
    
    // MARK: Fetched results controller
    
    func configureFetchedResultsController() {
        let fetchRequest = NSFetchRequest(entityName: "Repository")
        let fetchSort = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [fetchSort]
        
        fetchRequest.predicate = NSPredicate(format: "isFavorite == %d", 1)
        
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

    
}
