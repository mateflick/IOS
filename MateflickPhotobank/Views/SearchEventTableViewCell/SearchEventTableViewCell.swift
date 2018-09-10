//
//  SearchEventTableViewCell.swift
//  MateflickPhotobank
//
//  Created by Panda on 7/18/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit
import SDWebImage

class SearchEventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var eventCovertImageView: UIImageView!
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var moneyButton: UIButton!
    
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    
    var event : EventData!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setEvent(_ event:EventData) {
        self.event = event        
        self.userImageView.sd_setImage(with: URL(string: ApiManager.sharedInstance.getUserProfileImagePath(event.userId)), placeholderImage: #imageLiteral(resourceName: "avatar"), options: SDWebImageOptions.continueInBackground, completed: nil)
        self.eventTitleLabel.text = event.name
        
        if !event.coverImageId.isEmpty {
            self.eventCovertImageView.sd_setImage(with: URL(string: ApiManager.sharedInstance.getImagePath(event.coverImageId)), completed: nil)
        }        
    }
    
    @IBAction func shareEvent(_ sender: Any) {
        
    }
    
    @IBAction func likeEvent(_ sender: Any) {
        
    }
    
    @IBAction func buyOrSellEvent(_ sender: Any) {
        
    }
    
    @IBAction func followUser(_ sender: Any) {
        
    }
    
}
