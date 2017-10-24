//
//  UdacityMethods.swift
//  _20171006_OnTheMap
//
//  Created by Maria Traxler on 10/8/17.
//  Copyright © 2017 Maria Traxler. All rights reserved.
//

import Foundation
import UIKit

extension ClientCode {
    
    // MARK: Authentication
    func authenticateWithUdacity(_ hostViewController: UIViewController, _ email: String, _ password: String, completionHandlerForAuth: @escaping (_ success: Bool, _ errorString: String?) -> Void) {

        sendUdacityAuthRequest(email, password) { (success, sessionID, userKey, errorString) in
            if success {
                self.sessionID = sessionID
                self.userKey = userKey
                
                //check if user has posted a student location before; if not, create stub dictionary with first and last name, and key
                //media URL, map string, and lat/long will be populated later
                //need to initialize myStudentLocation on login anyway for downstream functionality
                self.checkForExistingLocation() { (success, errorString) in
                    if !success {
                        completionHandlerForAuth(false, errorString)
                    } else {
                        completionHandlerForAuth(true, nil)
                    }
                }
            } else {
                completionHandlerForAuth(false, errorString)
            }
            //seems like this shouldn't be needed as all cases are covered above, but login doesn't work (never gets out of this chunk of code/transitions to next VC) without it...
            completionHandlerForAuth(success, errorString)
        }

    }
    
    func sendUdacityAuthRequest(_ email: String, _ password: String, _ completionHandlerForSessionID: @escaping (_ success: Bool, _ sessionId: String?, _ userKey: String?, _ errorString: String) -> Void) {
        
        let jsonBody = "{\"\(UdacityRequestParameterKeys.Udacity)\":{\"\(UdacityRequestParameterKeys.Username)\":\"\(email)\",\"\(UdacityRequestParameterKeys.Password)\":\"\(password)\"}}"
        
        let _ = taskForUdacityAuth(jsonBody: jsonBody) { (results, error) in
            
            if let error = error {
                if ((error.userInfo[NSLocalizedDescriptionKey] as? String)?.contains("a status code of 403"))!  {
                    completionHandlerForSessionID(false, nil, nil, "Login Failed (Incorrect Credentials).")
                } else {
                    //*** ??
                    print(error)
                    completionHandlerForSessionID(false, nil, nil, "Login Failed (Unknown Error).")
                }
            } else {
                if let sessionJSON = results?[ClientCode.UdacityResponseKeys.Session] as! [String:AnyObject]? {
                    if let sessionID = sessionJSON[ClientCode.UdacityResponseKeys.Id] as? String {
                        if let account = results?[ClientCode.UdacityResponseKeys.Account] as! [String:AnyObject]? {
                            if let userKey = account[ClientCode.UdacityResponseKeys.Key] as? String {
                                completionHandlerForSessionID(true, sessionID, userKey, "")
                            } else {
                                print("Could not find \(ClientCode.UdacityResponseKeys.Key) in \(results!)")
                                completionHandlerForSessionID(false, nil, nil, "Login Failed (SessionId - User Key not found).")
                            }
                        } else {
                            print("Could not find \(ClientCode.UdacityResponseKeys.Account) in \(results!)")
                            completionHandlerForSessionID(false, nil, nil, "Login Failed (SessionId - Account not found).")
                        }
                    } else {
                        print("Could not find \(ClientCode.UdacityResponseKeys.Id) in \(results!)")
                        completionHandlerForSessionID(false, nil, nil, "Login Failed (SessionId - ID not found).")
                    }
                } else {
                    print("Could not find \(ClientCode.UdacityResponseKeys.Session) in \(results!)")
                    completionHandlerForSessionID(false, nil, nil, "Login Failed (SessionId - Session not found).")
                } 
            }
        }
    }
    
    func deleteUdacitySession(completionHandlerForDeleteUdacitySession: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        let _ = taskForDeleteUdacitySession() { (results, error) in
            
            //don't need to set parameters or body for (this) DELETE call
            
            if let error = error {
                print(error)
                completionHandlerForDeleteUdacitySession(false, NSError(domain: "deleteUdacitySession", code: 1, userInfo: [NSLocalizedDescriptionKey: "Logout Failed (Unknown Error)."]))
            } else {
                if let sessionJSON = results?[ClientCode.UdacityResponseKeys.Session] as! [String:AnyObject]? {
                    if let _ = sessionJSON[ClientCode.UdacityResponseKeys.Id] as? String {
                        completionHandlerForDeleteUdacitySession(true, nil)
                    } else {
                        print("Could not find \(ClientCode.UdacityResponseKeys.Id) in \(results!)")
                        completionHandlerForDeleteUdacitySession(false, NSError(domain: "deleteUdacitySession", code: 1, userInfo: [NSLocalizedDescriptionKey: "Logout Failed (No session ID in results)."]))
                    }
                } else {
                    print("Could not find \(ClientCode.UdacityResponseKeys.Session) in \(results!)")
                    completionHandlerForDeleteUdacitySession(false, NSError(domain: "deleteUdacitySession", code: 1, userInfo: [NSLocalizedDescriptionKey: "Logout Failed (SessionId - Session)."]))
                }
            }
        }
    }
    
