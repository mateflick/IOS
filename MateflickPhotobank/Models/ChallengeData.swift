//
//  ChallengeData.swift
//  MateflickPhotobank
//
//  Created by Panda on 7/19/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChallengeData: NSObject {
    /*
     "_id": "5b504cb9a9ff4d7436923053",
     "Prize": 1000,
     "EndDate": 1832733297,
     "StartDate": 1761869298,
     "Name": "Bolek challenge3",
     "Description": "winter challenge",
     "CreatedAt": 1531989177381
 */
    var id : String!
    var prize : Int = 0
    var startDate: String!
    var endDate:String!
    var name : String!
    var challengeDescription : String!
    var createdDate : String!
    var votes : Int = 0
    
    init(_ data:JSON) {
        self.id                     = data["_id"].stringValue
        self.prize                  = data["Prize"].intValue
        self.endDate                = data["EndDate"].stringValue
        self.startDate              = data["StartDate"].stringValue
        self.challengeDescription   = data["Description"].stringValue
        self.createdDate            = data["CreatedAt"].stringValue
        self.name                   = data["Name"].stringValue
    }
}
