//
//  LeftMenuViewController.swift
//  MateflickPhotobank
//
//  Created by Panda on 6/21/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit
import FBSDKLoginKit

enum LeftMenu: Int {
    case account = 0
    case policy
    case terms
    case help
    case tellAFriend
    case logout
}

class LeftMenuViewController: UIViewController {
    
    var accountViewController: UIViewController!
    var privacyViewController: UIViewController!
    var termsViewController: UIViewController!
    var helpViewController: UIViewController!
    

    @IBOutlet weak var menuTableView: UITableView!
    
    var menus : [String] = ["ACCOUNT", "Privacy Policy", "Terms and Condition", "HELP", "TELL A FRIEND", "Logout"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.menuTableView.tableFooterView = UIView()
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
    
    func changeViewController(_ menu: LeftMenu) {
        switch menu {
        case .account:
//            self.slideMenuController()?.changeMainViewController(self.accountViewController, close: true)
            break
        case .policy:
//            self.slideMenuController()?.changeMainViewController(self.privacyViewController, close: true)
            break
        case .terms:
//            self.slideMenuController()?.changeMainViewController(self.termsViewController, close: true)
            break
        case .help:
//            self.slideMenuController()?.changeMainViewController(self.helpViewController, close: true)
            break
        case .tellAFriend: // Social sharing
            break
        case .logout:            
            // Go to the login VC
            if FBSDKAccessToken.currentAccessTokenIsActive() { // logged in FB
                let loginManager = FBSDKLoginManager.init()
                loginManager.logOut()
            }
            
            self.deleteInstagramCookies()
            
            if let navigationController = self.navigationController {
                navigationController.popToRootViewController(animated: true)
            }
            break
        }
    }
    
    // Delete the cookies of Instagram
    func deleteInstagramCookies(){
        let cookieJar : HTTPCookieStorage = HTTPCookieStorage.shared
        for cookie in cookieJar.cookies! as [HTTPCookie]{
            NSLog("cookie.domain = %@", cookie.domain)
            
            if cookie.domain == "www.instagram.com" || cookie.domain == "api.instagram.com"{
                cookieJar.deleteCookie(cookie)
            }
        }
    }

}

extension LeftMenuViewController : UITableViewDataSource , UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let menu = LeftMenu(rawValue: indexPath.row) {
            self.changeViewController(menu)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "LeftMenuTableCell", for: indexPath)
        cell.textLabel?.text = menus[indexPath.row]
        cell.textLabel?.textColor = UIColor.white
        
        return cell
    }
}
