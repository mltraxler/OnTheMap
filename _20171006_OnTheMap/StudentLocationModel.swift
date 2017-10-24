//
//  StudentLocationModel.swift
//  _20171006_OnTheMap
//
//  Created by Maria Traxler on 10/20/17.
//  Copyright © 2017 Maria Traxler. All rights reserved.
//

import Foundation

class StudentLocationModel {
    
    var studentLocationList = [StudentLocation]()
    var myStudentLocation: StudentLocation? = nil
    
    static let sharedInstance = StudentLocationModel()
    
    func reloadStudentLocationList(_ completionHandlerForReload: @escaping (_ error: NSError?) -> Void) {
        ClientCode.sharedInstance.getStudentLocations(filterOn: nil) { (studentLocations, error) in
            if error == nil, studentLocations != nil {
                StudentLocationModel.sharedInstance.studentLocationList = studentLocations!
                completionHandlerForReload(nil)
            } else {
                completionHandlerForReload(error)
            }
        }
    }
}
