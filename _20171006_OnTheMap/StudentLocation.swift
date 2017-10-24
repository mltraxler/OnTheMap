//
//  StudentLocation.swift
//  _20171006_OnTheMap
//
//  Created by Maria Traxler on 10/9/17.
//  Copyright © 2017 Maria Traxler. All rights reserved.
//

import Foundation
import CoreLocation

struct StudentLocation {
    
    // MARK: Properties
    
    var firstName: String
    var lastName: String
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var mapString: String
    var mediaURL: String
    var uniqueKey: String
    var objectId: String?
   
    var fullName: String
    var coordinate: CLLocationCoordinate2D
    
    // MARK: Init
    
    // construct a StudentLocation from a dictionary
    init(dictionary: [String:AnyObject]) {
        if let first = dictionary[ClientCode.ParseResponseKeys.FirstName] as? String, let last = dictionary[ClientCode.ParseResponseKeys.LastName] as? String {
            firstName = first
            lastName = last
            fullName = first + " " + last
        } else {
            firstName = ""
            lastName = ""
            fullName = "(first or last name cannot be converted to string)"
        }
        
        if let lat = dictionary[ClientCode.ParseResponseKeys.Latitude] as? CLLocationDegrees, let long = dictionary[ClientCode.ParseResponseKeys.Longitude] as? CLLocationDegrees {
            latitude = lat
            longitude = long
        } else {
            latitude = 0
            longitude = 0
        }
        
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        if let map = dictionary[ClientCode.ParseResponseKeys.MapString] as? String {
            mapString = map
        } else {
            mapString = "(bad map string)"
        }
        
        if let media = dictionary[ClientCode.ParseResponseKeys.MediaURL] as? String {
            mediaURL = media
        } else {
            mediaURL = "(not a good media url)"
        }
        
        if dictionary[ClientCode.ParseResponseKeys.UniqueKey] as? String == "userKey" {
            uniqueKey = ClientCode.sharedInstance.userKey!
        } else if let key = dictionary[ClientCode.ParseResponseKeys.UniqueKey] as? String {
            uniqueKey = key
        } else {
            uniqueKey = "(mystery keyyyy)"
        }
        
        if let object = dictionary[ClientCode.ParseResponseKeys.ObjectId] as? String {
            objectId = object
        } else {
            objectId = nil
        }
    }
    
    // MARK: Convenience Methods
    
    // create array of StudentLocations from results
    static func studentLocationsFromResults(_ results: [[String: Any]]) -> [StudentLocation] {
        var studentLocations = [StudentLocation]()
        
        for result in results {
            studentLocations.append(StudentLocation(dictionary: result as [String : AnyObject]))
        }
        
        return studentLocations
    }
    
    //convert StudentLocation to string
    static func studentLocationAsHttpBody(_ student: StudentLocation) -> String {
        let string = "{\"uniqueKey\": \"\(student.uniqueKey)\", \"firstName\": \"\(student.firstName)\", \"lastName\": \"\(student.lastName)\",\"mapString\": \"\(student.mapString)\", \"mediaURL\": \"\(student.mediaURL)\",\"latitude\": \(student.latitude), \"longitude\": \(student.longitude)}"

        return string
    }
    
}

