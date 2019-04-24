//
//  addViewController.swift
//  BloodPressureMonitoring
//
//  Created by Rhiannaa Singh on 12/04/2019.
//  Copyright © 2019 Rhiannaa Singh. All rights reserved.
//
/*
 References:
    Build A Todo Application in Swift 4 | Auto Layout | Core Data. (2017). [video] Directed by G. Tokman. Youtube.
 */
import UIKit
import CoreData

class addViewController: UIViewController {
    //MARK: -Properties
    var managedContextR: NSManagedObjectContext!
    var resultsControllerR: NSFetchedResultsController<Reading>!
    let coreDataStackR = CoreDataStack()
    
    //MARK: Outlets
    
    @IBOutlet weak var currentDate: UILabel!
    @IBOutlet weak var currentTime: UILabel!
    
    @IBOutlet weak var sysInput: UITextField!
    @IBOutlet weak var diaInput: UITextField!
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //REQUEST
        let requestR: NSFetchRequest<Reading> = Reading.fetchRequest()
        let sortDescriptors = NSSortDescriptor(key: "date", ascending: true)
        
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

        self.managedContextR = resultsControllerR.managedObjectContext
        
        getcurrentDate()
        getcurrentTime()
        numberPadInput()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardShow(with:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)

        sysInput.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }
    
    //MARK: Action
    
    @objc func keyboardShow(with notification:Notification){
        let key = "UIKeyboardFrameEndUserInfoKey"
        guard let keyboardFrame = notification.userInfo?[key] as? NSValue else {return}
        let keyboardHeight = keyboardFrame.cgRectValue.height + 10
        
        bottomConstraint.constant = keyboardHeight
        UIView.animate(withDuration: 0.3){
            self.view.layoutIfNeeded()
        }
    }
    
    fileprivate func dismissResign() {
        dismiss(animated: true)
        sysInput.resignFirstResponder()
    }
    
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        dismissResign()
    }
    
    func getcurrentDate(){
        let cDate = Date()
        let dFormat = DateFormatter()
        
        dFormat.dateFormat = "dd.MM.yyyy"
        let resultDate = dFormat.string(from: cDate)
        
        currentDate.text = resultDate
    }
    
    func getcurrentTime(){
        let cTime = Date()
        let tFormat = DateFormatter()
        
        tFormat.dateFormat = "HH:mm a"
        let resultTime = tFormat.string(from: cTime)
        
        currentTime.text = resultTime
    }
    
    func numberPadInput(){
        sysInput.keyboardType = UIKeyboardType.numberPad
        diaInput.keyboardType = UIKeyboardType.numberPad
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        dismissResign()
    }
    
    @IBAction func addReading(_ sender: UIButton) {
        guard let sysVal = sysInput.text, !sysVal.isEmpty else{
            let alert = UIAlertController(title:"Invalid Entry", message: "Fill in text fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(alert, animated: true, completion: nil)
            return
        
        }
        guard let diaVal = diaInput.text, !diaVal.isEmpty else{
            let alert = UIAlertController(title:"Invalid Entry", message: "Fill in text fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(alert, animated: true, completion: nil)
            return
        }
       
        
        let reading = Reading(context: managedContextR)
        reading.sysVal = sysVal
        reading.diaVal = diaVal
        reading.date = Date()
        reading.time = Date()
        
        if (Int(sysVal)! > 120)||(Int(diaVal)! > 80){
            reading.category = "high"
        } else if (Int(sysVal)! < 90)||(Int(diaVal)! < 60) {
            reading.category = "low"
        }else{
            reading.category = "ideal"
        }
        
        do{
            try managedContextR.save()
            dismissResign()
        } catch{
            print("Error saving reading \(error)")
        }
    }
}
