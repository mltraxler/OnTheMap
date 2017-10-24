//
//  AlertHelper.swift
//  _20171006_OnTheMap
//
//  Created by Maria Traxler on 10/16/17.
//  Copyright © 2017 Maria Traxler. All rights reserved.
//

import UIKit

// used https://discussions.udacity.com/t/am-i-not-following-the-mvc-pattern-if-i-put-ui-related-code-in-a-model/219273/2 as template
class AlertHelper {
    
    // MARK: Setup
    
    static let sharedInstance = AlertHelper()
    private init() {}
    
    // MARK: Types of alerts
    
    // Informational
    func presentAlert(withTitle title: String, message: String, presenter: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        presenter.present(alert, animated: true, completion: nil)
    }
    
    // Confirm (attempt to start process for) overwrite of existing location
    func presentOverwriteAlert(withTitle title: String, message: String, presenter: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Overwrite", style: .default, handler: {action in
            if presenter.classForCoder == MapViewController.self {
                presenter.performSegue(withIdentifier: "mapToAddPinSegue", sender: self)
            } else if presenter.classForCoder == StudentTableViewController.self {
                presenter.performSegue(withIdentifier: "tableToAddPinSegue", sender: self)

            }
        }))
        presenter.present(alert, animated: true, completion: nil)
    }
    
    // Send user back to previous VC
    func presentAlertBack(withTitle title: String, message: String, presenter: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Back", style: .default, handler: {action in
            let navigationController = presenter.navigationController
            navigationController?.popViewController(animated: true)
        }))
        presenter.present(alert, animated: true, completion: nil)
    }
}
