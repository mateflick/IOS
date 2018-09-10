//
//  FeedViewController.swift
//  MateflickPhotobank
//
//  Created by Panda on 5/27/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit
import SDWebImage

class FeedViewController: UIViewController {

    @IBOutlet weak var photobankButton: GradientRoundedButton!
    @IBOutlet weak var matechallengeButton: GradientRoundedButton!
    @IBOutlet weak var feedTableView: UITableView!
    
    var feeds : [TimelineData] = [] {
        didSet {
            self.feedTableView.reloadData()
        }
    }
    
    var currentPage : Int = 1
    var ITEM_COUNT_PER_PAGE : Int = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        photobankButton.layer.cornerRadius = 10
        photobankButton.clipsToBounds = true
        
        matechallengeButton.layer.cornerRadius = 10
        matechallengeButton.clipsToBounds = true
        
        self.feedTableView.tableFooterView = UIView()
        
        // load the feed data
        self.loadFeeds()
        
        // Notification for updating album
        NotificationCenter.default.addObserver(self, selector: #selector(FeedViewController.updatedAlbum(notification:)), name: Notification.Name("notification_edited_album"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setNavigationBarItem()
    }
    
    func loadFeeds(){
        if !Reachability.isConnectedToNetwork() {
            self.showNoInternetAlert()
            return
        }
        
        self.showLoadingProgress(view: self.navigationController?.view)
        ApiManager.sharedInstance.loadTimelineData(currentPage, pageSize: ITEM_COUNT_PER_PAGE) { (timelines, totalPages, errorMsg) in
            DispatchQueue.main.async {
                self.dismissLoadingProgress(view: self.navigationController?.view)
                if timelines != nil {
                    self.feeds = timelines!
                }
                else{
                    self.showSimpleAlert(title: "", message: errorMsg, complete: nil)
                }
            }
        }
    }
    
    @objc func updatedAlbum(notification:Notification){
        if Reachability.isConnectedToNetwork() {
            self.loadFeeds()
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

extension FeedViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : FeedTableCell = tableView.dequeueReusableCell(withIdentifier: TableCell.feed, for: indexPath) as! FeedTableCell
        cell.setData(self.feeds[indexPath.row])
        
        let createdDate = Date(milliseconds: (Int)(self.feeds[indexPath.row].createdDate)!)
        cell.createdTimeLabel.text = self.timeAgoSinceDate(createdDate, currentDate: Date(), numericDates: true)
        
        return cell
    }
}

class FeedTableCell : UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var createdTimeLabel: UILabel!
    @IBOutlet weak var albumImageView: UIImageView!
    
    var timelineData : TimelineData!
    func setData(_ data : TimelineData) {
        if !data.userInfo.userImage.isEmpty {
            avatarImageView.sd_setImage(with: URL(string: ApiManager.sharedInstance.getImagePath(data.userInfo.userImage)), completed: nil)
        }
        
        usernameLabel.text = "\(data.userInfo.firstname!) \(data.userInfo.surname!)"
        
        if !data.fileId.isEmpty {
            albumImageView.sd_setImage(with: URL(string: ApiManager.sharedInstance.getImagePath(data.fileId)), completed: nil)
        }        
    }
    
}
