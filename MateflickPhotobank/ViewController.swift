//
//  ViewController.swift
//  MateflickPhotobank
//
//  Created by Panda on 5/24/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FacebookLogin
import SwiftInstagram

class ViewController: UIViewController {

    let api = Instagram.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onLoginPressed(_ sender: Any) {
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LogInVC") as! LogInViewController
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
    
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
    
    @IBAction func loginWithFacebook(_ sender: Any) {
        if FBSDKAccessToken.currentAccessTokenIsActive() { // Already logged in
            let accessToken = FBSDKAccessToken.current()
            self.getFBProfile(with: accessToken!.tokenString)
        }
        else{ // still not logged in
            self.loginFB()
        }
    }
    
    func loginFB(){
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.email, .publicProfile], viewController: self) { (loginResult) in
            switch loginResult {
            case .failed(let error):
                print("Facebook login error : \(error.localizedDescription)")
            case .cancelled:
                print("Cancelled Facebook login")
            case .success( _, _, let accessToken):
                print("Facebook login success")
                self.getFBProfile(with: accessToken.authenticationToken)
            }
        }
    }
    
    func getFBProfile(with token : String) {
        print("Facebook token = \(token)")
        
        self.showLoadingProgress(view: self.navigationController?.view, label: "Please wait...")
        let req : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id, email, first_name, last_name"], tokenString: token, version: nil, httpMethod: "GET")
        req.start(completionHandler: { (connection, result, error) in
            DispatchQueue.main.async {
                self.dismissLoadingProgress(view: self.navigationController?.view)
                if error == nil {
                    let data:[String:AnyObject] = result as! [String : AnyObject]
                    print(data)
                    
                    // user id
                    let fbId    = data["id"] as! String
                    
                    // user email
                    var fbEmail = ""
                    if let email = data["email"] {
                        fbEmail = email as! String
                    }
                    
                    // user name
                    var fbFirstname = ""
                    if let name = data["first_name"] {
                        fbFirstname = name as! String
                    }
                    
                    var fbLastname = ""
                    if let name = data["last_name"] {
                        fbLastname = name as! String
                    }
                    
                    // user profile picture
                    let fbProfileUrl = "http://graph.facebook.com/\(fbId)/picture?type=large"
                    
                    // collect all FB profile information
                    let socialInfo : [String : String] = [
                        "social_id" : fbId,
                        "social_email" : fbEmail,
                        "social_firstname" : fbFirstname,
                        "social_lastname" : fbLastname,
                        "social_avatar" : fbProfileUrl,
                        "social_type" : "facebook",
                        "token" : token
                    ]
                    
                    self.checkIfAlreadyRegisterUser(socialInfo)
                }
                else{
                    print("error \(String(describing: error))")
                }
            }
        })
    }
    
    func checkIfAlreadyRegisterUser(_ info : [String : String]){
        // Call api to check if already registered
        
        let socialId = info["social_id"]
        let socialToken = info["token"]
        // Call login api
        let params : [String : Any] = [
            "Id" : socialId!, // Facebook or Instagram Id
            "Password" : socialToken!, // Token
            "UserType" : 1,
            "AccountType" : info["social_type"] == "facebook" ? AccountType.facebook.rawValue : AccountType.instagram.rawValue
        ]
        
        self.showLoadingProgress(view: self.navigationController?.view, label: MSG_SIGN_IN)
        UserInfo.sharedInstance.login(params: params) { (success, errorMsg) in
            DispatchQueue.main.async {
                self.dismissLoadingProgress(view: self.navigationController?.view)
                if success {
                    // Go to Feed page
                    let mainStoryboard = UIStoryboard.init(name: Storyboard.main , bundle: nil)
                    if let mainVC = mainStoryboard.instantiateViewController(withIdentifier: "ContainerVC") as? ContainerViewController {
                        self.navigationController?.pushViewController(mainVC, animated: true)
                    }
                }
                else{
                    if errorMsg == MSG_INVALID_EMAIL_PASSWORD || errorMsg == MSG_INVALID_EMAIL_TOKEN {
                        // Go to UserTypeSelection page
                        if let createAccountVC = self.storyboard?.instantiateViewController(withIdentifier: "CreateAccountVC") as? CreateAccountViewController {
                            createAccountVC.isSocialLogin = true
                            createAccountVC.socialInfo = info
                            self.navigationController?.pushViewController(createAccountVC, animated: true)
                        }
                    }
                    else{
                        self.view.makeToast(errorMsg ?? "Social login failed, try again later")
                    }
                }
            }
        }
    }
    
    @IBAction func loginWithInstagram(_ sender: Any) {
        if let instagramLoginVC = self.storyboard?.instantiateViewController(withIdentifier: "InstagramLoginVC") as? InstagramLoginViewController{
            instagramLoginVC.delegate = self
            self.present(instagramLoginVC, animated: true, completion: nil)
        }
        
        // Login
//        api.login(from: self.navigationController!, withScopes: [.basic, .publicContent], success: {
//            print("*** Instagram login success! ***")
//            if let accessToken = self.api.retrieveAccessToken() {
//                print("*** Instagram access token = \(accessToken)")
//            }
//        }) { (error) in
//            print("*** Instagram login failed! ***")
//            self.view.makeToast(error.localizedDescription)
//        }
    }
    
    
}

extension ViewController : InstagramLoginDelegate {
    func didLoginSuccessfully(_ info: [String : String]) {
        self.checkIfAlreadyRegisterUser(info)
    }
}


