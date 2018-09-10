//
//  Constants.swift
//  MateflickPhotobank
//
//  Created by Panda on 5/24/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit

public enum UserType : Int{
    case User = 1
    case Photographer // 2
}

public enum Gender {
    case Male
    case Female
    case other
}

public enum AccountType : Int {
    case email = 0
    case facebook
    case instagram
}

let deviceTyoe : Int = 1 // iPhone

let KEY_ISLOGIN : String            = "is_loggedin"
let KEY_IS_REMEMBER                 = "is_remember_me"

let MSG_TERMS_CONDITION : String    = "I have read and agree to the Terms & Conditions and the Privacy Policy of Mateflick"
let MSG_INVALID_FIRSTNAME           = "Invalid Firstname"
let MSG_INVALID_LASTNAME            = "Invalid Lastname"
let MSG_INVALID_EMAIL               = "Invalid Email"
let MSG_INVALID_USERNAME            = "Invalid Username"
let MSG_INVALID_STUDIO_COMPANY      = "Invalid Studio or Company"
let MSG_INVALID_PASSWORD            = "Invalid Password"
let MSG_INVALID_CONTACT_NUMBER      = "Invalid Contact Number"
let MSG_PASSWORD_NOT_MATCHED        = "Not matched"
let MSG_SOMETHING_WRONG             = "Ops!, Something went wrong, try again later"

let MSG_SIGN_IN                     = "Logging in..."
let MSG_SIGN_UP                     = "Signing up..."
let MSG_NO_INTERNET                 = "Make sure your device is connected to the Internet."
let MSG_NO_INTERNET_TITLE           = "No Internet connection"
let MSG_NAME_FIELD_LENGTH           = "Name length must be larger than or equal to 4 characters long!"
let MSG_PHONE_FIELD_LENGTH          = "Phone number must be larger than or equal to 10 characters long!"

let TERMS_CONDITIONS                = "Terms & Conditions"
let PRIVACY_POLICY                  = "Privacy Policy"

let TERMS_CONDITIONS_CONTENT        = ""
let PRIVACY_POLICY_CONTENT          = ""

let PRIMARY_COLOR : UIColor = UIColor(red: 50/255.0, green: 118/255.0, blue: 181/255.0, alpha: 1)

let PLACEHOLDER_SEARCH_FAMILY = "Search Family or Friends"
let PLACEHOLDER_SEARCH_PHOTOGRAPHER = "Search Photographers"
let PLACEHOLDER_SEARCH_USERS = "Search Users"

struct Storyboard {
    static let main : String = "Main"
    static let auth : String = "Auth"
}

struct TableCell {
    static let feed : String                = "FeedTableCell"
    static let challenge : String           = "ChallengeTableCell"
    static let notificationParole : String  = "NotificationParoleCell"
    static let notificationVote : String    = "NotificationVoteCell"
    static let swap : String                = "SwapTableCell"
    static let photoBankCollection : String = "PhotobankCollectionCell"
    static let eventAlbum : String          = "eventAlbumCollectionCell"    
}

let KEY_FIRSTNAME                 = "key_firstname"
let KEY_LASTNAME                  = "key_lastname"
let KEY_EMAIL                     = "key_email"
let KEY_COMPANY                   = "key_company"
let KEY_BIRTHDAY                  = "key_birthday"
let KEY_PHONE                     = "key_phone"
let KEY_DEVICE_TOKEN              = "key_device_token"

public let MEDIA_FOLDER                 = "Media/"
public let MEDIA_PHOTO_FOLDER           = MEDIA_FOLDER + "Photos/"
public let MEDIA_CAMERA_FOLDER          = MEDIA_FOLDER + "Camera/"
public let MEDIA_PROFILE                = MEDIA_FOLDER + "Profile/"
let IMG_USER_PROFILE                    = "user.jpg"

let INSTAGRAM_AUTH_URL       = "https://api.instagram.com/oauth/authorize/"
let INSTAGRAM_API_URL        = "https://api.instagram.com/v1/users/"
let INSTAGRAM_CLIENT_ID      = "04fbfddaf37941b19795a90ba3dc3fc8"
let INSTAGRAM_CLIENT_SECRET  = "4cef224298f94102878b47cd0db0e68f"
let INSTAGRAM_ACCESS_TOKEN   = "access_token"
let INSTAGRAM_REDIRECT_URI   = "http://www.mateflick.com/"
let INSTAGRAM_SCOPE          = "follower_list+public_content"
let INSTAGRAM_USER_ENDPOINTS = "https://api.instagram.com/v1/users/self/?access_token="

let MSG_INVALID_EMAIL_PASSWORD = "Invalid EmailAddress/Password"
let MSG_INVALID_EMAIL_TOKEN    = "Inavlid EmailAddress/Token"


