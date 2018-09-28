//
//  SwitchAccountViewController.swift
//  MateflickPhotobank
//
//  Created by Igor Ostriz on 26/09/2018.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit

class SwitchAccountViewController: UIViewController {

    var email: String?
    var pwd: String?
    var utype: UserType?
    var atype: AccountType?

    override func viewDidLoad() {
        super.viewDidLoad()

        email = UserDefaults.standard.string(forKey: KEY_UID)
        pwd = UserDefaults.standard.string(forKey: KEY_PWD)
        utype = UserType(rawValue: UserDefaults.standard.integer(forKey: KEY_USRTYPE))
        atype = AccountType(rawValue: UserDefaults.standard.integer(forKey: KEY_ACCTYPE))

    }
    
    @IBAction func onMateButton(_ sender: UIButton) {
        
        utype = .User
        

        doLogin()
    }
    
    @IBAction func onPhotographerButton(_ sender: UIButton) {
        
        utype = .Photographer
        
        doLogin()
    }
    
    func doLogin() -> Void {
     
        // Call login api
        let params : [String : Any] = [
            "Id" : email!,
            "Password" : pwd!,
            "UserType" : utype!.rawValue,
            "AccountType" : atype!.rawValue
        ]

        self.showLoadingProgress(view: self.view, label: MSG_SIGN_IN)
        UserInfo.sharedInstance.login(params: params) { (success, errorMsg) in
            DispatchQueue.main.async {
                self.dismissLoadingProgress(view: self.view)
                if success {
                    
                    self.navigationController?.popViewController(animated: true)
                    
                }
                else{
                    
                    self.showSimpleAlert(title: "", message: errorMsg) {}
                    
                }
            }
        }
    }
    
}
