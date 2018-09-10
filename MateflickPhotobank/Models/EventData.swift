//
//  EventData.swift
//  MateflickPhotobank
//
//  Created by Panda on 7/8/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit
import SwiftyJSON

class EventData: NSObject {
/*
     {
     "Status": 1,
     "_id": "5b4232124e8a507bcf9da8e0",
     "UserId": "5b41aa75a077d47a2967a65e",
     "Location": "New York, USA",
     "EventDate": "2018-07-12",
     "Description": "This is the test event",
     "Name": "First event",
     "CreatedAt": "2018-07-08T15:47:30.361Z"
     }
 */
    var eventId : String!
    var userId : String!
    var name : String!
    var location : String!
    var eventDescription : String!
    var createdDate : String!
    var coverImageId : String = ""
    
    init(_ data:JSON){
        eventId     = data["_id"].stringValue
        userId      = data["UserId"].stringValue
        name        = data["Name"].stringValue
        location    = data["Location"].stringValue
        eventDescription = data["Description"].stringValue
        createdDate = data["CreatedAt"].stringValue
        
        if let coverImage = data["CoverImage"].string {
            coverImageId = coverImage
        }
    }
}