    func getMyUserInfo(key: String, _ completionHandlerForGetMyUserInfo: @escaping (_ results: [String: AnyObject]?, _ error: NSError?, _ firstName: String?, _ lastName: String?) -> Void) {
        let _  = taskForGETMethod(UdacityConstants.UdacityApiHost, UdacityConstants.UdacityApiPath, requestExtension: key, parameters: [:]) { (results, error) in
            if let error = error {
                print("error was \(error)")
                completionHandlerForGetMyUserInfo(nil, error, nil, nil)
            } else {
                if let result = (results as? [String: AnyObject]), let user = result[UdacityResponseKeys.User] {
                    if let firstName = user[UdacityResponseKeys.FirstName] as? String, let lastName = user[UdacityResponseKeys.LastName] as? String {
                        completionHandlerForGetMyUserInfo(result, nil, firstName, lastName)
                    } else {
                        completionHandlerForGetMyUserInfo(user as? [String : AnyObject], NSError(domain: "getMyUserInfo parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not find value for \(UdacityResponseKeys.FirstName) or \(UdacityResponseKeys.LastName) in response \(String(describing: results))"]), nil, nil)
                    }
                } else {
                    completionHandlerForGetMyUserInfo(nil, NSError(domain: "getMyUserInfo parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getMyUserInfo response"]), nil, nil)
                }
            }
        }
    }
    
    func checkForExistingLocation(_ completionHandlerForExistingLocation: @escaping(_ success: Bool, _ errorString: String?) -> Void) {
        let filter = "{\"uniqueKey\":\"\(userKey!)\"}"
        
        self.getStudentLocations(filterOn: filter) { (result, error) in
            if error == nil {
                if let result = result {
                    if result.count == 1 {
                        StudentLocationModel.sharedInstance.myStudentLocation = result[0]
                    } else if result.count == 0, let userKey = self.userKey {
                        self.getMyUserInfo(key: userKey) { (results, error, firstName, lastName) in
                            if firstName != nil && lastName != nil {
                                let dictionary: [String: AnyObject] = [ParseResponseKeys.FirstName: firstName as AnyObject, ParseResponseKeys.LastName: lastName as AnyObject, ParseResponseKeys.UniqueKey: userKey as AnyObject, ParseResponseKeys.Latitude: 0 as AnyObject, ParseResponseKeys.Longitude: 0 as AnyObject, ParseResponseKeys.MediaURL: "" as AnyObject, ParseResponseKeys.MapString: "" as AnyObject]
                                StudentLocationModel.sharedInstance.myStudentLocation = StudentLocation(dictionary: dictionary)
                                completionHandlerForExistingLocation(true, nil)
                            } else {
                                completionHandlerForExistingLocation(false, "No first or last name was returned for this student.")
                                 //alternatively, could enter default name and pass in "true" in the completion handler above
                                
                            }
                        }
                    } else {
                        completionHandlerForExistingLocation(false, "Error returned on getStudentLocations: \(String(describing: error))")
                    }
                } else {
                    completionHandlerForExistingLocation(false, "No results returned for getStudentLocations")
                }
            } else {
                completionHandlerForExistingLocation(false, "Error returned on getStudentLocations: \(String(describing: error))")
            }
        }
    }
    
    // MARK: PARSE methods
    
    func getStudentLocations(filterOn: String?, _ completionHandlerForStudentLocations: @escaping (_ result: [StudentLocation]?, _ error: NSError?) -> Void) {
        
        var parameters = [UdacityRequestParameterKeys.Limit: UdacityRequestParameterValues.Limit,
                          UdacityRequestParameterKeys.Skip: UdacityRequestParameterValues.Skip,
                          UdacityRequestParameterKeys.Order: UdacityRequestParameterValues.Order] as [String: AnyObject]
        
        if let filterCriteria = filterOn?.utf8 {
            parameters[UdacityRequestParameterKeys.Filter] = filterCriteria as AnyObject
        }
        
        let _ = taskForGETMethod(UdacityConstants.ParseApiHost, UdacityConstants.ParseApiPath, requestExtension: "", parameters: parameters) { (results, error) in
            
            if error != nil {
                completionHandlerForStudentLocations(nil, NSError(domain: "getStudentLocations", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error when trying to download list of students"]))
            } else {
                if let results = results?[ParseResponseKeys.Results] as? [[String:AnyObject]] {
                    let studentLocations = StudentLocation.studentLocationsFromResults(results)
                        completionHandlerForStudentLocations(studentLocations, nil)
                } else {
                    completionHandlerForStudentLocations(nil, NSError(domain: "getStudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocations"]))
                }
            }
        }
    }
    
    func postNewStudentLocation(_ student: StudentLocation, _ completionHandlerForNewStudentLocation: @escaping (_ result: [String: AnyObject]?, _ error: NSError?) -> Void) {
        
        let studentAsHttpBody = StudentLocation.studentLocationAsHttpBody(student)
        let filter = "{\"uniqueKey\":\"\(student.uniqueKey)\"}"
        
        ClientCode.sharedInstance.getStudentLocations(filterOn: filter) { (studentLocations, error) in
            if let error = error {
                print(error)
                completionHandlerForNewStudentLocation(nil, NSError(domain: "postNewStudentLocation", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error on refreshing student list when creating student location"]))
            } else {
                if (studentLocations?.count)! > 0 {
                    //this should never happen since addUrlViewController checks for objectID, which is populated on POST, or on login if it already exists
                    completionHandlerForNewStudentLocation(nil, NSError(domain: "postNewStudentLocation", code: 0, userInfo: [NSLocalizedDescriptionKey: "Cannot POST - location for this student already exists"]))
                } else {
                    let _ = self.taskForPOSTMethod(UdacityConstants.ParseApiHost, UdacityConstants.ParseApiPath, parameters: [:], jsonBody: studentAsHttpBody) { (results, error) in
                        if let error = error {
                            completionHandlerForNewStudentLocation(nil, error)
                        } else {
                            if let result = results as? [String:AnyObject] {
                                if StudentLocationModel.sharedInstance.myStudentLocation != nil {
                                    StudentLocationModel.sharedInstance.myStudentLocation!.objectId = result["objectId"] as? String
                                    completionHandlerForNewStudentLocation(result, nil)
                                } else {
                                    completionHandlerForNewStudentLocation(nil, NSError(domain: "postNewStudentLocation", code: 0, userInfo: [NSLocalizedDescriptionKey: "myStudentLocation was never initialized"]))
                                }
                            } else {
                                completionHandlerForNewStudentLocation(nil, NSError(domain: "postNewStudentLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postNewStudentLocation response"]))
                            }
                        }
                    }
                }
            }
        }
    }
    
    func updateStudentLocation(_ student: StudentLocation, _ completionHandlerForUpdateStudentLocation: @escaping (_ result: [String:AnyObject]?, _ error: NSError?) -> Void) {
        let studentAsHttpBody = StudentLocation.studentLocationAsHttpBody(student)
        
        let filter = "{\"uniqueKey\":\"\(student.uniqueKey)\"}"
        
        ClientCode.sharedInstance.getStudentLocations(filterOn: filter) { (studentLocations, error) in
            if let error = error {
                print(error)
                completionHandlerForUpdateStudentLocation(nil, NSError(domain: "updateStudentLocation", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error on refreshing student list when updating student location"]))
            } else {
                //neither of these first two cases should ever happen since count is already getting checked in addPinViewController which determines whether POST or PUT should get called
                if (studentLocations?.count)! == 0 {
                    completionHandlerForUpdateStudentLocation(nil, NSError(domain: "updateStudentLocation", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot PUT - no locations exist for this student"]))
                } else if (studentLocations?.count)! > 1 {
                    completionHandlerForUpdateStudentLocation(nil, NSError(domain: "updateStudentLocation", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot PUT - more than one location exists for this student"]))
                } else {
                    let _ = self.taskForPUTMethod(UdacityConstants.ParseApiHost, UdacityConstants.ParseApiPath, studentLocations![0].objectId!, parameters: [:], jsonBody: studentAsHttpBody) { (results, error) in
                        if let error = error {
                            completionHandlerForUpdateStudentLocation(nil, error)
                        } else {
                            //might not actually need this check as we don't use updatedAt or any of the contents
                            if let _ = results as? [String:AnyObject] {
                                //no need to update objectId because it does not change
                                completionHandlerForUpdateStudentLocation(results as? [String : AnyObject], nil)
                            } else {
                                completionHandlerForUpdateStudentLocation(nil, NSError(domain: "updateStudentLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse updateStudentLocation response"]))
                            }
                        }
                    }
                }
            }
        }
    }
    
    func deleteStudentLocation (_ student: String, _ completionHandlerForDeleteLocation: @escaping (_ results: [String:AnyObject]?, _ error: NSError?) -> Void) {
        let _  = taskForDelete(UdacityConstants.ParseApiHost, UdacityConstants.ParseApiPath, student) { (results, error) in
            if let error = error {
                completionHandlerForDeleteLocation(nil, error)
            } else {
                if let _ = results as? [String: AnyObject] {
                    completionHandlerForDeleteLocation(results as? [String: AnyObject], nil)
                } else {
                    completionHandlerForDeleteLocation(nil, NSError(domain: "deleteNewStudentLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse deleteStudentLocation response"]))
                }
            }
        }
    }
}


