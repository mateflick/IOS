//
//  LogInViewController.swift
//  MateflickPhotobank
//
//  Created by Panda on 5/27/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class LogInViewController: UIViewController {

    @IBOutlet weak var passwordText: SkyFloatingLabelTextField!
    @IBOutlet weak var emailText: SkyFloatingLabelTextField!
    
    var userType = UserType.User
    @IBOutlet weak var userTypeButton: UIButton!
    var isPhotographer : Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Loigin button is pressed and validate the user info
    @IBAction func onSignIn(_ sender: Any) {
        // dismiss the keyboard
        self.view.endEditing(true)
        
        if isValidUserInfo() {
            
            if !Reachability.isConnectedToNetwork() {
                self.showNoInternetAlert()
                return
            }
            
            // Call login api
            let params : [String : Any] = [
                "Id" : emailText.text!, // Phone number
                "Password" : passwordText.text!,
                "UserType" : userType.rawValue,
                "AccountType" : AccountType.email.rawValue
            ]
            
            self.showLoadingProgress(view: self.navigationController?.view, label: MSG_SIGN_IN)
            UserInfo.sharedInstance.login(params: params) { (success, errorMsg) in
                DispatchQueue.main.async {
                    self.dismissLoadingProgress(view: self.navigationController?.view)
                    if success {
                        let mainStoryboard = UIStoryboard.init(name: Storyboard.main , bundle: nil)
                        if let mainVC = mainStoryboard.instantiateViewController(withIdentifier: "ContainerVC") as? ContainerViewController {
                            self.navigationController?.pushViewController(mainVC, animated: true)
                        }
                    }
                    else{
                        self.showSimpleAlert(title: "", message: errorMsg, complete: nil)
                    }
                }
            }
        }
    }
    
    // Called when the back button is pressed
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func selectedPhotographerButton(_ sender: Any) {
        isPhotographer = !isPhotographer
        if isPhotographer {
            userType = UserType.Photographer
            userTypeButton.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
        }
        else{
            userType = UserType.User
            userTypeButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
        }
    }
    
    func isValidUserInfo() -> Bool{
        if self.isEmpty(emailText.text) || !self.isValidEmail(emailText.text!) {
            emailText.errorMessage = MSG_INVALID_EMAIL
            return false
        }
        
        if self.isEmpty(passwordText.text!) {
            passwordText.errorMessage = MSG_INVALID_PASSWORD
            return false
        }
        return true
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

extension LogInViewController : UITextFieldDelegate {
    /// Implementing a method on the UITextFieldDelegate protocol. This will notify us when something has changed on the textfield
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text != nil {
            if let floatingLabelTextField = textField as? SkyFloatingLabelTextField {
                // Hide the error message
                floatingLabelTextField.errorMessage = ""
            }
        }
        return true
    }
}
