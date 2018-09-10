//
//  ContainerViewController.swift
//  MateflickPhotobank
//
//  Created by Panda on 6/21/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift

class ContainerViewController: SlideMenuController {

    override func awakeFromNib() {
        // set the scale of content view
        SlideMenuOptions.contentViewScale = 1
        
        // set the left menu and main view controller
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "MainTabVC") {
            self.mainViewController = controller
        }
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "LeftMenuVC") {
            self.leftViewController = controller
        }
        
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

}
