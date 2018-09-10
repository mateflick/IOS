//
//  OTPVerificationViewController.swift
//  MateflickPhotobank
//
//  Created by Panda on 5/29/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit
import PinCodeTextField

class OTPVerificationViewController: UIViewController {
    @IBOutlet weak var pinCodeText: PinCodeTextField!
    @IBOutlet weak var sendButton: UIButton!
    
    var phoneNumber : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        pinCodeText.keyboardType = .numberPad
        pinCodeText.delegate = self
        
        sendButton.isEnabled = false
        sendButton.alpha = 0.5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Dismiss the ViewController
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // Send the OTP code again from server
    @IBAction func sendOTPAgain(_ sender: Any) {
        
    }
    
    @IBAction func sendVerificationCode(_ sender: Any) {
        let code = self.pinCodeText.text!
        
        // Check if the network is connected to the Internet
        if !Reachability.isConnectedToNetwork() {
            self.showNoInternetAlert()
            return
        }
        
        // Call api to ask to send the OTP again
        self.showLoadingProgress(view: self.navigationController?.view)
        UserInfo.sharedInstance.verifySMS(code: code, mobile: phoneNumber) { (success, errorMsg) in
            DispatchQueue.main.async {
                self.dismissLoadingProgress(view: self.navigationController?.view)
                if success {
                    // Go to reset password page
                    if let resetPasswordVC = self.storyboard?.instantiateViewController(withIdentifier: "ResetPasswordConfirmVC") {
                        self.navigationController?.pushViewController(resetPasswordVC, animated: true)
                    }
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

}

extension OTPVerificationViewController : PinCodeTextFieldDelegate {
    func textFieldValueChanged(_ textField: PinCodeTextField) {
        let pinCode = textField.text ?? ""
        print("Pincode value changed : \(pinCode)")
        if pinCode.count == 6 {
            sendButton.isEnabled = true
            sendButton.alpha = 1
        }
    }
}
