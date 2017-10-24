//
//  MapViewController.swift
//  _20171006_OnTheMap
//
//  Created by Maria Traxler on 10/6/17.
//  Copyright © 2017 Maria Traxler. All rights reserved.
//

import UIKit
import MapKit

/**
 * This view controller demonstrates the objects involved in displaying pins on a map.
 *
 * The map is a MKMapView.
 * The pins are represented by MKPointAnnotation instances.
 *
 * The view controller conforms to the MKMapViewDelegate so that it can receive a method
 * invocation when a pin annotation is tapped. It accomplishes this using two delegate
 * methods: one to put a small "info" button on the right side of each pin, and one to
 * respond when the "info" button is tapped.
 */

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: IBActions
    
    @IBAction func addPinButton(_ sender: Any) {
        if let myStudentLocation = StudentLocationModel.sharedInstance.myStudentLocation, let _ = myStudentLocation.objectId {
            AlertHelper.sharedInstance.presentOverwriteAlert(withTitle: "Pin Already Exists", message: "A pin already exists for this user. Do you want to overwrite it?", presenter: self)
        } else {
            self.performSegue(withIdentifier: "mapToAddPinSegue", sender: self)
        }
    }
    
    @IBAction func reloadMap(_ sender: Any) {
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        
        StudentLocationModel.sharedInstance.reloadStudentLocationList { (error) in
            if error != nil {
                AlertHelper.sharedInstance.presentAlert(withTitle: "Reload Error", message: "An error occurred when reloading student data: \(error!.userInfo[NSLocalizedDescriptionKey] as! String)", presenter: self)
            }
            self.getStudentsForMap()
        }
    }
    
    @IBAction func logOut(_sender: Any) {
        ClientCode.sharedInstance.deleteUdacitySession() { success, error in
            if success {
                self.dismiss(animated: true, completion: nil)
            } else {
                AlertHelper.sharedInstance.presentAlert(withTitle: "Logout Error", message: (error!.userInfo[NSLocalizedDescriptionKey] as! String), presenter: self)
            }
        }
    }
    
    // MARK: Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        getStudentsForMap()
    }
    
    //reload data every time the view appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        
        StudentLocationModel.sharedInstance.reloadStudentLocationList { (error) in
            if error == nil {
                self.getStudentsForMap()
            } else {
                AlertHelper.sharedInstance.presentAlert(withTitle: "Reload Error", message: "An error occurred when reloading student data: \(error!.userInfo[NSLocalizedDescriptionKey] as! String)", presenter: self)
            }
        }
    }
    
    func getStudentsForMap() -> Void {
        
        // Majority of this code (including comments) taken from PinSample app
        
        // We will create an MKPointAnnotation for each student location in the list stored in
        // the model. The point annotations will be stored in this array, and then provided to
        // the map view.
        
        var annotations = [MKPointAnnotation]()
        
        // We are using the student locations to create map annotations.
        
        for studentLocation in StudentLocationModel.sharedInstance.studentLocationList {
        
            // Notice that the float values are being used to create CLLocationDegree values.
            // This is a version of the Double type.
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = studentLocation.coordinate
            let fullName = studentLocation.fullName
            let mediaURL = studentLocation.mediaURL
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = fullName
            annotation.subtitle = mediaURL
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        
        DispatchQueue.main.async {
            self.mapView.addAnnotations(annotations)
        }
    }
    
    // MARK: - MKMapViewDelegate [mostly from PinSample app except link-opening code]
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                if let url = URL(string: toOpen) {
                    if UIApplication.shared.canOpenURL(url) {
                        app.open(url, options: [:], completionHandler: nil)
                    } else {
                        AlertHelper.sharedInstance.presentAlert(withTitle: "Invalid URL", message: "Could not open this user's URL", presenter: self)
                    }
                } else {
                    AlertHelper.sharedInstance.presentAlert(withTitle: "Invalid URL", message: "Could not cast this user's URL to URL", presenter: self)
                }
            } else {
                AlertHelper.sharedInstance.presentAlert(withTitle: "Invalid URL", message: "Could not open subtitle for this annotation", presenter: self)
            }
        }
    }
}

