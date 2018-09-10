//
//  CreateAccountViewController.swift
//  MateflickPhotobank
//
//  Created by Panda on 5/24/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit

class CreateAccountViewController: UIViewController {

    var isSocialLogin : Bool = false
    var socialInfo : [String : String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCreateUser(_ sender: Any) {
        self.gotoRegisterPage(UserType.User)
    }
    
    @IBAction func onCreatePhotographer(_ sender: Any) {
        self.gotoRegisterPage(UserType.Photographer)
    }
    
    func gotoRegisterPage(_ type : UserType){
        if let registerVC = self.storyboard?.instantiateViewController(withIdentifier: "RegisterVC") as? RegisterViewController {
            registerVC.userType = type
            if isSocialLogin {
                registerVC.socialCredentials = socialInfo
            }
            self.navigationController?.pushViewController(registerVC, animated: true)
        }
    }
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
