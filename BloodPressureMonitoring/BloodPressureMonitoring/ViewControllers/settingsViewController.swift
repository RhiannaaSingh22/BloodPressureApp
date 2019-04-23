//
//  settingsViewController.swift
//  BloodPressureMonitoring
//
//  Created by Rhiannaa Singh on 23/04/2019.
//  Copyright © 2019 Rhiannaa Singh. All rights reserved.
//

import UIKit
import CoreData

class settingsViewController: UIViewController {
    
    //MARK: -Properties
    var managedContextU: NSManagedObjectContext!
    var resultsControllerU: NSFetchedResultsController<User>!
    let coreDataStackU = CoreDataStack()
    
    var userExist  = false
    var user: User?
    
    //MARK: Outlets 
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var ageField: UITextField!
    @IBOutlet weak var heightField: UITextField!
    @IBOutlet weak var weightField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let requestU: NSFetchRequest<User> = User.fetchRequest()
        let sortDescriptors = NSSortDescriptor(key: "height", ascending: true)
        
        //INITIALISE
        requestU.sortDescriptors = [sortDescriptors]
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
        
        self.managedContextU = resultsControllerU.managedObjectContext

        if resultsControllerU.fetchedObjects!.count == 1{
            userExist = true
        }
        
        if resultsControllerU.fetchedObjects!.count==1{
            let user: User = resultsControllerU.fetchedObjects![0]
            self.user = user
            nameField.text = user.name
            ageField.text = String(user.age)
            weightField.text = String(user.weight)
            heightField.text = String(user.height)
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardShow(with:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        
        nameField.becomeFirstResponder()
        
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
    
    @IBAction func saveInfo(_ sender: UIButton) {
        
        guard let name = nameField.text, !name.isEmpty else{
            let alert = UIAlertController(title:"Invalid Entry", message: "Fill in text fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        guard let age = ageField.text, !age.isEmpty else{
            let alert = UIAlertController(title:"Invalid Entry", message: "Fill in text fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        guard let height = heightField.text, !height.isEmpty else{
            let alert = UIAlertController(title:"Invalid Entry", message: "Fill in text fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        guard let weight = weightField.text, !weight.isEmpty else{
            let alert = UIAlertController(title:"Invalid Entry", message: "Fill in text fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if let user = self.user{
            user.name = name
            user.age = Int16(age)!
            user.weight = Int16(weight)!
            user.height = Int16(height)!
        }else{
            let user = User(context: managedContextU)
            user.name = name
            user.age = Int16(age) ?? 0
            user.weight = Int16(weight) ?? 0
            user.height = Int16(height) ?? 0
        }
        
        do{
            try managedContextU.save()
            userExist = true
            dismiss(animated: true)
            nameField.resignFirstResponder()
        } catch{
            print("Error saving reading \(error)")
        }
    }
        
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true)
        nameField.resignFirstResponder()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
