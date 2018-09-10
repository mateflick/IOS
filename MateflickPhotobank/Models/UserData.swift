//
//  UserData.swift
//  MateflickPhotobank
//
//  Created by Panda on 7/4/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit
import SwiftyJSON

class UserData: NSObject {

    var firstName : String!
    var lastName : String!
    var company : String?
    var email : String!
    var birthday : String?
    var userId : String!
    var mobile : String!
    var token : String!
    var gender : String?
    var type : UserType!
    
    var followers : Int = 0
    var followings : Int = 0
    var photos : Int = 0
    var usedSpace : Int = 0
    var skills : Int = 0
    var likes : Int = 0
    var userImage : String = ""
   
    
    // initialize the User information
    init(_ data: JSON){
        /*
         {
         "UserType": 2,
         "AccountType": 0,
         "UsedSpace": 0,
         "Skills": 0,
         "PhotoCount": 0,
         "FollowersCount": 0,
         "FollowingsCount": 0,
         "CreatedAt": 1532082819913,
         "_id": "5b45e70da7b8e856214a5020",
         "Mobile": "+966551543042",
         "CompanyName": "tes2t",
         "FirstName": "Oleks",
         "SurName": "Daniel",
         "EmailAddress": "a@a.com",
         "DateOfBirth": "11-11-2011",
         "Token": "empty",
         "DeviceType": 1,
         "UserImage": "5b519bad3979ba7928de2769"
         }
         */
        
        self.userId         = data["_id"].stringValue
        self.firstName      = data["FirstName"].stringValue
        self.lastName       = data["SurName"].stringValue
        self.email          = data["EmailAddress"].stringValue
        self.mobile         = data["Mobile"].stringValue
        self.type           = UserType(rawValue: data["UserType"].intValue)
        self.birthday       = data["DateOfBirth"].string
        self.company        = data["CompanyName"].string
        self.token          = data["Token"].string
        
        self.followers      = data["FollowersCount"].intValue
        self.followings     = data["FollowingsCount"].intValue
        self.photos         = data["PhotoCount"].intValue
        self.skills         = data["Skills"].intValue
        if let imageId = data["UserImage"].string {
            self.userImage = imageId
        }
        self.usedSpace      = data["UsedSpace"].intValue
    }
}
