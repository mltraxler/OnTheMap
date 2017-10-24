//
//  AddUrlViewController.swift
//  _20171006_OnTheMap
//
//  Created by Maria Traxler on 10/18/17.
//  Copyright © 2017 Maria Traxler. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class AddUrlViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var urlQuestionLabel: UILabel!
    @IBOutlet weak var mediaUrlTextField: UITextField!
    @IBOutlet weak var addLocationMapView: MKMapView!
    @IBOutlet var backgroundView: UIView!
    var indicator = UIActivityIndicatorView()
    private let locationManager = CLLocationManager()
    
    lazy var geocoder = CLGeocoder()
    
    // MARK: Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLocationMapView.delegate = self
        mediaUrlTextField.delegate = self
        mediaUrlTextField.keyboardType = .URL
        geocodeLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: Core Methods
    
    @IBAction func submitRequest(_ sender: Any) {
        mediaUrlTextField.resignFirstResponder()
        //don't need to geocode here because it has already been done in order to put the pin on the map
        if checkMediaUrl(urlString: mediaUrlTextField.text) {
            if let studentLocationToSend = StudentLocationModel.sharedInstance.myStudentLocation {
                //necessary to validate that all other fields are valid before posting as well?
                attemptToSend(studentLocationToSend)
            } else {
                AlertHelper.sharedInstance.presentAlert(withTitle: "Data error", message: "The local student location could not be found. Check that correct data is saved in myStudentLocation.", presenter: self)
            }
        }
        //the "else" cases for checkMediaUrl are actually handled in that method itself
        
        //the map/table will automatically update with new information (though it might take a bit to load) - doesn't need to be handled here
    }
    
    func attemptToSend(_ student: StudentLocation) {
        if student.objectId == nil {
            ClientCode.sharedInstance.postNewStudentLocation(student) { (result, error) in
                if error == nil {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    AlertHelper.sharedInstance.presentAlert(withTitle: "POST error", message: "There was an error when trying to create a new location: \(error!.userInfo["NSLocalizedDescription"]!)", presenter: self)
                }
            }
        } else {
            ClientCode.sharedInstance.updateStudentLocation(student) { (result, error) in
                if error == nil {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    AlertHelper.sharedInstance.presentAlert(withTitle: "PUT error", message: "There was an error when trying to update a location: \(error!.userInfo["NSLocalizedDescription"]!)", presenter: self)
                }
            }
        }
    }
    
    // MARK: Data Validation Methods
    // could expand if needed
    
    func checkMediaUrl(urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(url) {
                    StudentLocationModel.sharedInstance.myStudentLocation?.mediaURL = urlString
                    return true
                } else {
                    AlertHelper.sharedInstance.presentAlert(withTitle: "Invalid URL", message: "The URL you entered was invalid and could not be opened.", presenter: self)
                    return false
                }
            }
        } else {
            AlertHelper.sharedInstance.presentAlert(withTitle: "No URL", message: "No URL was entered. Please enter a URL.", presenter: self)
            return false
        }
        return false
    }
    
    // MARK: Geocoding Methods
    // used https://cocoacasts.com/forward-and-reverse-geocoding-with-clgeocoder-part-1/ as template
    
    func geocodeLocation() {
        if let student = StudentLocationModel.sharedInstance.myStudentLocation {
            
            showActivityIndicator(view: view)
            geocoder.geocodeAddressString(student.mapString) { (placemarks, error) in
                self.processGeocodeResponse(withPlacemarks: placemarks, error: error)
                
            }
            //this call is what was causing the alerts to auto-dismiss - see https://stackoverflow.com/questions/41644622/uialertcontroller-panel-disappears-before-user-can-respond
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
            }
        } else {
            AlertHelper.sharedInstance.presentAlertBack(withTitle: "Invalid Address", message: "The address for this user is invalid. Please enter a valid address on the preceding screen.", presenter: self)
        }
    }
    
    func processGeocodeResponse(withPlacemarks: [CLPlacemark]?, error: Error?) {
        if error != nil {
            AlertHelper.sharedInstance.presentAlertBack(withTitle: "Invalid Location", message: "The location you entered could not be geocoded.", presenter: self)
            //return
        } else {
            if let placemarks = withPlacemarks {
                if placemarks.count == 1 {
                    if let coordinate = placemarks[0].location?.coordinate {
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = coordinate
                        StudentLocationModel.sharedInstance.myStudentLocation?.coordinate = coordinate
                        StudentLocationModel.sharedInstance.myStudentLocation?.latitude = coordinate.latitude
                        StudentLocationModel.sharedInstance.myStudentLocation?.longitude = coordinate.longitude
                        DispatchQueue.main.async {
                            self.addLocationMapView.addAnnotation(annotation)
                            let span = MKCoordinateSpanMake(0.075, 0.075)
                            let region = MKCoordinateRegion(center: coordinate, span: span)
                            self.addLocationMapView.setRegion(region, animated: true)
                        }
                    }
                } else {
                    //not sure if this is likely/possible
                    AlertHelper.sharedInstance.presentAlert(withTitle: "Too Many Placemarks", message: "Too many placemarks were received for the location string entered.", presenter: self)
                }
            } else {
                AlertHelper.sharedInstance.presentAlert(withTitle: "No Placemarks", message: "No placemarks were returned for the address given", presenter: self)
                return
            }
        }
    }
    
    //used https://coderwall.com/p/su1t1a/ios-customized-activity-indicator-with-swift as template
    func showActivityIndicator(view: UIView) {
        indicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        indicator.center = view.center
        indicator.hidesWhenStopped = true
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(indicator)
        indicator.startAnimating()
    }
    
    // MARK: MKMapViewDelegate Methods
    
    //stripped-down version of what's in MapViewController (minus the callout-related code)
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    //no need to implement the "tap" MKMapViewDelegate method since user is not actually tapping on anything in this view
    
    // MARK: TextFieldDelegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
 }
