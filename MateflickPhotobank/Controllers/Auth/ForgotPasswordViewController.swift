//
//  ForgotPasswordViewController.swift
//  MateflickPhotobank
//
//  Created by Panda on 5/27/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailText: SkyFloatingLabelTextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Reset the password
    @IBAction func onResetPassword(_ sender: Any) {
        // Check if the email is valid
        if self.isEmpty(self.emailText.text) {
            self.emailText.errorMessage = MSG_INVALID_EMAIL
            return
        }
        else if self.emailText.text!.count < 10 {
            self.showSimpleAlert(title: "", message: MSG_PHONE_FIELD_LENGTH, complete: nil)
            return
        }
        
        if !Reachability.isConnectedToNetwork() {
            self.showNoInternetAlert()
            return
        }
        
        self.showLoadingProgress(view: self.navigationController?.view)
        UserInfo.sharedInstance.getSMS(mobile: self.emailText.text!) { (code, errorMsg) in
            DispatchQueue.main.async {
                self.dismissLoadingProgress(view: self.navigationController?.view)
                
                if !code.isEmpty {
                    print("SMS code = \(code)")
                    // Go to SMS verification ViewController
                    if let verifySMSVC = self.storyboard?.instantiateViewController(withIdentifier: "OTPVerificationVC") as? OTPVerificationViewController {
                        verifySMSVC.phoneNumber = self.emailText.text!
                        self.navigationController?.pushViewController(verifySMSVC, animated: true)
                    }
                }
                else{
                    self.showSimpleAlert(title: "", message: errorMsg, complete: nil)
                }
            }
        }        
    }
    
    // Called when back button is pressed
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

extension ForgotPasswordViewController : UITextFieldDelegate {
    /// Implementing a method on the UITextFieldDelegate protocol. This will notify us when something has changed on the textfield
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text != nil {
            if let floatingLabelTextField = textField as? SkyFloatingLabelTextField {
                floatingLabelTextField.errorMessage = ""
            }
        }
        return true
    }
}
