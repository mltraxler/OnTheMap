//
//  ClientCode.swift
//  _20171006_OnTheMap
//
//  Created by Maria Traxler on 10/8/17.
//  Copyright © 2017 Maria Traxler. All rights reserved.
//

import UIKit

class ClientCode: NSObject {

    // MARK: Properties
    
    var session = URLSession.shared
    
    var sessionID: String? = nil
    var userKey: String? = nil
    
    // MARK: PARSE Tasks
    
    func taskForGETMethod(_ host: String, _ path: String, requestExtension: String, parameters: [String:AnyObject], completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let parametersWithApiKey = parameters
        
        var request = URLRequest(url: urlFromParameters(host, path, parametersWithApiKey, withPathExtension: requestExtension))
        request.addValue(UdacityConstants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(UdacityConstants.APIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if let errorString = self.errorFoundIn(data: data, response: response, error: error) {
                let userInfo = [NSLocalizedDescriptionKey : errorString]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            } else if let data = data {
                if host == UdacityConstants.UdacityApiHost {
                    let range = Range(5..<data.count)
                    let newData = data.subdata(in: range)
                    
                    self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForGET)
                } else {
                    self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
                }
            }
            
            /*
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            //self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
            */
        }
        
        task.resume()
        
        return task
    }
    
    func taskForPOSTMethod(_ host: String, _ path: String, parameters: [String:AnyObject], jsonBody: String, completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let parametersWithApiKey = parameters
        
        var request = URLRequest(url: urlFromParameters(host, path, parametersWithApiKey, withPathExtension: ""))
        request.httpMethod = "POST"
        request.addValue(UdacityConstants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(UdacityConstants.APIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if let errorString = self.errorFoundIn(data: data, response: response, error: error) {
                let userInfo = [NSLocalizedDescriptionKey : errorString]
                completionHandlerForPOST(nil, NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            } else if let data = data {
                self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPOST)
            }
            
            /*
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(nil, NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
 
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPOST)
            */
        }
        
        task.resume()
        
        return task
    }
    
    func taskForPUTMethod(_ host: String, _ path: String, _ studentKey: String, parameters: [String:AnyObject], jsonBody: String, completionHandlerForPUT: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let parametersWithApiKey = parameters
        
        var request = URLRequest(url: urlFromParameters(host, path, parametersWithApiKey, withPathExtension: studentKey))
        request.httpMethod = "PUT"
        request.addValue(UdacityConstants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(UdacityConstants.APIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if let errorString = self.errorFoundIn(data: data, response: response, error: error) {
                let userInfo = [NSLocalizedDescriptionKey : errorString]
                completionHandlerForPUT(nil, NSError(domain: "taskForPUTMethod", code: 1, userInfo: userInfo))
            } else if let data = data {
                self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPUT)
            }
            
            /*
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPUT(nil, NSError(domain: "taskForPUTMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
 
            
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPUT)
            */
        }
        
        task.resume()
        
        return task
    }
    
    func taskForDelete(_ host: String, _ path: String, _ objectToDelete: String, completionHandlerForDELETE: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
            
        let parametersWithApiKey = [String:AnyObject]()
            
        var request = URLRequest(url: urlFromParameters(host, path, parametersWithApiKey, withPathExtension: objectToDelete))
        request.httpMethod = "DELETE"
        request.addValue(UdacityConstants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(UdacityConstants.APIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if let errorString = self.errorFoundIn(data: data, response: response, error: error) {
                let userInfo = [NSLocalizedDescriptionKey : errorString]
                completionHandlerForDELETE(nil, NSError(domain: "taskForDELETEMethod", code: 1, userInfo: userInfo))
            } else if let data = data {
                self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForDELETE)
            }
            
            /*
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForDELETE(nil, NSError(domain: "taskForDELETEMethod", code: 1, userInfo: userInfo))
            }
                
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
                
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
                
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
                
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForDELETE)
            */
            }
            
        task.resume()
            
        return task
    }
    
    // MARK: Udacity Auth Tasks

    func taskForUdacityAuth(jsonBody: String, completionHandlerForAuth: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        //no parameters needed for auth
        
        let authUrl = URL(string: UdacityMethods.UdacityAuth)!
        var request = URLRequest(url: authUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(UdacityConstants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(UdacityConstants.APIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if let errorString = self.errorFoundIn(data: data, response: response, error: error) {
                let userInfo = [NSLocalizedDescriptionKey : errorString]
                completionHandlerForAuth(nil, NSError(domain: "taskForUdacityAuth", code: 1, userInfo: userInfo))
            } else if let data = data {
                let range = Range(5..<data.count)
                let newData = data.subdata(in: range)
                
                self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForAuth)
            }
            
            /*
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForAuth(nil, NSError(domain: "taskForUdacityAuth", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                if (response as? HTTPURLResponse)?.statusCode == 403 {
                    sendError("Your request returned a status code of 403")
                    return
                } else {
                    sendError("Your request returned a status code other than 2xx or 403!: \(String(describing: response))")
                    return
                }
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range) /* subset response data! */
            
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForAuth)
            */
        }
        
        task.resume()
        
        return task
    }
    
    func taskForDeleteUdacitySession(completionHandlerForDeleteUdacitySession: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        //no need to set parameters for this particular request - covered by cookie
        
        let authUrl = URL(string: UdacityMethods.UdacityAuth)!
        var request = URLRequest(url: authUrl)
        request.httpMethod = "DELETE"
        request.addValue(UdacityConstants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(UdacityConstants.APIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        //cookie particulars, from Udacity: https://classroom.udacity.com/nanodegrees/nd003/parts/99f2246b-fb9e-41a9-9834-3b7db87f7628/modules/0e6213b2-bc78-490c-a967-f67fa258ed12/lessons/3071699113239847/concepts/f1858f50-76e4-40ee-9309-d597c70d0619
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if let errorString = self.errorFoundIn(data: data, response: response, error: error) {
                let userInfo = [NSLocalizedDescriptionKey : errorString]
                completionHandlerForDeleteUdacitySession(nil, NSError(domain: "taskForDeleteUdacitySession", code: 1, userInfo: userInfo))
            } else if let data = data {
                let range = Range(5..<data.count)
                let newData = data.subdata(in: range)
                
                self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForDeleteUdacitySession)
            }

            /*
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForDeleteUdacitySession(nil, NSError(domain: "taskForDeleteUdacitySession", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range) /* subset response data! */
            
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForDeleteUdacitySession)
            */
        }
        
        task.resume()
        
        return task
    }

    // MARK: Convenience methods
    // remainder of code here taken/adapted from TheMovieManager app provided by Udacity
    
    //abstracted this into a single function instead of copying code across requests
    //does not necessarily provide the most user-friendly error text at times...
    func errorFoundIn(data: Data?, response: URLResponse?, error: Error?) -> String? {
    
        /* GUARD: Was there an error? */
        guard (error == nil) else {
            return "There was an error with your request: \(error!)"
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode == 403 {
                return "Your request returned a status code of 403"
            } else {
                return "Your request returned a status code other than 2xx or 403"
            }
        }
        
        /* GUARD: Was there any data returned? */
        guard let _: Data = data else {
            return "No data was returned by the request!"
        }
        
        return nil
    }
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    //create URL from parameters
    private func urlFromParameters(_ host: String, _ path: String, _ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL {
        var components = URLComponents()
        components.scheme = UdacityConstants.ApiScheme
        components.host = host
        components.path = path + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        return components.url!
    }
    
    // MARK: Shared Instance
    
    static let sharedInstance = ClientCode()
}
