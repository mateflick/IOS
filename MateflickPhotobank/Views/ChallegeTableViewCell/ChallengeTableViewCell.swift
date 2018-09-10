//
//  ChallengeTableViewCell.swift
//  MateflickPhotobank
//
//  Created by Panda on 7/19/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit

protocol ChallengeTableViewDelegate {
    func didJoinChallenge(cell: ChallengeTableViewCell)
    func didShowChallengeInfo(cell : ChallengeTableViewCell)
    func didLikeChallenge(cell : ChallengeTableViewCell)
}

class ChallengeTableViewCell: UITableViewCell {

    @IBOutlet weak var remainingDaysLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var voteLabel: UILabel!
    @IBOutlet weak var prizeLabel: UILabel!
    
    var challenge : ChallengeData!
    var delegate : ChallengeTableViewDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setChallengeDate(_ data : ChallengeData){
        self.challenge = data
        
        self.voteLabel.text = "\(self.challenge.votes) votes"
        self.prizeLabel.text = "$ \(self.challenge.prize) prize"
        self.titleLabel.text = self.challenge.name
        
        if self.challenge.endDate != nil {
            let endDate = Date(milliseconds: Int(self.challenge.endDate)!)
            let remainingDays = Date().getRemainingDays(to: endDate)
            let suffix = remainingDays > 1 ? "days left" : "day left"
            self.remainingDaysLabel.text = "\(remainingDays) \(suffix)"
        }
    }
    
    @IBAction func joinChallenge(_ sender: Any) {
        if delegate != nil {
            delegate.didJoinChallenge(cell: self)
        }
    }
    
    @IBAction func showChallengeInfo(_ sender: Any) {
        if delegate != nil {
            delegate.didShowChallengeInfo(cell: self)
        }
    }
    
    @IBAction func likeChallenge(_ sender: Any) {
        if delegate != nil {
            delegate.didLikeChallenge(cell: self)
        }
    }
}
