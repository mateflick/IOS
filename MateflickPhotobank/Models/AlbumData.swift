//
//  AlbumData.swift
//  MateflickPhotobank
//
//  Created by Panda on 7/7/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit
import SwiftyJSON

class AlbumData: NSObject {
/*
    {
    "Status": 1,
    "_id": "5b3fdba16565be4367e968f8",
    "UserId": "5b3c94e50aefbf71f9a2b9c5",
    "Title": "test",
    "Location": "No Location",
    "Event": "No Event",
    "Description": "No description",
    "CreatedAt": "2018-07-06T21:14:09.323Z"
    }
 */
    var albumId : String!
    var userId : String!
    var title : String!
    var location : String!
    var albumEvent : String!
    var albumDescription : String!
    var createdDate : String!
    var coverImageId : String = ""
    
    
    init(_ data:JSON){
        albumId     = data["_id"].stringValue
        userId      = data["UserId"].stringValue
        title       = data["Title"].stringValue
        location    = data["Location"].stringValue
        albumEvent  = data["Event"].stringValue
        albumDescription = data["Description"].stringValue
        createdDate = data["CreatedAt"].stringValue
        
        if let coverImage = data["CoverImage"].string {
            coverImageId = coverImage
        }
    }
}
