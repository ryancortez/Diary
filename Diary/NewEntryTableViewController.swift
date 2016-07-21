//
//  NewEntryTableViewController.swift
//  Diary
//
//  Created by Ryan Cortez on 7/20/16.
//  Copyright © 2016 Ryan Cortez. All rights reserved.
//

import UIKit

protocol NewEntryViewControllerDelegate {
    func insertNewDiaryEntry(title: String, entry: String)
}

class NewEntryTableViewController: UITableViewController {

    @IBOutlet weak var entryTitleTextField: UITextField!
    @IBOutlet weak var entryTextView: UITextView!
    var delegate:DiaryEntryListViewController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view Data Source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    // MARK: - Helper Methods
    
    func getCurrentDateAsString () -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy, HH:mm:ss"
        let string = dateFormatter.stringFromDate(NSDate())
        return string
    }
    
    // MARK: - Actions
    @IBAction func saveButtonPressed(sender: AnyObject) {
        
        if (entryTitleTextField.text != "" && entryTitleTextField.text != nil) {
            delegate.insertNewDiaryEntry(entryTitleTextField.text!, entry: entryTextView.text, date: getCurrentDateAsString())
        } else {
            delegate.insertNewDiaryEntry("Untitled", entry: entryTextView.text, date: getCurrentDateAsString())
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
