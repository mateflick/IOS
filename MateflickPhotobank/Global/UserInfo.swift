//
//  UserInfo.swift
//  MateflickPhotobank
//
//  Created by Panda on 5/28/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit
import SwiftyJSON

class UserInfo: NSObject {
    // Get the instance of this Singleton class
    static var sharedInstance : UserInfo = {
        var instance = UserInfo()
        return instance
    }()
    
    
    var userdata : UserData!
    var userId : String!
    var albumTagUsers : [PhoneContact] = []
    var eventTagUsers : [PhoneContact] = []
    
    var followers : Int = 0
    var followings : Int = 0
    var photos : Int = 0
    var usedSpace : Int = 0
    var skills : Int = 0
    var likes : Int = 0
    var userImage : String!
    
    var myEvents:[EventData] = []
    
    func initUser(with json : JSON){
        /*
         "data": {
         "_id": "5b45e70da7b8e856214a5020",
         "UserType": 2,
         "FollowersCount": 0,
         "PhotoCount": 0,
         "FollowingsCount": 0,
         "Mobile": "+966551543042",
         "FirstName": "Oleks",
         "SurName": "Daniel",
         "UsedSpace": 0,
         "EmailAddress": "a@a.com",
         "DateOfBirth": "11-11-2011",
         "Token": "empty",
         "DeviceType": 1,
         "UserImage": "5b5045aaa9ff4d743692304f",
         "Skills": 0
         }
        */
//        self.followers = json["FollowersCount"].intValue
//        self.followings = json["FollowingsCount"].intValue
//        self.photos = json["PhotoCount"].intValue
//        self.skills = json["Skills"].intValue
//        if let imageId = json["UserImage"].string {
//            self.userImage = imageId
//        }
//        self.usedSpace = json["UsedSpace"].intValue
        
        self.userdata = UserData(json)
    
    }
    
    // Clean all user data
    func cleanAll(){
        
    }
    
    // Logout
    func logout(){
        self.cleanAll()        
    }
    
    // Register User
    func signUp(params : [String : Any], complete:@escaping(Bool, String?) -> Void) {
        ApiManager.sharedInstance.signIn(params, isRegister: true) { (user, errorMsg) in
            if user != nil {
                self.userdata = user!
                self.userId = user!.userId
                
                UserDefaults.standard.set(params["EmailAddress"], forKey: KEY_UID)
                UserDefaults.standard.set(params["Password"], forKey: KEY_PWD)
                UserDefaults.standard.set(params["AccountType"] as! Int, forKey: KEY_ACCTYPE)
                UserDefaults.standard.set(params["UserType"] as! Int, forKey: KEY_USRTYPE)

                UserDefaults.standard.set(true, forKey: KEY_ISLOGIN)

                complete(true, nil)
            }
            else{
                complete(false, errorMsg)
            }
        }
    }
    
    // SignIn User
    func login(params : [String : Any], complete:@escaping(Bool, String?) -> Void) {
        ApiManager.sharedInstance.signIn(params) { (user, errorMsg) in
            if user != nil {
                self.userdata = user!
                self.userId = user!.userId
                
                UserDefaults.standard.set(params["Id"], forKey: KEY_UID)
                UserDefaults.standard.set(params["Password"], forKey: KEY_PWD)
                UserDefaults.standard.set(params["AccountType"] as! Int, forKey: KEY_ACCTYPE)
                UserDefaults.standard.set(params["UserType"] as! Int, forKey: KEY_USRTYPE)

                UserDefaults.standard.set(true, forKey: KEY_ISLOGIN)

                complete(true, nil)
            }
            else{
                complete(false, errorMsg)
            }
        }
    }
    
    // Forget password
    func resetPassword (_ newPassword : String, complete:@escaping(Bool, String?) -> Void) {
        ApiManager.sharedInstance.resetPassword(newPassword, complete: complete)
    }
    
    // Verify SMS
    func verifySMS(code : String, mobile:String, complete:@escaping(Bool, String?) -> Void){
        ApiManager.sharedInstance.verifySMS(code, mobile:mobile) { (success, errorMsg) in
            complete(success, errorMsg)
        }
    }
    
    // Request SMS code
    func getSMS(mobile:String, complete:@escaping(String, String?) -> Void) {
        ApiManager.sharedInstance.requestOTPCode(["Mobile" : mobile]) { (responseJson, errorMsg) in
            if responseJson != nil {
                let userId = responseJson!["UserId"].stringValue
                let otpCode = responseJson!["Value"].stringValue
                UserInfo.sharedInstance.userId = userId
                complete(otpCode, nil)
            }
            else{
                complete("", errorMsg)
            }
        }
    }
}
