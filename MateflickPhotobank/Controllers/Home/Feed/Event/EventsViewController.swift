//
//  EventsViewController.swift
//  MateflickPhotobank
//
//  Created by Panda on 6/16/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit
import Toast_Swift

class EventsViewController: UIViewController {

    @IBOutlet weak var eventCollectionView: UICollectionView!
    @IBOutlet weak var myEventCollectionView: UICollectionView!
    @IBOutlet weak var myEventLabel: UILabel!
    
    @IBOutlet weak var addEventButton: UIButton!
    @IBOutlet weak var pastEventButton: UIButton!
    
    @IBOutlet weak var emptyUpcomingEventsView: UIView!
    
    var currentPage = 1
    var ITEM_COUNT_PER_PAGE = 20
    
    var upcomingEvents : [EventData] = []{
        didSet{
            self.eventCollectionView.reloadData()
        }
    }
    
    var myEvents : [EventData] = []{
        didSet{
            self.myEventCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.loadUpcomingEvents()
        self.loadMyEvents()
        
        // Notification for new event
        NotificationCenter.default.addObserver(self, selector: #selector(createdNewEvent(notification:)), name: Notification.Name("notification_created_event"), object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        self.addEventButton.centerVertically(padding: 10)
        self.pastEventButton.centerVertically(padding: 10)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addNewEvent(_ sender: Any) {
    }
    
    @IBAction func showPastEvent(_ sender: Any) {
    }
    
    @objc func createdNewEvent(notification:Notification){
        self.loadUpcomingEvents()
        self.loadMyEvents()
    }
    
    // Load all upcoming events
    func loadUpcomingEvents(){
        if !Reachability.isConnectedToNetwork() {
            self.showNoInternetAlert()
            return
        }
        
        self.showLoadingProgress(view: self.navigationController?.view)
        ApiManager.sharedInstance.getUpcomingEvents(currentPage, pageSize: ITEM_COUNT_PER_PAGE) { (eventArray, errorMsg) in
            DispatchQueue.main.async {
                self.dismissLoadingProgress(view: self.navigationController?.view)
                if eventArray != nil {
                    self.upcomingEvents = eventArray!
                    self.updateEventsView()
                }
                else{
                    self.showSimpleAlert(title: "", message: errorMsg, complete: nil)
                    self.updateMyEventsView()
                }
            }
        }
    }
    
    func loadMyEvents(){
        if !Reachability.isConnectedToNetwork() {
            self.showNoInternetAlert()
            return
        }
        
        DispatchQueue(label: "LoadMyEvents").async {
            ApiManager.sharedInstance.getUpcomingEvents(self.currentPage, pageSize: self.ITEM_COUNT_PER_PAGE, userId: UserInfo.sharedInstance.userId!) { (eventArray, errorMsg) in
                DispatchQueue.main.async {
                    if eventArray != nil {
                        self.myEvents = eventArray!
                        UserInfo.sharedInstance.myEvents = eventArray!
                        self.updateMyEventsView()
                    }
                    else{
                        self.view.makeToast(errorMsg ?? "Failed to load your events")
                    }
                }
            }
        }
    }
    
    func updateEventsView(){
        if self.upcomingEvents.count == 0 {
            self.eventCollectionView.isHidden = true
            self.emptyUpcomingEventsView.isHidden = false
        }
        else{
            self.eventCollectionView.isHidden = false
            self.emptyUpcomingEventsView.isHidden = true
        }
    }
    
    func updateMyEventsView(){
        if self.myEvents.count == 0 {
            self.myEventCollectionView.isHidden = true
            self.myEventLabel.isHidden = true
        }
        else{
            self.myEventCollectionView.isHidden = false
            self.myEventLabel.isHidden = false
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

extension EventsViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        if collectionView.tag == 10 {
            let upcomingEventCell : EventCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCollectionViewCell", for: indexPath) as! EventCollectionViewCell
            let eventData = self.upcomingEvents[indexPath.row]
            upcomingEventCell.setEvent(eventData)
            
            return upcomingEventCell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyEventCollectionViewCell", for: indexPath) as! MyEventCollectionViewCell
            let eventData = self.myEvents[indexPath.row]
            cell.setEvent(eventData)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 10 {
            return self.upcomingEvents.count
        }
        else{
            return self.myEvents.count
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var cellWidth : CGFloat
        var cellHeight : CGFloat
        
        if collectionView.tag == 10 {
            cellWidth = collectionView.frame.size.width * 0.6
            cellHeight = 145
        }
        else{
            cellWidth = (collectionView.frame.size.width - 10) / 2
            cellHeight = cellWidth * 3 / 4.0
        }
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView.tag == 10 {
            return 0
        }
        else{
            return 10
        }
    }
}

class EventCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventLocationLabel: UILabel!
    @IBOutlet weak var groupLabel: UILabel!
    
    var eventData : EventData!
    func setEvent(_ event : EventData){
        self.eventTitleLabel.text = event.name
        self.eventLocationLabel.text = event.location
        
        if !event.coverImageId.isEmpty {
            let imagePath = ApiManager.sharedInstance.getImagePath(event.coverImageId)
            self.coverImageView.sd_setImage(with: URL(string: imagePath), completed: nil)
        }
    }
}

class MyEventCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var sellButton: UIButton!
    
    var eventData : EventData!
    func setEvent(_ event : EventData){
        self.eventTitleLabel.text = event.name
        
        if !event.coverImageId.isEmpty {
            let imagePath = ApiManager.sharedInstance.getImagePath(event.coverImageId)
            self.coverImageView.sd_setImage(with: URL(string: imagePath), completed: nil)
        }
    }
}



