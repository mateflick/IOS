//
//  MyFriendData.swift
//  MateflickPhotobank
//
//  Created by Panda on 7/23/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit
import SwiftyJSON

class MyFriendData: NSObject {
    /*
     {
     "_id": "5b54bd7ca0a78130cb1e50e0",
     "FollowerId": "5b471888f65e8b6189079f3b",
     "UserId": "5b45e70da7b8e856214a5020",
     "CreatedAt": 1532280188009,
     "userinfo": {
         "_id": "5b471888f65e8b6189079f3b",
         "UserType": 1,
         "SurName": "Achichi",
         "FirstName": "Israel",
         "EmailAddress": "iam1achie@gmail.com"
     },
     "follower": true
     }
    */
    
    var id:String!
    var followerId : String!
    var userId : String!
    var createdDate : String!
    var follower : Bool!
    var userInfo : TimelineUserInfo!
    
    init(_ item:JSON) {
        self.id             = item["_id"].stringValue
        self.followerId     = item["FollowerId"].stringValue
        self.userId         = item["UserId"].stringValue
        self.createdDate    = item["CreatedAt"].stringValue
        self.userInfo       = TimelineUserInfo(item["userinfo"])
        self.follower       = item["follower"].boolValue
    }
}
