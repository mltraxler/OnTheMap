//
//  StudentTableViewController.swift
//  _20171006_OnTheMap
//
//  Created by Maria Traxler on 10/6/17.
//  Copyright © 2017 Maria Traxler. All rights reserved.
//

import Foundation
import UIKit

class StudentTableViewController: UITableViewController {

    // MARK: IBActions
    
    @IBAction func addPinButton(_ sender: Any) {
        if let myStudentLocation = StudentLocationModel.sharedInstance.myStudentLocation, let _ = myStudentLocation.objectId {
            AlertHelper.sharedInstance.presentOverwriteAlert(withTitle: "Pin Already Exists", message: "A pin already exists for this user. Do you want to overwrite it?", presenter: self)
        } else {
            self.performSegue(withIdentifier: "tableToAddPinSegue", sender: self)
        }
    }

    @IBAction func refreshTable(_ sender: Any) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
    @IBAction func logOut(_sender: Any) {
        ClientCode.sharedInstance.deleteUdacitySession() { success, error in
            if success {
                self.dismiss(animated: true, completion: nil)
            } else {
                AlertHelper.sharedInstance.presentAlert(withTitle: "Logout Error", message: "An error occurred when reloading student data: \(error!.userInfo[NSLocalizedDescriptionKey] as! String)", presenter: self)
            }
        }
    }
    
    // MARK: Table View Controller Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentLocationModel.sharedInstance.studentLocationList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentTableCell")!
        let student = StudentLocationModel.sharedInstance.studentLocationList[(indexPath as NSIndexPath).row]
    
        cell.textLabel?.text = student.fullName
        cell.imageView?.image = UIImage(named: "PinIcon")

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let app = UIApplication.shared
        let toOpen = StudentLocationModel.sharedInstance.studentLocationList[(indexPath as NSIndexPath).row].mediaURL
        if let url = URL(string: toOpen) {
            if UIApplication.shared.canOpenURL(url) {
                app.open(url, options: [:], completionHandler: nil)
            } else {
                AlertHelper.sharedInstance.presentAlert(withTitle: "Invalid URL", message: "Could not open this user's URL", presenter: self)
            }
        } else {
            AlertHelper.sharedInstance.presentAlert(withTitle: "Invalid URL", message: "Could not cast this user's URL as URL", presenter: self)
        }
    }
 
    // MARK: Lifecycle Methods
    
    //reload data every time the view appears
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        StudentLocationModel.sharedInstance.reloadStudentLocationList { (error) in
            if error != nil {
              AlertHelper.sharedInstance.presentAlert(withTitle: "Reload Error", message: "An error occurred when reloading student data: \(error!.userInfo[NSLocalizedDescriptionKey] as! String)", presenter: self)
            }
            self.refreshTable(self)
        }
    }
}
