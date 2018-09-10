//
//  ResetPasswordConfirmViewController.swift
//  MateflickPhotobank
//
//  Created by Panda on 5/29/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class ResetPasswordConfirmViewController: UIViewController {

    @IBOutlet weak var newPasswordText: SkyFloatingLabelTextField!
    
    @IBOutlet weak var confirmPasswordText: SkyFloatingLabelTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
//        self.navigationController?.popViewController(animated: true)
        self.gotoLoginPage()
    }
    
    @IBAction func onResetPassword(_ sender: Any) {        
        if self.isEmpty(newPasswordText.text) {
            newPasswordText.errorMessage = MSG_INVALID_PASSWORD
            return
        }
        
        if self.isEmpty(confirmPasswordText.text) {
            confirmPasswordText.errorMessage = MSG_INVALID_PASSWORD
            return
        }
        
        if newPasswordText.text! != confirmPasswordText.text! {
            confirmPasswordText.errorMessage = MSG_PASSWORD_NOT_MATCHED
            return
        }
        
        if !Reachability.isConnectedToNetwork() {
            self.showNoInternetAlert()
            return
        }
        
        // Call api to reset the password
        self.showLoadingProgress(view: self.navigationController?.view)
        UserInfo.sharedInstance.resetPassword(newPasswordText.text!) { (success, errorMsg) in
            DispatchQueue.main.async {
                self.dismissLoadingProgress(view: self.navigationController?.view)
                if success {
                    // Go to login viewcontroller
                    self.gotoLoginPage()
                }
                else{
                    self.showSimpleAlert(title: "", message: errorMsg, complete: nil)
                }
            }
            
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func gotoLoginPage(){
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: LogInViewController.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }

}

extension ResetPasswordConfirmViewController : UITextFieldDelegate {
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
