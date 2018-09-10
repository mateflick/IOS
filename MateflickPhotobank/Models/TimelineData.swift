//
//  TimelineData.swift
//  MateflickPhotobank
//
//  Created by Panda on 7/11/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit
import SwiftyJSON

class TimelineData: NSObject {
/*
    "_id": "5b45c0ac89449d505c2c2c46",
    "FileId": "5b45c0aa89449d505c2c2c44",
    "CreatedAt": "2018-07-11T08:32:44.102Z",
    "userInfo": {
        "_id": "5b41aa75a077d47a2967a65e",
        "UserType": 2,
        "FirstName": "tes2t",
        "SurName": "user2",
        "EmailAddress": "a@a.com",
        "UserImage": "5b45c3cf89449d505c2c2c47"
    }
 */
        
    var id : String!
    var fileId : String = ""
    var createdDate : String!
    var userInfo : TimelineUserInfo!
    
    init(_ data : JSON){
        id          = data["_id"].stringValue
        if let coverImageId = data["FileId"].string {
            fileId = coverImageId
        }
        createdDate = data["CreatedAt"].stringValue
        userInfo = TimelineUserInfo(data["userInfo"])
    }
}

class TimelineUserInfo : NSObject {
    var userId : String!
    var firstname : String!
    var surname : String!
    var emailAddress : String!
    var userImage : String = ""
    var userType : UserType!
    
    
    init(_ data: JSON){
        userId          = data["_id"].stringValue
        firstname       = data["FirstName"].stringValue
        surname         = data["SurName"].stringValue
        emailAddress    = data["EmailAddress"].stringValue
        if let imageId  = data["UserImage"].string {
            userImage = imageId
        }
        userType        = UserType(rawValue: data["UserType"].intValue)
    }
}
