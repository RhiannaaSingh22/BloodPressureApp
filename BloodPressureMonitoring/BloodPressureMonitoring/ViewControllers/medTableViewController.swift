//
//  medTableViewController.swift
//  BloodPressureMonitoring
//
//  Created by Rhiannaa Singh on 16/04/2019.
//  Copyright © 2019 Rhiannaa Singh. All rights reserved.
//
/*
 References:
 Build A Todo Application in Swift 4 | Auto Layout | Core Data. (2017). [video] Directed by G. Tokman. Youtube.
 */

import UIKit
import CoreData

class medTableViewController: UITableViewController {
    
    //MARK: - Properties
    //generic so you would need to specify the object it's responsible for managing eg saving the medication showing in table
    var resultsController: NSFetchedResultsController<Medicine>!
    let coreDataStack = CoreDataStack()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Request - create a request to specify what to look for
        let request:NSFetchRequest<Medicine> = Medicine.fetchRequest()
            //sort descriptors to be specific
        let sortDescriptors = NSSortDescriptor(key: "name", ascending: true)
        
        //Initialise - inti the results controller
        request.sortDescriptors = [sortDescriptors]
        resultsController = NSFetchedResultsController(
            //fetchRequest - how to get the medication create the request
            fetchRequest: request,
            managedObjectContext: coreDataStack.managedContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        resultsController.delegate = self
        //Fetch - fetch the data
        do{
            try resultsController.performFetch()
        } catch {
            print("Perform fetch error: \(error)")
        }
        
        var i = 0
        for result in resultsController.fetchedObjects! {
            if result.takenToday == true{
                let cell = tableView.cellForRow(at: IndexPath(row: i, section: 1))
                cell?.backgroundColor = UIColor(red: 192/255, green: 247/255, blue: 204/255, alpha: 1.0)
            }
            i+=1
        }
        
    }
    
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath){
        let medi = resultsController.object(at: indexPath)
        let cDate = Date()
        let dFormat = DateFormatter()
        dFormat.dateFormat = "dd.MM.yyyy"
        let today = dFormat.string(from: cDate)
        let lastDateTaken = dFormat.string(from: medi.lastTakeDate!)
        
        if lastDateTaken != today {
            medi.takenToday = false
            do{
                try self.resultsController.managedObjectContext.save()
            } catch {
                print("delete failed \(error)")
            }
        }

        if medi.takenToday == true{
            cell.backgroundColor = UIColor(red: 192/255, green: 247/255, blue: 204/255, alpha: 1.0)
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mediCell", for: indexPath)

        // Configure the cell...
        let medi = resultsController.object(at: indexPath)
        cell.textLabel?.text = medi.name

        return cell
    
    }
    
    //MARK: Table View Delegate
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete"){
            (action, view, completion) in
            //Delete Medication
            let medi = self.resultsController.object(at: indexPath)
            self.resultsController.managedObjectContext.delete(medi)
            do{
                try self.resultsController.managedObjectContext.save()
                completion(true)
            } catch {
                print("delete failed \(error)")
                completion(false)
            }
        }
        action.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: "Taken"){
            (action, view, completion) in
            //taken Medication
            let medi = self.resultsController.object(at: indexPath)
            medi.lastTakeDate = Date()
            medi.takenToday = !medi.takenToday //sets it to false if true, and true if false in case of mistake
            
            do{
                try self.resultsController.managedObjectContext.save()
                if medi.takenToday {
                    let cell = tableView.cellForRow(at: indexPath)
                    cell?.backgroundColor = UIColor(red: 192/255, green: 247/255, blue: 204/255, alpha: 1.0)
                }
                else {
                    let cell = tableView.cellForRow(at: indexPath)
                    cell?.backgroundColor = .white
                }
                completion(true)
            } catch {
                print("delete failed \(error)")
                completion(false)
            }
        }
        action.backgroundColor = .green
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showAddMedication", sender: tableView.cellForRow(at: indexPath))
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Initalise the managedContext on modal view contoller
        //sender casted to UIBarButtonItem ie the + button checking if the sender clicking of type UIBarButtonItem
        //then create constant for vc casted to the desination vc
        if let _ = sender as? UIBarButtonItem, let viewC = segue.destination as? addMedViewController{
            //access this vc its mangagedConext property and initalised it the coredata stack managedConext allowing us to save the medication added
            viewC.managedContext = resultsController.managedObjectContext
        }
        
        if let cell = sender as? UITableViewCell, let viewC = segue.destination as? addMedViewController{
            viewC.managedContext = resultsController.managedObjectContext
            if let indexPath = tableView.indexPath(for: cell){
                let medi = resultsController.object(at: indexPath)
                viewC.medi = medi
            }
            
        }
    }

}

extension medTableViewController: NSFetchedResultsControllerDelegate{
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath{
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath{
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath){
                let medi = resultsController.object(at: indexPath)
                cell.textLabel?.text = medi.name
                
            }
        default:
            break
        }
    }
}
