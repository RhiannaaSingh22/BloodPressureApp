//
//  ViewController.swift
//  BloodPressureMonitoring
//
//  Created by Rhiannaa Singh on 09/04/2019.
//  Copyright © 2019 Rhiannaa Singh. All rights reserved.

/*
 References:
    Developer.apple.com. (2019). Scheduling a Notification Locally from Your App | Apple Developer Documentation. [online] Available at: https://developer.apple.com/documentation/usernotifications/scheduling_a_notification_locally_from_your_app [Accessed 24 Apr. 2019].
    Build A Todo Application in Swift 4 | Auto Layout | Core Data. (2017). [video] Directed by G. Tokman. Youtube.
 
 */
//

import UIKit
import UserNotifications
import CoreData

class ViewController: UIViewController {

    //MARK: - Properties
    
    var resultsControllerR: NSFetchedResultsController<Reading>!
    let coreDataStackR = CoreDataStack()

    var resultsControllerU: NSFetchedResultsController<User>!
    let coreDataStackU = CoreDataStack()
    
    
    @IBOutlet weak var viewAddButton: UIButton!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var sysLabel: UILabel!
    @IBOutlet weak var diaLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        
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
        
        //REQUEST
        let requestU: NSFetchRequest<User> = User.fetchRequest()
        let sortDescriptorsU = NSSortDescriptor(key: "name", ascending: false)
        
        //INITIALISE
        requestU.sortDescriptors = [sortDescriptorsU]
        resultsControllerU = NSFetchedResultsController(
            fetchRequest: requestU,
            managedObjectContext: coreDataStackU.managedContextU,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        //FETCH
        do{
            try resultsControllerU.performFetch()
        } catch{
            print("perform fetch error:\(error)")
        }
        // Ask for notification permission
        let notiCenter = UNUserNotificationCenter.current()
        notiCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (access, error) in
        }
        
        openDisplay()
        
        //Create notification and content
        let notiContent = UNMutableNotificationContent()
        notiContent.title = "Notification"
        notiContent.subtitle = "Reminder to take your medication"
        notiContent.body = "Swipe the medication taken in the table"
        
        //Trigger notification
        var dateCom = DateComponents()
        dateCom.calendar = Calendar.current
        
        dateCom.hour = 12
        
        
        let trig = UNCalendarNotificationTrigger(dateMatching: dateCom, repeats: true)
        
        //create the request
        //that containt the noti content and trigger puting them together into an object
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: notiContent, trigger: trig)
        
        
        //register notification
        notiCenter.add(request) { (error) in
            //check error and hanndle any errors
            if error != nil{
                
            }
        }
    }
    
    func openDisplay(){
        if resultsControllerU.fetchedObjects!.count != 0{
            let user = resultsControllerU.fetchedObjects![0]
            let username = user.name
            
            welcomeLabel.text = "Welcome " + username!
            
            let read = resultsControllerR.fetchedObjects![0]
            
            sysLabel.text = read.sysVal
            diaLabel.text = read.diaVal
        }
    }
}

