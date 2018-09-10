//
//  RegisterViewController.swift
//  MateflickPhotobank
//
//  Created by Panda on 5/24/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import FSCalendar
import CountryPickerView
import DropDown
import DatePickerDialog

class RegisterViewController: UIViewController {

    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var termsLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var calendarContainer: UIView!
    
    // Fields
    @IBOutlet weak var firstnameText: SkyFloatingLabelTextField!
    @IBOutlet weak var lastnameText: SkyFloatingLabelTextField!
    @IBOutlet weak var usernameText: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordText: SkyFloatingLabelTextField!
    @IBOutlet weak var dateText: SkyFloatingLabelTextField!
    @IBOutlet weak var genderText: SkyFloatingLabelTextField!
    @IBOutlet weak var emailText: SkyFloatingLabelTextField!
    @IBOutlet weak var phoneText: UITextField!
    @IBOutlet weak var countryText: SkyFloatingLabelTextField!
    
    @IBOutlet weak var countryPicker: CountryPickerView!
    @IBOutlet weak var genderButton: UIButton!
    
    var selectedCountry : Country!
    var selectedPhoneCountry : Country!
    
    var isCheckedTerms : Bool = false
    var isShowPassword : Bool = false
    let activeColor = UIColor.init(red: 50/255.0, green: 118/255.0, blue: 181/255.0, alpha: 1)
    
    var userType : UserType!
    
    // Gender
    let genderArray : [String] = ["Male", "Female"]
    let genderDropDown = DropDown()
    
    // Social Info
    var socialCredentials : [String : String]?
    var socialId : String?
    var accountType = AccountType.email.rawValue
    
    // Calendar & DateFormatter
    fileprivate let gregorian = Calendar(identifier: .gregorian)
    fileprivate var formatter : DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        var placeholderString = ""
        if userType == UserType.User {
            self.titleLabel.text = "USER ACCOUNT"
            placeholderString = "Username"
        }
        else{
            self.titleLabel.text = "PHOTOGRAPHER"
            placeholderString = "Studio/Company"
        }
        
        // Show the place holder
        self.usernameText.placeholder = placeholderString
        
        self.registerButton.alpha = 0.5
        self.registerButton.isUserInteractionEnabled = false
        
        // Initialize the CountryPickerView
        initCountryPickerView()
        
        // Initialize the Gender Dropdown
        initGenderDropdown()
        
        // Display the social credentials
        if self.socialCredentials != nil {
            self.firstnameText.text = socialCredentials!["social_firstname"]
            self.lastnameText.text  = socialCredentials!["social_lastname"]
            self.emailText.text     = socialCredentials!["social_email"]
            self.socialId = socialCredentials!["social_id"]
            self.accountType = socialCredentials!["social_type"] == "facebook" ? AccountType.facebook.rawValue : AccountType.instagram.rawValue
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        initTermsConditionsLabel()
    }
    
    
    func initCountryPickerView(){
        let phoneCountryView = CountryPickerView(frame: CGRect(x: 0, y: 20, width: 100, height: 25))
        phoneText.leftView = phoneCountryView
        phoneText.leftViewMode = .always
        phoneText.showDoneButtonOnKeyboard()
        
        phoneCountryView.delegate = self
        phoneCountryView.tag = 100
        phoneCountryView.showCountryCodeInView = false
        
//        countryPicker.delegate = self
//        countryPicker.tag = 101
    }
    
    
    func initGenderDropdown(){
        genderDropDown.dataSource = genderArray
        genderDropDown.anchorView = genderText
        genderDropDown.bottomOffset = CGPoint(x: 0, y: genderText.bounds.height)
        genderDropDown.selectionAction = {[unowned self] (index: Int, item: String) in
            print("Selected gender: \(item)")
            self.genderText.text = self.genderArray[index]
            self.genderDropDown.hide()
        }
        genderDropDown.width = 100
    }
    
