//
//  ApiManager.swift
//  MateflickPhotobank
//
//  Created by Panda on 6/21/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class ApiManager: NSObject {
    static var sharedInstance : ApiManager = {
        var instance = ApiManager()
        return instance
    }()
    
    let baseURL         = "https://mateflick.herokuapp.com/"
    let userLogin       = "user/login"
    let userRegister    = "user/register"
    let userProfile     = "user/profile"
    let changePassword  = "user/changePassword"
    let sendSMS         = "sms/sendSms"
    let verifySMS       = "sms/verifySms"
    
    let createGallery   = "gallery/new"
    let updateGallery   = "gallery/update"
    let removeGallery   = "gallery/remove"
    let listOfGallery   = "gallery/list"
    
    let createEvent     = "event/create"
    let allUpcomingEvents    = "event/list/all/upcoming"
    let myAllEvents     = "event/list/upcoming"
    let allPastEvents   = "event/list/all/past"
    let myPastEvents    = "event/list/past"
    let searchEvent     = "event/search"
    
    let fileList          = "files/list"
    let downloadImage     = "files/fileById/"
    let downloadUserImage = "files/file/"
    
    let upcomingChallenge = "challenge/list/upcoming"
    let pastChallenge     = "challenge/list/past"
    let joinChallenge     = "photochallenge/join"
    
    let timeline        = "timeline/user"
    
    let searchUsers             = "follow/myUsers"
    let searchPhotographers     = "follow/myPhotgraphers"
    let suggestedUsers          = "user/suggestedUsers"
    let suggestedPhotographers  = "user/suggestedPhotographers"
    
    let followUser              = "follow"
    
    typealias DefaultResponse   = (JSON?, Error?) -> Void
    typealias UpdateResponse    = (Bool, String) -> Void
    typealias DefaultArrayResponse = ([JSON]?, Error?) ->Void
    typealias JSONDefaultResponse = (Bool, Error?) -> Void
    
    let headers : HTTPHeaders = [
        "Content-Type":"application/json",
        "Accept" : "application/json"
    ]
    
    func getImagePath(_ imageId : String) -> String {
        return "\(baseURL)\(downloadImage)\(imageId)"
    }
    
    func getUserProfileImagePath(_ userId : String) -> String {
        return "\(baseURL)\(downloadImage)\(userId)"
    }
    
    // MARK:- REQUEST METHOD
    func request(method:HTTPMethod, url:String, params:[String:Any]?, headers :HTTPHeaders?, encoding: ParameterEncoding = URLEncoding.default, complete: @escaping DefaultResponse) -> Void {
        Alamofire.request(url, method: method, parameters: params, encoding: encoding, headers: headers).responseJSON { (response : DataResponse<Any>) in
            print("**** Response from server **** \(response)")
            switch response.result{
            case .success(let data):
                let result = JSON(data)
                complete(result, nil)
                break
            case .failure(let error):
                complete(nil, error)
                break
            }
        }
    }
    
    // Send request with JSON Encoding
    func requestWithJson(method:HTTPMethod, url:String, params:[String:Any]?, encoding: ParameterEncoding = JSONEncoding.default, complete: @escaping DefaultResponse) -> Void {
        let headers : HTTPHeaders = [
            "Content-Type":"application/json",
            "Accept" : "application/json"
        ]
        Alamofire.request(url, method: method, parameters: params, encoding: encoding, headers: headers).responseJSON { (response : DataResponse<Any>) in
            print("**** Response from server **** \(response)")
            switch response.result{
            case .success(let data):
                let result = JSON(data)
                complete(result, nil)
                break
            case .failure(let error):
                complete(nil, error)
                break
            }
        }
    }
    
    //
    func getApiRequestResult(method : HTTPMethod, url : String, params : [String : Any]?, complete:@escaping(Bool, String?)-> Void) {
        self.requestWithJson(method: .post, url: url, params: params) { (response, error) in
            if error != nil {
                print("Request Error = \(error!.localizedDescription)")
                complete(false, error!.localizedDescription)
            }
            else{
                let statusCode = response!["code"].intValue
                if statusCode  == 200 {
                    complete(true, nil)
                }
                else{
                    let errorMsg = response!["message"].stringValue
                    complete(false, errorMsg)
                }
            }
        }
    }
    
    // Login & SignUp
    func signIn(_ params:[String : Any], isRegister : Bool = false, complete:@escaping(UserData?, String?) -> Void) -> Void {
        var requestUrl = ""
        if isRegister {
            requestUrl = "\(baseURL)\(userRegister)"
        }
        else{
            requestUrl = "\(baseURL)\(userLogin)"
        }
        
        self.requestWithJson(method: .post, url: requestUrl, params: params) { (response, error) in
            if error != nil {
                print("Sign Error = \(error!.localizedDescription)")
                complete(nil, error!.localizedDescription)
            }
            else{
                if let responseJson = response {
                    let statusCode = responseJson["code"].intValue
                    if statusCode  == 200 {
                        let userData = UserData(responseJson["data"])
                        complete(userData, nil)
                    }
                    else{
                        let errorMsg = responseJson["message"].stringValue
                        complete(nil, errorMsg)
                    }
                }
                else{
                    complete(nil, MSG_SOMETHING_WRONG)
                }
            }
        }
    }
    
    // Request the OTP code
    func requestOTPCode(_ params:[String:Any], complete:@escaping(JSON?, String?) -> Void){
        let requestUrl = "\(baseURL)\(sendSMS)"
        self.requestWithJson(method: .post, url: requestUrl, params: params) { (response, error) in
            if error != nil {
                print("SMS request Error = \(error!.localizedDescription)")
                complete(false, error!.localizedDescription)
            }
            else{
                let statusCode = response!["code"].intValue
                if statusCode  == 200 {
                    complete(response!["data"], nil)
                }
                else{
                    let errorMsg = response!["message"].stringValue
                    complete(nil, errorMsg)
                }
            }
        }
    }
    
    //Verify SMS
    func verifySMS(_ code: String, mobile:String, complete:@escaping(Bool, String?) -> Void){
        let requestUrl = "\(baseURL)\(verifySMS)"
        let params : [String:Any] = [
            "Mobile" : mobile,
            "Value" : code
        ]
        self.getApiRequestResult(method: .post, url: requestUrl, params: params, complete: complete)
    }
    
    // Reset password
    func resetPassword(_ newPassword : String, complete:@escaping(Bool, String?) -> Void) {
        let requestUrl = "\(baseURL)\(changePassword)"
        let params : [String : Any] = [
            "Id" : UserInfo.sharedInstance.userId,
            "Password" : newPassword
        ]
        
        self.getApiRequestResult(method: .post, url: requestUrl, params: params, complete: complete)
    }
    
    // Create Album
    func createNewAlbum(_ params : [String : Any], complete:@escaping(AlbumData? , String?)-> Void) -> Void {
        let requestUrl = "\(baseURL)\(createGallery)"
        self.requestWithJson(method: .post, url: requestUrl, params: params) { (response, error) in
            if error != nil {
                print("Create album request Error = \(error!.localizedDescription)")
            }
            else{
                let statusCode = response!["code"].intValue
                if statusCode  == 200 {
                    let albumJson = response!["data"]
                    complete(AlbumData(albumJson), nil)
                }
                else{
                    let errorMsg = response!["message"].stringValue
                    complete(nil, errorMsg)
                }
            }
        }
    }
    
    // Update album
    func updateAlbum(_ params: [String:Any], complete:@escaping(AlbumData? , String?) -> Void){
        let requestUrl = "\(baseURL)\(updateGallery)"
        self.requestWithJson(method: .post, url: requestUrl, params: params) { (response, error) in
            if error != nil {
                print("Update album request Error = \(error!.localizedDescription)")
            }
            else{
                let statusCode = response!["code"].intValue
                if statusCode  == 200 {
                    let albumJson = response!["data"]
                    complete(AlbumData(albumJson), nil)
                }
                else{
                    let errorMsg = response!["message"].stringValue
                    complete(nil, errorMsg)
                }
            }
        }
    }
    
    // Remove album
    func removeAlbum(_ params: [String:Any], complete:@escaping(String? , String?) -> Void){
        let requestUrl = "\(baseURL)\(removeGallery)"
        self.requestWithJson(method: .post, url: requestUrl, params: params) { (response, error) in
            if error != nil {
                print("Remove album request Error = \(error!.localizedDescription)")
            }
            else{
                let statusCode = response!["code"].intValue
                if statusCode  == 200 {
                    let raw = response!["data"]
                    complete(raw.rawString(), nil)
                }
                else{
                    let errorMsg = response!["message"].stringValue
                    complete(nil, errorMsg)
                }
            }
        }
    }

    
    // Create Event
    func createNewEvent(_ params : [String : Any], complete:@escaping(EventData? , String?)-> Void) -> Void {
        let requestUrl = "\(baseURL)\(createEvent)"
        self.requestWithJson(method: .post, url: requestUrl, params: params) { (response, error) in
            if error != nil {
                print("Create event request Error = \(error!.localizedDescription)")
            }
            else{
                let statusCode = response!["code"].intValue
                if statusCode  == 200 {
                    let eventJson = response!["data"]
                    complete(EventData(eventJson), nil)
                }
                else{
                    let errorMsg = response!["message"].stringValue
                    complete(nil, errorMsg)
                }
            }
        }
    }
    
    // Upload image to Gallery & Event
    func uploadImageToGallery(_ mediaId:String, isAlbum:Bool, imageURL: URL, complete:@escaping(Bool, String?) -> Void) -> Void{
        var requestUrl = ""
        if isAlbum {
            requestUrl = "\(baseURL)post/gallery/\(mediaId)/user/\(UserInfo.sharedInstance.userId!)/title/NoTitle"
        }
        else{
            requestUrl = "\(baseURL)evpost/event/\(mediaId)/user/\(UserInfo.sharedInstance.userId!)/title/NoTitle"
        }
        
        print("Image Upload Request Url ==== \(requestUrl)")
        
        Alamofire.upload(multipartFormData: { (multiFormData) in
            multiFormData.append(imageURL, withName: "file")
        }, to: requestUrl, encodingCompletion: { (encodingResult) in
            switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON(completionHandler: { (response) in
                        print("ApiManager : Upload Success Response === \(response)")
                        switch response.result {
                        case .success(_):
                            if let responseData = response.result.value {
                                let uploadResponseJson = JSON(responseData)
                                let successCode = uploadResponseJson["code"]
                                if successCode == 200 {
                                    complete(true, nil)
                                }
                                else{
                                    let message = uploadResponseJson["message"].stringValue
                                    complete(false, message)
                                }
                            }
                        case .failure(let error):
                            complete(false, error.localizedDescription)
                        }
                    })
                
                case .failure(let encodingError):
                    print("ApiManager : upload error =\(encodingError)")
                    complete(false, encodingError.localizedDescription)
                }
        })
    }
    
    // Upload profile image
    func uploadProfileImage(with URL : URL, complete:@escaping(Bool, String?) -> Void) {
        let requestUrl = "\(baseURL)user/image/\(UserInfo.sharedInstance.userId!)"
        Alamofire.upload(multipartFormData: { (multiFormData) in
            multiFormData.append(URL, withName: "file")
        }, to: requestUrl, encodingCompletion: { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON(completionHandler: { (response) in
                    print("ApiManager : Upload Success Response === \(response)")
                    switch response.result {
                    case .success(_):
                        if let responseData = response.result.value {
                            let uploadResponseJson = JSON(responseData)
                            let successCode = uploadResponseJson["code"]
                            if successCode == 200 {
                                complete(true, nil)
                            }
                            else{
                                let message = uploadResponseJson["message"].stringValue
                                complete(false, message)
                            }
                        }
                    case .failure(let error):
                        complete(false, error.localizedDescription)
                    }
                })
                
            case .failure(let encodingError):
                print("ApiManager : upload error =\(encodingError)")
                complete(false, encodingError.localizedDescription)
            }
        })
    }
    
     // Get Album array
    func getAlbumArray(params : [String: Any], complete:@escaping([AlbumData]? , Int, Int, String?)-> Void){
        let requestUrl = "\(baseURL)\(listOfGallery)"
        
        self.requestWithJson(method: .post, url: requestUrl, params: params) { (response, error) in
            if response != nil {
                let statusCode = response!["code"].intValue
                if statusCode == 200 {
                    let albumJson = response!["data"]
                    var albums : [AlbumData] = []
                    if let albumJsonArray = albumJson["rows"].array {
                        albumJsonArray.forEach({ (item:JSON) in
                            let album = AlbumData(item)
                            albums.append(album)
                        })
                    }
                    
                    let pageNumber = albumJson["page"].intValue
                    let totalPages = albumJson["totalPages"].intValue
                    complete(albums, pageNumber, totalPages, nil)
                }
                else{
                    let message = response!["message"].stringValue
                    complete(nil, -1, 0, message)
                }
            }
            else{
                complete(nil, -1, 0, error?.localizedDescription ?? "")
            }
        }
        
    }
    
    // Timeline
    func loadTimelineData(_ page:Int, pageSize:Int, complete:@escaping([TimelineData]?, Int, String?) -> Void) {
        let requestUrl = "\(baseURL)\(timeline)"
        let params : [String:Any] = [
            "UserId" : UserInfo.sharedInstance.userId!,
            "page" : page,
            "pageSize" : pageSize
        ]
        
        self.requestWithJson(method: .post, url: requestUrl, params: params) { (response, error) in
            if response != nil {
                let statusCode = response!["code"].intValue
                if statusCode == 200 {
                    let timelineJson = response!["data"].arrayValue
                    var timelineArray : [TimelineData] = []
                    timelineJson.forEach({ (item : JSON) in
                        let timeline = TimelineData(item)
                        timelineArray.append(timeline)
                    })
                    
                    complete(timelineArray, 0, nil)
                }
                else{
                    let message = response!["message"].stringValue
                    complete(nil, 0, message)
                }
            }
            else{
                complete(nil, 0, error?.localizedDescription ?? "")
            }
        }
    }
    
    // Upcoming events
    func getUpcomingEvents(_ page:Int, pageSize:Int, userId : String? = nil, complete:@escaping([EventData]? , String?) -> Void){
        var requestUrl = ""
        var params : [String : Any] = [:]
        
        if userId != nil { // User Events
            params = [
                "UserId" : userId!,
                "page" : page,
                "pageSize" : pageSize
            ]
            requestUrl = "\(baseURL)\(myAllEvents)"
            
        }
        else{
            params = [
                "page" : page,
                "pageSize" : pageSize
            ]
            requestUrl = "\(baseURL)\(allUpcomingEvents)"
        }
        
        self.requestWithJson(method: .post, url: requestUrl, params: params) { (response, error) in
            if response != nil {
                let code = response!["code"].intValue
                if code == 200 {
                    let eventJson = response!["data"].arrayValue
                    var events : [EventData] = []
                    eventJson.forEach({ (item : JSON) in
                        let event = EventData(item)
                        events.append(event)
                    })
                    
                    complete(events, nil)
                }
                else{
                    let message = response!["message"].stringValue
                    complete(nil, message)
                }
            }
            else{
                complete(nil, error?.localizedDescription)
            }
        }
    }
    
    // Past events
    func getPastEvents(_ page:Int, pageSize:Int, userId : String? = nil, complete:@escaping([EventData]? , String?) -> Void){
        var requestUrl = ""
        var params : [String : Any] = [:]
        
        if userId != nil { // User Events
            params = [
                "UserId" : userId!,
                "page" : page,
                "pageSize" : pageSize
            ]
            requestUrl = "\(baseURL)\(myPastEvents)"
            
        }
        else{
            params = [
                "page" : page,
                "pageSize" : pageSize
            ]
            requestUrl = "\(baseURL)\(allPastEvents)"
        }
        
        self.requestWithJson(method: .post, url: requestUrl, params: params) { (response, error) in
            if response != nil {
                let code = response!["code"].intValue
                if code == 200 {
                    let eventJson = response!["data"].arrayValue
                    var events : [EventData] = []
                    eventJson.forEach({ (item : JSON) in
                        let event = EventData(item)
                        events.append(event)
                    })
                    
                    complete(events, nil)
                }
                else{
                    let message = response!["message"].stringValue
                    complete(nil, message)
                }
            }
            else{
                complete(nil, error?.localizedDescription)
            }
        }
    }
    
    // Search events
    func searchEvents(keyword : String, page : Int, pageSize:Int, complete:@escaping([EventData]?, String?) -> Void) {
        let requestUrl = "\(baseURL)\(searchEvent)"
        let params : [String : Any] = [
            "Search" : keyword,
            "page" : page,
            "pageSize" : pageSize
        ]
        
        self.requestWithJson(method: .post, url: requestUrl, params: params) { (response, error) in
            if response != nil {
                let code = response!["code"].intValue
                if code == 200 {
                    let dataJson = response!["data"]
                    let eventJson = dataJson["rows"].arrayValue
                    var events : [EventData] = []
                    eventJson.forEach({ (item : JSON) in
                        let event = EventData(item)
                        events.append(event)
                    })
                    
                    complete(events, nil)
                }
                else{
                    let message = response!["message"].stringValue
                    complete(nil, message)
                }
            }
            else{
                complete(nil, error?.localizedDescription)
            }
        }
    }
    
    // Upcoming challenge
    func getUpcomingChallenge(_ params:[String:Any], complete:@escaping([ChallengeData]?, String?) -> Void) -> Void{
        let requestUrl = "\(baseURL)\(upcomingChallenge)"
        self.requestWithJson(method: .post, url: requestUrl, params: params) { (response, error) in
            if response != nil {
                let code = response!["code"].intValue
                if code == 200 {
                    let challengeJson = response!["data"].arrayValue
                    var challenges : [ChallengeData] = []
                    challengeJson.forEach({ (item : JSON) in
                        let challenge = ChallengeData(item)
                        challenges.append(challenge)
                    })
                    
                    complete(challenges, nil)
                }
                else{
                    let message = response!["message"].stringValue
                    complete(nil, message)
                }
            }
            else{
                complete(nil, error?.localizedDescription)
            }
        }
    }
    
    // Join challenge
    func joinChallenge(challengeId : String, userId : String, complete:@escaping(Bool, String?) -> Void){
        let requestUrl = "\(baseURL)\(joinChallenge)"
        let params:[String:Any] = [
            "ChallengeId" : challengeId,
            "PhotographerId" : userId
        ]
        
        self.getApiRequestResult(method: .post, url: requestUrl, params: params, complete: complete)
    }
    
    // Search users (User & Photographer)
    func searchUsers(keyword : String, userType : UserType, pageNumber:Int, pageSize: Int, complete:@escaping([MyFriendData]? , String?)-> Void) {
        var requestUrl = ""
        let params:[String:Any] = [
            "UserId" : UserInfo.sharedInstance.userId!,
            "Keyword" : keyword,
            "page" : pageNumber,
            "pageSize" : pageSize
        ]
        
        if userType == UserType.User {
            requestUrl = "\(baseURL)\(searchPhotographers)"
        }
        else{
            requestUrl = "\(baseURL)\(searchUsers)"
        }
        self.requestWithJson(method: .post, url: requestUrl, params: params) { (response, error) in
            if response != nil {
                let code = response!["code"].intValue
                if code == 200 {
                    let userJson = response!["data"].arrayValue
                    var users : [MyFriendData] = []
                    userJson.forEach({ (item : JSON) in
                        let user = MyFriendData(item)
                        users.append(user)
                    })
                    
                    complete(users, nil)
                }
                else{
                    let message = response!["message"].stringValue
                    complete(nil, message)
                }
            }
            else{
                complete(nil, error?.localizedDescription ?? "")
            }
        }
    }
    
    // Suggested Users & Photographers
    func getSuggestUsers(userType : UserType, pageNumber:Int, pageSize: Int, complete:@escaping([UserData]? , String?)-> Void) {
        var requestUrl = ""
        let params:[String:Any] = [
            "UserId" : UserInfo.sharedInstance.userId!,
            "page" : pageNumber,
            "pageSize" : pageSize
        ]
        
        if userType == UserType.User {
            requestUrl = "\(baseURL)\(suggestedPhotographers)"
        }
        else{
            requestUrl = "\(baseURL)\(suggestedUsers)"
        }
        self.requestWithJson(method: .post, url: requestUrl, params: params) { (response, error) in
            if response != nil {
                let code = response!["code"].intValue
                if code == 200 {
                    let dataJson = response!["data"]
                    let userJsonArray = dataJson["rows"].arrayValue
                    var users : [UserData] = []
                    userJsonArray.forEach({ (item : JSON) in
                        let user = UserData(item)
                        users.append(user)
                    })
                    
                    complete(users, nil)
                }
                else{
                    let message = response!["message"].stringValue
                    complete(nil, message)
                }
            }
            else{
                complete(nil, error?.localizedDescription ?? "")
            }
        }
    }
    func getInstagramUserCredentials(url : String, complete:@escaping(JSON?, String?) -> Void){
        self.request(method: .get, url: url, params: nil, headers: nil) { (response, error) in
            if let userInfo = response {
                let meta = userInfo["meta"]
                if meta["code"].intValue == 200 {
                    let dataJson = userInfo["data"]
                    complete(dataJson, nil)
                }
                else{
                    let message = meta["error_message"].stringValue
                    complete(nil, message)
                }
            }
            else{
                complete(nil, error?.localizedDescription)
            }
        }
    }
    
    // User profile
    func getUserProfile(_ complete:@escaping(Bool, String?) -> Void){
        let requestUrl = "\(baseURL)\(userProfile)"
        let param : [String : Any] = ["UserId":UserInfo.sharedInstance.userId!]
        self.requestWithJson(method: .post, url: requestUrl, params: param) { (response, error) in
            if response != nil {
                let code = response!["code"]
                if code == 200 {
                    let profileJson = response!["data"]
                    UserInfo.sharedInstance.userdata = UserData(profileJson)
//                    UserInfo.sharedInstance.initUser(with: profileJson)
                    complete(true, nil)
                }
                else{
                    let message = response!["message"].stringValue
                    complete(false, message)
                }
            }
            else{
                complete(false, error?.localizedDescription ?? "")
            }
        }
    }
}


