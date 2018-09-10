//
//  InstagramLoginViewController.swift
//  VanChat
//
//  Created by MHM on 6/26/18.
//  Copyright © 2018 CreativeTeam. All rights reserved.
//

import UIKit
import Toast_Swift

protocol InstagramLoginDelegate {
    func didLoginSuccessfully(_ info : [String : String])
}
class InstagramLoginViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var loginWebView: UIWebView!
    @IBOutlet weak var loginIndicator: UIActivityIndicatorView!
    
    var delegate:InstagramLoginDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loginWebView.delegate = self
        unSignedRequest()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    //MARK: - unSignedRequest
    func unSignedRequest () {
        let authURL = String(format: "%@?client_id=%@&redirect_uri=%@&response_type=token&scope=%@&DEBUG=True", arguments: [INSTAGRAM_AUTH_URL,INSTAGRAM_CLIENT_ID,INSTAGRAM_REDIRECT_URI, INSTAGRAM_SCOPE ])
        let urlRequest =  URLRequest(url: URL(string: authURL)!)
        loginWebView.loadRequest(urlRequest)
    }
    
    // MARK: - UIWebViewDelegate
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return checkRequestForCallbackURL(request: request)
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        loginIndicator.isHidden = false
        loginIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("Instagram loading finished")
        loginIndicator.isHidden = true
        loginIndicator.stopAnimating()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print("Instagram loading failed error : \(error.localizedDescription)")
//        self.view.makeToast(error.localizedDescription)
        loginIndicator.isHidden = true
        loginIndicator.stopAnimating()
    }
    
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func checkRequestForCallbackURL(request: URLRequest) -> Bool {
        
        let requestURLString = (request.url?.absoluteString)! as String
        print("Instagram Request url = \(requestURLString)\n")
        if requestURLString.hasPrefix(INSTAGRAM_REDIRECT_URI) {
            let range: Range<String.Index> = requestURLString.range(of: "#access_token=")!
            handleAuth(authToken: requestURLString.substring(from: range.upperBound))
            return false;
        }
        return true
    }
    
    func handleAuth(authToken: String)  {
        print("Instagram authentication token ==", authToken)
        let requestUrl = "\(INSTAGRAM_USER_ENDPOINTS)\(authToken)"
        ApiManager.sharedInstance.getInstagramUserCredentials(url: requestUrl) { (response, errorMsg) in
            if response != nil {
                let instagramId = response!["id"].stringValue
                
                // Get first and last name
                let fullname = response!["full_name"].stringValue
                var firstname = ""
                var lastname = ""
                var components = fullname.components(separatedBy: " ")
                if components.count > 0 {
                    firstname = components.removeFirst()
                    lastname  = components.joined(separator: "")
                }
                
                let profilePicture = response!["profile_picture"].stringValue
                let socialInfo : [String : String] = [
                    "social_id" : instagramId,
                    "social_email" : "",
                    "social_firstname" : firstname,
                    "social_lastname" : lastname,
                    "social_avatar" : profilePicture,
                    "social_type" : "instagram",
                    "token" : authToken
                ]
                print(socialInfo)
                
                self.dismiss(animated: true, completion: {
                    self.delegate.didLoginSuccessfully(socialInfo)
                })                
            }
            else{
                self.showSimpleAlert(title: "Instagram Login Error", message: errorMsg, complete: {
//                    self.navigationController?.popViewController(animated: true)
                })
            }
        }
    }
}
