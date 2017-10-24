//
//  Constants.swift
//  _20171006_OnTheMap
//
//  Created by Maria Traxler on 10/8/17.
//  Copyright © 2017 Maria Traxler. All rights reserved.
//

import Foundation

extension ClientCode {
    
    struct UdacityConstants {
        static let APIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let AppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        
        static let ApiScheme = "https"
        static let ParseApiHost = "parse.udacity.com"
        static let ParseApiPath = "/parse/classes/StudentLocation/"
        static let UdacityApiHost = "www.udacity.com"
        static let UdacityApiPath = "/api/users/"
        static let UdacityAuthorizationURL = "https://www.udacity.com/api/session"
        static let UdacityHomePageURL = "https://www.udacity.com"
    }
    
    struct UdacityMethods {
        static let UdacityAuth = UdacityConstants.UdacityAuthorizationURL
        //not sure if I need this since I really only seem to be using the StudentLocation API
    }
    
    struct UdacityRequestParameterKeys {
        static let Limit = "limit"
        static let Skip = "skip"
        static let Order = "order"
        static let Filter = "where"
        
        //JSON Body Keys
        static let Username = "username"
        static let Password = "password"
        static let Udacity = "udacity"
    }
    
    struct UdacityRequestParameterValues {
        static let Limit = 100
        static let Skip = 0
        static let Order = "-updatedAt"
    }
    
    struct ParseResponseKeys {
        //In body of response to POST/PUT /StudentLocation
        static let CreatedAt = "createdAt"
        static let UpdatedAt = "updatedAt"
        static let ObjectId = "objectId"
        
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let UniqueKey = "uniqueKey"
        
        static let Results = "results"
    }
    
    struct UdacityResponseKeys {
        static let FirstName = "first_name"
        static let LastName = "last_name"
        
        static let Session = "session"
        static let Id = "id"
        static let Account = "account"
        static let Key = "key"
        
        static let Udacity = "udacity"
        static let User = "user"
    }
    
}
