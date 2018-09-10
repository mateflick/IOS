//
//  TermsConditionsViewController.swift
//  MateflickPhotobank
//
//  Created by Panda on 5/26/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit

class TermsConditionsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        }
        else{
            self.dismiss(animated: true, completion: nil)
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
