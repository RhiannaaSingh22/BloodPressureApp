//
//  addMedViewController.swift
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

class addMedViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    //MARK: - Properties
    var managedContext: NSManagedObjectContext!
    var medi: Medicine?
    
    //MARK: Outlets
    @IBOutlet weak var nameTextF: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var dosage: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var notes: UITextView!
    
    
    @IBOutlet weak var bottomCon: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardShow(with:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        nameTextF.becomeFirstResponder()
        numberPadInput()
        
        if let medi = medi{
            nameTextF.text = medi.name
            dosage.text = medi.dosage
            notes.text = medi.notes
            nameTextF.text = medi.name
            dosage.text = medi.dosage
            notes.text = medi.notes
            
        }
    }
    
    //MARK: Actions
    @objc func keyboardShow(with notification: Notification){
        let key = "UIKeyboardFrameEndUserInfoKey"
        guard let keyboardFrame = notification.userInfo?[key] as? NSValue else {return}
        
        //margin of 10 between keyboard and button
        let keyboardHeight = keyboardFrame.cgRectValue.height + 10
        
        bottomCon.constant = keyboardHeight
        UIView.animate(withDuration: 0.3){
            self.view.layoutIfNeeded()
        }
    }
    
    fileprivate func dismissResign() {
        dismiss(animated: true)
        nameTextF.resignFirstResponder()
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        dismissResign()
    }
    
    @IBAction func addMed(_ sender: UIButton) {
        
        guard let name = nameTextF.text, !name.isEmpty else{
            let alert = UIAlertController(title:"Invalid Entry", message: "Fill in text fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(alert, animated: true, completion: nil)
            return
        }
        guard let dosage = dosage.text, !dosage.isEmpty else {
            let alert = UIAlertController(title:"Invalid Entry", message: "Fill in text fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(alert, animated: true, completion: nil)
            return
        }
        guard let notes = notes.text, !notes.isEmpty else {
            let alert = UIAlertController(title:"Invalid Entry", message: "Fill in text fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if let medi = self.medi{
            medi.name = name
            medi.dosage = dosage
            medi.notes = notes
        }else{
            let medi = Medicine(context: managedContext)
            medi.name = name
            medi.dosage = dosage
            medi.notes = notes
            medi.takenToday = false
            medi.lastTakeDate = Date()
        }
        
        //to save
        do{
            try managedContext.save()
            dismissResign()
        }catch{
            print("Error saving medicine: \(error)")
        }
        
    }
    
    func numberPadInput(){
        dosage.keyboardType = UIKeyboardType.numberPad
    }
    
    
    @IBAction func selectImage(_ sender: UIButton) {
        let img = UIImagePickerController()
        img.delegate = self
        
        img.sourceType = UIImagePickerController.SourceType.photoLibrary
        img.allowsEditing = false
        self.present(img, animated: true){
            
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imageView.image = img
        }else{
            //error
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}

extension addMedViewController: UITextViewDelegate{
    func textViewDidChangeSelection(_ textView: UITextView) {
        if addButton.isHidden{
            notes.text.removeAll()
            notes.textColor = .black
            
            addButton.isHidden = false
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
}
