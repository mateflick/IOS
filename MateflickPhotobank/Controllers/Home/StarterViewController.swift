//
//  StarterViewController.swift
//  MateflickPhotobank
//
//  Created by Igor Ostriz on 13/09/2018.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit

class StarterViewController: UIViewController {

    var email: String?
    var pwd: String?
    var utype: UserType?
    var atype: AccountType?
    
    @IBOutlet weak var tryAgainButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        email = UserDefaults.standard.string(forKey: KEY_UID)
        pwd = UserDefaults.standard.string(forKey: KEY_PWD)
        utype = UserType(rawValue: UserDefaults.standard.integer(forKey: KEY_USRTYPE))
        atype = AccountType(rawValue: UserDefaults.standard.integer(forKey: KEY_ACCTYPE))

        
        tryAgainButton.alpha = 0
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if email != nil && pwd != nil && utype != nil && atype != nil {
            signIn()
        }
        else {
            displayAuth()
        }
    }
    

    func signIn() -> Void {
        
        if !Reachability.isConnectedToNetwork() {
            self.showNoInternetAlert()
            
            // display login button
            return
        }
        
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

                    self.displayMain()
                    
                }
                else{
                    self.showSimpleAlert(title: "", message: errorMsg) {

                        self.displayAuth()

                    }
                }
            }
        }

    }
    
    
    func displayAuth() -> Void {

        let authStoryboard = UIStoryboard.init(name: Storyboard.auth , bundle: nil)
        if let mainVC = authStoryboard.instantiateViewController(withIdentifier: "authNavController") as? UINavigationController {
            mainVC.modalTransitionStyle = .crossDissolve
            self.present(mainVC, animated: true, completion: nil)
        }

    }

    func displayMain() -> Void {
        
        let mainStoryboard = UIStoryboard.init(name: Storyboard.main , bundle: nil)
        if let mainVC = mainStoryboard.instantiateViewController(withIdentifier: "ContainerVC") as? ContainerViewController {
            mainVC.modalTransitionStyle = .crossDissolve
            self.present(mainVC, animated: true, completion: nil)
        }

    }
    
    
    func showHideButton(_ show: Bool)
    {
        UIView.animate(withDuration: 0.35) {
            self.tryAgainButton.alpha = 1
        }
    }
    
    @IBAction func onTryAgain(_ sender: UIButton) {
        signIn()
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
