//
//  CoreDataStack.swift
//  BloodPressureMonitoring
//
//  Created by Rhiannaa Singh on 17/04/2019.
//  Copyright © 2019 Rhiannaa Singh. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack{
    //entry point into saving the medication in core data
    
    //NS Persistant Container - interact with medicine data model
    
    var container: NSPersistentContainer{
        let container = NSPersistentContainer(name: "Medicine")
        container.loadPersistentStores { (description, error) in
            //to avoid an error
            guard error == nil else{
                print("Error: \(error!)")
                return
            }
        }
        return container
    }
    
    //Managed Object Context - resposible for saving deleting, updating the state of the data model
    
    var managedContext: NSManagedObjectContext{
        return container.viewContext
    }
    
    var containerR: NSPersistentContainer{
        let containerR = NSPersistentContainer(name: "Reading")
        containerR.loadPersistentStores { (description, error) in
            //to avoid an error
            guard error == nil else{
                print("Error: \(error!)")
                return
            }
        }
        return containerR
    }
    
    //Managed Object Context - resposible for saving deleting, updating the state of the data model
    var managedContextR: NSManagedObjectContext{
        return containerR.viewContext
    }
    
    var containerU: NSPersistentContainer{
        let containerU = NSPersistentContainer(name: "User")
        containerU.loadPersistentStores { (description, error) in
            //to avoid an error
            guard error == nil else{
                print("Error: \(error!)")
                return
            }
        }
        return containerU
    }
    
    //Managed Object Context - resposible for saving deleting, updating the state of the data model
    var managedContextU: NSManagedObjectContext{
        return containerU.viewContext
    }
}
