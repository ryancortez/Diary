//
//  ViewController.swift
//  Diary
//
//  Created by Ryan Cortez on 7/19/16.
//  Copyright © 2016 Ryan Cortez. All rights reserved.
//

import UIKit
import CoreData

class DiaryEntryListViewController: UITableViewController, NSFetchedResultsControllerDelegate {
 
    // CoreDataManager is a helper class that sets up CoreData
    var coreDataManager: CoreDataManager!
    var managedObjectContext: NSManagedObjectContext!
    var fetchResultsController: NSFetchedResultsController!
    var entries = [AnyObject]()
    
    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initFetchResultsController()
    }
    
    // MARK: - Core Data
    func initFetchResultsController() {
        let entityName = "DiaryEntry"
        let fetchRequest = NSFetchRequest(entityName: entityName)
        
        // Diary Entries will be display in descending order from the date created
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: false)]
        
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        self.fetchResultsController.delegate = self
        
        do {
            try self.fetchResultsController.performFetch()
        } catch {
            print("fetchResultsController was unable to perform fetch")
            return
        }
        guard let fetchedObjects = fetchResultsController.fetchedObjects else {
            print ("Unable to fetch objects from Entity: \(entityName)")
            return
        }
        
        entries = fetchedObjects
    }
    
    // MARK: - TableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = self.fetchResultsController.sections else {
            fatalError("No sections were found in the fetchResultsController")
        }
        return sections[section].numberOfObjects
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let diaryEnteryTableViewCell = DiaryEntryCellTableViewCell(style: .Subtitle, reuseIdentifier: "DiaryEntryCell")
        
        let entry = self.fetchResultsController.objectAtIndexPath(indexPath)
        diaryEnteryTableViewCell.textLabel?.text = entry.valueForKey("title") as? String
        diaryEnteryTableViewCell.detailTextLabel?.text = entry.valueForKey("entry") as? String
        
        return diaryEnteryTableViewCell
    }
    
    // MARK: - TableViewDelegate
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch(type) {
        case .Insert:
            // Animate the inserting of new rows
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
            break
        case .Delete:
            break
        case .Update:
            break
        case .Move:
            break
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        // The behavior defined when a user deletes a row
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            
            guard let fetchedObjects = self.fetchResultsController.fetchedObjects else {
                print("No fetchedObjects were found")
                return
            }
            guard let managedObject = fetchedObjects[indexPath.row] as? NSManagedObject else {
                print("No managedObject pulled or an incorrect NSManagedObject was pulled when getting object from fetchedObjects[] ")
                return
            }
            
            // Remove the deleted row from CoreData
            self.managedObjectContext.deleteObject(managedObject)
            do {
                try self.managedObjectContext.save()
            } catch {
                print(CoreDataErrorType.UnableToSave.rawValue)
                return
            }
            
            let indexPaths = [indexPath]
            self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    // All cells have the ability to show the delete button
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    // All cells can be edited (deleted)
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // MARK: - Helper Method
    
    // Creates a new NSManagedObject for a new DiaryEntry in CoreData
    func insertNewDiaryEntry(title: String, entry: String, date: String) {
        let diaryEntry = NSEntityDescription.insertNewObjectForEntityForName("DiaryEntry", inManagedObjectContext: self.managedObjectContext)
        diaryEntry.setValue(title, forKey: "title")
        diaryEntry.setValue(entry, forKey: "entry")
        diaryEntry.setValue(date, forKey: "dateCreated")
        
        do {
            try self.managedObjectContext.save()
        } catch {
            print("Unable to save new diary entry from addButtonPress")
            return
        }
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // If the Add Button was pressed, this DiaryEntryList controller is the NewEntryTableViewController Delegate
        if (segue.identifier == "diaryEntryListToNewEntry") {
            let navigationViewController = segue.destinationViewController as! UINavigationController
            let newEntryViewController = navigationViewController.viewControllers.first as! NewEntryTableViewController
            newEntryViewController.delegate = self
            
        }
    }
}