    func initTermsConditionsLabel(){
        // Set the attributed texts (underline and color)
        self.termsLabel.text = MSG_TERMS_CONDITION
        let underlineAttrString = NSMutableAttributedString(string: MSG_TERMS_CONDITION)
        let range1 = (MSG_TERMS_CONDITION as NSString).range(of: TERMS_CONDITIONS)
        underlineAttrString.addAttribute(.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: range1)
        underlineAttrString.addAttribute(.underlineColor, value: activeColor, range: range1)
        underlineAttrString.addAttribute(NSAttributedStringKey.foregroundColor, value: activeColor, range: range1)
        
        let range2 = (MSG_TERMS_CONDITION as NSString).range(of: PRIVACY_POLICY)
        underlineAttrString.addAttribute(.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: range2)
        underlineAttrString.addAttribute(.underlineColor, value: activeColor, range: range2)
        underlineAttrString.addAttribute(NSAttributedStringKey.foregroundColor, value: activeColor, range: range2)
        
        termsLabel.attributedText = underlineAttrString
        
        // Add the tap gesture to Terms & conditions label
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(RegisterViewController.tapLabel(gesture:)))
        self.termsLabel.isUserInteractionEnabled = true
        self.termsLabel.addGestureRecognizer(tapgesture)
    }
    
    @objc func tapLabel(gesture: UITapGestureRecognizer) {
        let termsRange = (MSG_TERMS_CONDITION as NSString).range(of: TERMS_CONDITIONS)
        let privacyRange = (MSG_TERMS_CONDITION as NSString).range(of: PRIVACY_POLICY)
        
        if gesture.didTapAttributedTextInLabel(label: self.termsLabel, inRange: termsRange) {
            print("Tapped terms & conditions")
            
            if let termsVC = self.storyboard?.instantiateViewController(withIdentifier: "TermsConditionsVC") as? TermsConditionsViewController {
                self.navigationController?.pushViewController(termsVC, animated: true)
            }
        } else if gesture.didTapAttributedTextInLabel(label: self.termsLabel, inRange: privacyRange) {
            print("Tapped privacy policy")
            if let privacyVC = self.storyboard?.instantiateViewController(withIdentifier: "PrivacyPolicyVC") as? PrivacyPolicyViewController {
                self.navigationController?.pushViewController(privacyVC, animated: true)
            }
            
        } else {
            print("Tapped none")
        }
    }
    
    @IBAction func onTermsContiditonSelected(_ sender: Any) {
        isCheckedTerms = !isCheckedTerms
        if isCheckedTerms {
            self.checkButton.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
            
            self.registerButton.alpha = 1
            self.registerButton.isUserInteractionEnabled = true
        }
        else{
            self.checkButton.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
            
            self.registerButton.alpha = 0.5
            self.registerButton.isUserInteractionEnabled = false
        }
    }
    
    // Back button
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // Register user
    @IBAction func onRegister(_ sender: Any) {
        // dismiss the keyboard
        self.view.endEditing(true)
        
        // check if network is connected to internet
        if !Reachability.isConnectedToNetwork() {
            self.showNoInternetAlert()
        }
        
        // First name
        if self.isEmpty(firstnameText.text) {
            firstnameText.errorMessage = MSG_INVALID_FIRSTNAME
            return
        }
//        else if firstnameText.text!.count < 4 {
//            self.showSimpleAlert(title: "", message: MSG_NAME_FIELD_LENGTH, complete: nil)
//            return
//        }
        
        // Last name
        if self.isEmpty(lastnameText.text){
            lastnameText.errorMessage = MSG_INVALID_LASTNAME
            return
        }
//        else if lastnameText.text!.count < 4 {
//            self.showSimpleAlert(title: "", message: MSG_NAME_FIELD_LENGTH, complete: nil)
////            lastnameText.errorMessage = MSG_NAME_FIELD_LENGTH
//            return
//        }
        
        // Username
        if self.isEmpty(usernameText.text) {
            if userType == UserType.User {
                usernameText.errorMessage = MSG_INVALID_USERNAME
            }
            else{
                usernameText.errorMessage = MSG_INVALID_STUDIO_COMPANY
            }
            return
        }
        
        // Password
        if self.isEmpty(passwordText.text) {
            passwordText.errorMessage = MSG_INVALID_PASSWORD
            return
        }
        
        // Email
        if self.isEmpty(emailText.text) || !self.isValidEmail(emailText.text!){
            emailText.errorMessage = MSG_INVALID_EMAIL
            return
        }
        
        // Contact Number
        if self.isEmpty(phoneText.text) {
//            phoneText.errorMessage = MSG_INVALID_CONTACT_NUMBER
            self.showSimpleAlert(title: "", message: MSG_INVALID_CONTACT_NUMBER, complete: nil)
            return
        }
        
        // Call Register api
        let params : [String : Any] = [
            "Mobile" : self.selectedCountry != nil ? "\(self.selectedCountry.phoneCode)\(phoneText.text!)" : "+1\(phoneText.text!)",
            "Password" : passwordText.text!,
            "CompanyName" : userType == UserType.Photographer ? usernameText.text! : "",
            "FirstName" : firstnameText.text!,
            "SurName" : lastnameText.text!,
            "EmailAddress" : emailText.text!,
            "Country" : self.selectedCountry != nil ? selectedCountry.code : "US",
            "DateOfBirth" : dateText.text!,
            "Token" : "1234567890",
            "DeviceType" : 1,
            "UserType" : userType.rawValue,
            "SocialId" : socialId != nil ? socialId! : "",
            "AccountType": accountType
        ]
        
        self.showLoadingProgress(view: self.navigationController?.view, label: MSG_SIGN_UP)
        UserInfo.sharedInstance.signUp(params: params) { (success, errorMsg) in
            self.dismissLoadingProgress(view: self.navigationController?.view)
            DispatchQueue.main.async {
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
    
    // Show / Hide the password
    @IBAction func togglePassword(_ sender: Any) {
        isShowPassword = !isShowPassword
        if isShowPassword {
            passwordText.isSecureTextEntry = false
        }
        else{
            passwordText.isSecureTextEntry = true
        }
    }
    
    // Show the calendar
    @IBAction func selectBirthday(_ sender: Any) {
        DatePickerDialog().show("Date of Birthday", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .date) {
            (date) -> Void in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                self.dateText.text = formatter.string(from: dt)
            }
        }
    }
    
    // Gender
    @IBAction func selectGender(_ sender: Any) {
        genderDropDown.show()
    }
    
    // Show the country picker
    @IBAction func selectCountry(_ sender: Any) {
        
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


extension RegisterViewController : CountryPickerViewDelegate {
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        self.selectedCountry = country
        print(country)
    }
}



extension RegisterViewController : UITextFieldDelegate {
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
