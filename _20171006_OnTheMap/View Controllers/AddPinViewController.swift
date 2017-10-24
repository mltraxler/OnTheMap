//
//  AddPinViewController.swift
//  _20171006_OnTheMap
//
//  Created by Maria Traxler on 10/12/17.
//  Copyright © 2017 Maria Traxler. All rights reserved.
//

import UIKit

//this name was poorly chosen! I can probably create a new VC with a better name and just copy/paste this code in there...right?
class AddPinViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var mapStringTextField: UITextField!

    // MARK: IBActions
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func triggerSegueToAddUrl(_ sender: Any) {
        mapStringTextField.resignFirstResponder()
        if let myMapString = mapStringTextField.text, myMapString != "" {
            //even if the user cancels, the mapString stored for the user in myStudentLocation isn't used for anything else, and they cannot drop a new pin except via this route - so it will be overwritten if they do enter a new mapString
            StudentLocationModel.sharedInstance.myStudentLocation?.mapString = myMapString
            performSegue(withIdentifier: "addPinToAddUrlSegue", sender: self)
        } else {
            AlertHelper.sharedInstance.presentAlert(withTitle: "No Map String Given", message: "No location string was entered. Please enter a valid location.", presenter: self)
        }
    }
    
    @IBAction func deleteMyLocation(_ sender: Any) {
        
        if let objectIdToDelete: String = StudentLocationModel.sharedInstance.myStudentLocation!.objectId {
            ClientCode.sharedInstance.deleteStudentLocation(objectIdToDelete) { (result, error) in
                if error == nil {
                    StudentLocationModel.sharedInstance.myStudentLocation!.objectId = nil
                    self.dismiss(animated: true, completion: nil)
                } else {
                    AlertHelper.sharedInstance.presentAlert(withTitle: "DELETE error", message: "There was an error when trying to delete the location: \(String(describing: error))", presenter: self)
                }
            } 
        } else {
            AlertHelper.sharedInstance.presentAlert(withTitle: "DELETE error", message: "There is no location stored for this user", presenter: self)
        }
    }
    
    // MARK: Lifecycle Methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
