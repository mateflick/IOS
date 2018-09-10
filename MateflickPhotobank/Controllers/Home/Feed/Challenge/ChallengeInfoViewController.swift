//
//  ChallengeInfoViewController.swift
//  MateflickPhotobank
//
//  Created by Panda on 6/22/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit
import Toast_Swift

class ChallengeInfoViewController: UIViewController {
    
    var currentChallenge : ChallengeData!
    @IBOutlet weak var challengeTitle: UILabel!
    @IBOutlet weak var creatorImageView: CircleImageView!
    @IBOutlet weak var votesLabel: UILabel!
    @IBOutlet weak var remainingDaysLabel: UILabel!
    @IBOutlet weak var prizeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UITextView!
    @IBOutlet weak var challengeCoverImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.challengeTitle.text = currentChallenge.name
        self.descriptionLabel.text = currentChallenge.challengeDescription
        self.prizeLabel.text = "$\(currentChallenge.prize) Prize"
        self.votesLabel.text = "\(currentChallenge.votes) Votes"
        
        if self.currentChallenge.endDate != nil {
            let endDate = Date(milliseconds: Int(self.currentChallenge.endDate)!)
            let remainingDays = Date().getRemainingDays(to: endDate)
            let suffix = remainingDays > 1 ? "days left" : "day left"
            self.remainingDaysLabel.text = "\(remainingDays) \(suffix)"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func voteChallenge(_ sender: Any) {
        
    }
    
    // Join to current challenge
    @IBAction func joinChallenge(_ sender: Any) {
        if !Reachability.isConnectedToNetwork() {
            self.showNoInternetAlert()
            return
        }
        
        let challengeId = currentChallenge.id
        self.showLoadingProgress(view: self.navigationController?.view, label: "Joining...")
        ApiManager.sharedInstance.joinChallenge(challengeId: challengeId!, userId: UserInfo.sharedInstance.userId!) { (success, errorMsg) in
            DispatchQueue.main.async {
                self.dismissLoadingProgress(view: self.navigationController?.view)
                if success {
                    self.view.makeToast("Success")
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
