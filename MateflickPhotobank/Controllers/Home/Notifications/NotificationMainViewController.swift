//
//  NotificationMainViewController.swift
//  MateflickPhotobank
//
//  Created by Panda on 5/27/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class NotificationMainViewController: ButtonBarPagerTabStripViewController {

    override func viewDidLoad() {
        self.initButtonBar()
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setNavigationBarItem()
    }
    

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let voteVC = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVotesVC") as! NotificationVotesViewController
        let paroleVC = self.storyboard?.instantiateViewController(withIdentifier: "NotificationParoleVC") as! NotificationParoleViewController
        return [voteVC, paroleVC]
    }
    
    func initButtonBar(){
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.buttonBarItemTitleColor = UIColor.init(red: 50/255.0, green: 118/255.0, blue: 181/255.0, alpha : 1)
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 15)
        
        settings.style.selectedBarBackgroundColor = UIColor.init(red: 50/255.0, green: 118/255.0, blue: 181/255.0, alpha : 1)
        settings.style.selectedBarHeight = 2.0
        
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
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
