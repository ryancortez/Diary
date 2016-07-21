//
//  CoreDataManager.swift
//  Diary
//
//  Created by Ryan Cortez on 7/19/16.
//  Copyright © 2016 Ryan Cortez. All rights reserved.
//

import Foundation
import CoreData


// A custom class that sets up Cor
enum CoreDataErrorType: String, ErrorType {
    case UnableToSave = "NSManagedObjectContext was unable to save changes"
}


class CoreDataManager: NSObject {
    
    var managedObjectContext:NSManagedObjectContext
    
    enum StoreType:String {
        case SQLite, Binary, InMemory
        func stringValue() -> String {
            switch self {
            case .SQLite:
                return NSSQLiteStoreType
            case .Binary:
                return NSBinaryStoreType
            case .InMemory:
                return NSInMemoryStoreType
            }
        }
    }
    
    init(xcDataModelFileName: String, storeType: StoreType) {
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        super.init()
        
        // Get the XCDataModel File
        let xcDataModelFileName = "Model"
        let extenstionName = "momd"
        guard let url = NSBundle.mainBundle().URLForResource(xcDataModelFileName, withExtension: extenstionName) else {
            fatalError("Could not save URL for \(xcDataModelFileName).xcdatamodeld \(extenstionName)")
        }
        // Create a NSManagedObjectModel from the XCDataModel File
        guard let managedObjectModel = NSManagedObjectModel(contentsOfURL: url) else {
            fatalError("Could not create NSManagedObjectModel from \(xcDataModelFileName).xcdatamodeld \(extenstionName)")
        }
        
        // Create a NSPersistentStoreCoordinator from the NSManagedObjectModel
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        // Get the URL for the Document folder in the App Bundle
        let fileManager = NSFileManager()
        guard let documentURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first else {
            fatalError("Could not get the URL of the Document folder")
        }
        
        // Create a URL for the Persistent Store (SQLite Database)
        let persistentStoreFileName = "\(xcDataModelFileName).sqlite"
        let persistentStoreURL = documentURL.URLByAppendingPathComponent(persistentStoreFileName)
        
        // Add the Persistent Store File into the Document Directory
        do {
            try persistentStoreCoordinator.addPersistentStoreWithType(storeType.stringValue(), configuration: nil,  URL: persistentStoreURL, options: nil)
        } catch {
            fatalError("Could not save the \(storeType) file to URL: \(persistentStoreURL)")
        }
        
        self.managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
    }

}