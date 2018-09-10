//
//  MateChallengeViewController.swift
//  MateflickPhotobank
//
//  Created by Panda on 5/27/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit
import CHIPageControl
import Toast_Swift

class MateChallengeViewController: UIViewController {

    @IBOutlet weak var challengeTableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    @IBOutlet weak var pageControl: CHIPageControlAji!
    @IBOutlet weak var scrollView: UIScrollView!
    let totalPages = 4
    
    var currentPage = 1
    var ITEM_CHALLENGE_COUNT = 20
    
    var upcomingChallenges : [ChallengeData] = [] {
        didSet {
            challengeTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        self.navigationItem.title = "My PhotoBank"
        self.challengeTableView.tableFooterView = UIView()
        
        // create the Add Challenge button
//        let addImage : UIImage = UIImage(named: "green_plus")!
//        let addButton = UIButton(type: .custom)
//        addButton.setImage(addImage, for: .normal)
//        addButton.addTarget(self, action: #selector(MateChallengeViewController.createChallenge(_:)), for:.touchUpInside)
//        addButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
//        addButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
//        
//        let addChallengeBarButton = UIBarButtonItem(customView: addButton)
//        self.navigationItem.rightBarButtonItem = addChallengeBarButton
        
//        self.scrollView.delegate = self
//        self.configureScrollView()
//        self.configurePageControl()
        
        self.loadUpcomingChallenges()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func loadUpcomingChallenges(){
        if !Reachability.isConnectedToNetwork() {
            self.showNoInternetAlert()
            return
        }
        
        self.showLoadingProgress(view: self.navigationController?.view)
        let params : [String: Any] = [
            "page" : currentPage,
            "pageSize" : ITEM_CHALLENGE_COUNT
        ]
        
        ApiManager.sharedInstance.getUpcomingChallenge(params) { (challenges, errorMsg) in
            DispatchQueue.main.async {
                self.dismissLoadingProgress(view: self.navigationController?.view)
                if challenges != nil {
                    self.upcomingChallenges = challenges!
                    if self.upcomingChallenges.count == 0 {
                        self.emptyView.isHidden = false
                    }
                    else {
                        self.emptyView.isHidden = true
                    }
                }
                else{
                    self.showSimpleAlert(title: "", message: errorMsg, complete: nil)
                    
                    if self.upcomingChallenges.count == 0 {
                        self.emptyView.isHidden = false
                    }
                }
            }
        }
    }
    
    @IBAction func reloadEvents(_ sender: Any) {
        loadUpcomingChallenges()
    }
    
    func configureScrollView(){
        // Enable paging.
        scrollView.isPagingEnabled = true
        
        // Set the following flag values.
        scrollView.scrollsToTop = false
        
        // Set the scrollview content size.
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(totalPages), height: scrollView.frame.size.height)
        
        // Load the TestView view from the OnBoardView.xib file and configure it properly.
        for view in self.scrollView.subviews {
            view.removeFromSuperview()
        }
        
        for idx in 0..<totalPages {
            // Load the TestView view.
            let thumbImage : UIImageView = UIImageView(frame: CGRect(x: CGFloat(idx) * scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height))
            
            // Set the proper message to the onboard view's image.
            thumbImage.image = #imageLiteral(resourceName: "sample")
            thumbImage.contentMode = .scaleAspectFill
            
            // Add the test view as a subview to the scrollview.
            scrollView.addSubview(thumbImage)
        }
    }
    
    // Setup the page control
    func configurePageControl() {
        // Set the total pages to the page control.
        pageControl.numberOfPages = totalPages
        
        // Set the initial page.
        pageControl.progress = 0
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // Create the new challenge
    @objc func createChallenge(_ sender: Any) {
        if let createChallengeVC = self.storyboard?.instantiateViewController(withIdentifier: "CreateChallengeVC") as? CreateChallengeViewController {
            self.navigationController?.pushViewController(createChallengeVC, animated: true)
        }
    }
    
    // Challenge Info
    func showInformationPage(_ challengeData : ChallengeData){
        if let challengeInfoVC = self.storyboard?.instantiateViewController(withIdentifier: "ChallengeInfoVC") as? ChallengeInfoViewController {
            challengeInfoVC.currentChallenge = challengeData
            self.navigationController?.pushViewController(challengeInfoVC, animated: true)
        }
    }
}

extension MateChallengeViewController : UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.tag == 101 {
            // Calculate the new page index depending on the content offset.
            let currentPage = floor(scrollView.contentOffset.x / UIScreen.main.bounds.size.width)
            
            // change the page position
            self.pageControl.set(progress: Int(currentPage), animated: true)
        }
    }
}

extension MateChallengeViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.upcomingChallenges.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : ChallengeTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ChallengeTableViewCell", for: indexPath) as! ChallengeTableViewCell
        let challenge  = self.upcomingChallenges[indexPath.row]
        
        cell.setChallengeDate(challenge)
        cell.delegate = self
        return cell
    }
}

extension MateChallengeViewController : ChallengeTableViewDelegate {
    func didJoinChallenge(cell: ChallengeTableViewCell) {
        if !Reachability.isConnectedToNetwork() {
            self.showNoInternetAlert()
            return
        }
        
        let challengeId = cell.challenge.id
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
    
    func didLikeChallenge(cell: ChallengeTableViewCell) {
        
    }
    
    func didShowChallengeInfo(cell: ChallengeTableViewCell) {
        self.showInformationPage(cell.challenge)
    }
}

