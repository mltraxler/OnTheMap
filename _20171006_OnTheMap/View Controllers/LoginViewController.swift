//
//  LoginViewController.swift
//  _20171006_OnTheMap
//
//  Created by Maria Traxler on 10/6/17.
//  Copyright © 2017 Maria Traxler. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: IBActions
    
    @IBAction func loginButton(_ sender: Any) {
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        
        if emailTextField.text == "" || passwordTextField.text == "" {
            AlertHelper.sharedInstance.presentAlert(withTitle: "Login Error", message: "Please provide both email and password", presenter: self)
            return
        }
        
        if let email = emailTextField.text, let password = passwordTextField.text {
            ClientCode.sharedInstance.authenticateWithUdacity(self, email, password) {
                (success, errorString) in
                if success {
                    DispatchQueue.main.async {
                        self.view.frame.origin.y = 0
                    }
                    self.completeLogin()
                } else {
                    AlertHelper.sharedInstance.presentAlert(withTitle: "Login Error", message: "There was an error when trying to authenticate: \(errorString!)", presenter: self)
                }
            }
        } else {
            AlertHelper.sharedInstance.presentAlert(withTitle: "Login Error", message: "One or both of the email or password fields were blank. Please provide both email and password.", presenter: self)
        }
    }
    
    func completeLogin() {
        getAllStudents()
        let controller = storyboard!.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
        present(controller, animated: true, completion: nil)
    }
    
    func getAllStudents() {
        ClientCode.sharedInstance.getStudentLocations(filterOn: nil) { (studentLocations, error) in
            if error == nil, studentLocations != nil {
                StudentLocationModel.sharedInstance.studentLocationList = studentLocations!
            } else {
                AlertHelper.sharedInstance.presentAlert(withTitle: "Locations Error", message: "An error occurred when trying to download student locations: \(String(describing: error))", presenter: self)
            }
        }
    }
    
    @IBAction func signUp(_ sender: Any) {
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        
        let app = UIApplication.shared
        let toOpen = URL(string: ClientCode.UdacityConstants.UdacityHomePageURL)
        app.open(toOpen!, options: [:], completionHandler: nil)
    }
    
    // MARK: Lifecycle Methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        subscribeToKeyboardNotifications()
        emailTextField.keyboardType = .emailAddress
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: Keyboard Notifications
    
    // apparently Swift 4 https://forums.developer.apple.com/thread/79183 requires the @objc for items that are referenced via selector?
    @objc func keyboardWillShow(_ notification:Notification) {
        if (emailTextField.isEditing || passwordTextField.isEditing) {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        if !(emailTextField.isEditing || passwordTextField.isEditing) {
            view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
}











