//
//  readingTableViewController.swift
//  BloodPressureMonitoring
//
//  Created by Rhiannaa Singh on 19/04/2019.
//  Copyright © 2019 Rhiannaa Singh. All rights reserved.
//

import UIKit
import CoreData

class readingTableViewController: UITableViewController {

    //MARK: - Properties
    
    var resultsControllerR: NSFetchedResultsController<Reading>!
    let coreDataStackR = CoreDataStack()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //REQUEST
        let requestR: NSFetchRequest<Reading> = Reading.fetchRequest()
        let sortDescriptors = NSSortDescriptor(key: "date", ascending: false)
        
        //INITIALISE
        requestR.sortDescriptors = [sortDescriptors]
        resultsControllerR = NSFetchedResultsController(
            fetchRequest: requestR,
            managedObjectContext: coreDataStackR.managedContextR,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        //FETCH
        do{
            try resultsControllerR.performFetch()
        } catch{
            print("perform fetch error:\(error)")
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return resultsControllerR.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "readingCell", for: indexPath)
        let dFormat = DateFormatter()
        
        dFormat.dateFormat = "dd.MM.yyyy"
        
        let read = resultsControllerR.object(at: indexPath)
        let d = dFormat.string(from: read.date!)
        cell.textLabel?.text = String(read.sysVal!)+"/"+String(read.diaVal!) + "("+d+")"
        return cell
    }

    //MARK: - Table View delegate
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete"){
            (action, view, completion) in
            //Delete Medication
            let reading = self.resultsControllerR.object(at: indexPath)
            self.resultsControllerR.managedObjectContext.delete(reading)
            do{
                try self.resultsControllerR.managedObjectContext.save()
                completion(true)
            } catch {
                print("delete failed \(error)")
                completion(false)
            }
            
            
        }
        action.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [action])
    }

}
extension readingTableViewController: NSFetchedResultsControllerDelegate{

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let indexPath = indexPath{
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        default:
            break
        }
    }
}
