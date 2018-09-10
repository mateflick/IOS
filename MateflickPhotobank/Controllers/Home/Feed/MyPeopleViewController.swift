//
//  MyPeopleViewController.swift
//  MateflickPhotobank
//
//  Created by Panda on 6/15/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit
import SDWebImage

enum ScreenType {
    case friends
    case users
    case photographers
}

class MyPeopleViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var suggestCollectionView: UICollectionView!
    @IBOutlet weak var emptyUserView: UIView!
    @IBOutlet weak var emptySuggestionView: UIView!
    @IBOutlet weak var emptyUserLabel: UILabel!
    @IBOutlet weak var emptySuggestionLabel: UILabel!
    
    var screentype : ScreenType!
    var currentPage = 1
    let ITEM_PAGE_COUNT = 20
    
    var users : [MyFriendData] = []{
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var suggestionUsers : [UserData] = [] {
        didSet{
            self.suggestCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
                
        var placeholderString = ""
        if UserInfo.sharedInstance.userdata.type == UserType.User { // User
            navigationItem.title = "My Photographers"
            placeholderString = PLACEHOLDER_SEARCH_PHOTOGRAPHER
            emptyUserLabel.text = "No photographers found"
            emptySuggestionLabel.text = "No photographers found"
        }
        else {
            navigationItem.title = "My Users" // Photographer
            placeholderString = PLACEHOLDER_SEARCH_USERS
            emptyUserLabel.text = "No users found"
            emptySuggestionLabel.text = "No users found"
        }
        
        let placeholderAttributes = [NSAttributedStringKey.foregroundColor :UIColor.gray]
        let attrString = NSAttributedString(string: placeholderString, attributes: placeholderAttributes)
        let searchTextField = searchBar.value(forKey: "searchField") as? UITextField
        searchTextField?.attributedPlaceholder = attrString
        
        self.loadSearchResult()
        self.loadSuggestedUsers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadSearchResult(){
        if !Reachability.isConnectedToNetwork() {
            self.showNoInternetAlert()
            return
        }
        
        self.showLoadingProgress(view: self.navigationController?.view)
        ApiManager.sharedInstance.searchUsers(keyword: self.searchBar.text!, userType: UserInfo.sharedInstance.userdata.type, pageNumber: currentPage, pageSize: ITEM_PAGE_COUNT) { (userArray, errorMsg) in
            DispatchQueue.main.async {
                self.dismissLoadingProgress(view: self.navigationController?.view)
                if userArray != nil {
                    self.users = userArray!
                    self.updateSearchUI()
                }
                else{
                    self.showSimpleAlert(title: "", message: errorMsg, complete: nil)
                    self.updateSearchUI()
                }
            }
        }
    }
    
    func loadSuggestedUsers(){
        DispatchQueue(label: "SuggestionUserList").async {
            ApiManager.sharedInstance.getSuggestUsers(userType: UserInfo.sharedInstance.userdata.type, pageNumber: self.currentPage, pageSize: self.ITEM_PAGE_COUNT) { (userArray, errorMsg) in
                DispatchQueue.main.async {
                    if userArray != nil {
                        self.suggestionUsers = userArray!
                        self.updateSuggestionUI()
                    }
                    else{
                        self.showSimpleAlert(title: "", message: errorMsg, complete: nil)
                        self.updateSuggestionUI()
                    }
                }
            }
        }
    }
    
    func updateSearchUI(){
        if self.users.count == 0 {
            self.emptyUserView.isHidden = false
        }
        else{
            self.emptyUserView.isHidden = true
        }
    }
    
    func updateSuggestionUI(){
        if self.suggestionUsers.count == 0 {
            self.emptySuggestionView.isHidden = false
        }
        else{
            self.emptySuggestionView.isHidden = true
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

extension MyPeopleViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : PeopleTableViewCell = tableView.dequeueReusableCell(withIdentifier: PeopleTableViewCell.cellIdentifier, for: indexPath) as! PeopleTableViewCell
        let userData = self.users[indexPath.row]
        cell.setUserData(userData)
        cell.statusButton.isHidden = true
        
        return cell
    }
}

extension MyPeopleViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : SuggestPeopleCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: SuggestPeopleCollectionViewCell.cellIdentifier, for: indexPath) as! SuggestPeopleCollectionViewCell
        
        let user = self.suggestionUsers[indexPath.row]
        cell.setUserData(user)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.suggestionUsers.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth : CGFloat
        let cellHeight : CGFloat
        
        cellWidth  = 125
        cellHeight = 162
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
}

class PeopleTableViewCell : UITableViewCell {
    static let cellIdentifier = "PeopleTableViewCell"
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var statusButton: UIButton!
    
    var user : MyFriendData!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setUserData(_ user:MyFriendData) {
        self.user = user
        
        if !self.user.userInfo.userImage.isEmpty {
            self.avatarImageView.sd_setImage(with: URL(string: ApiManager.sharedInstance.getImagePath(self.user.userInfo.userImage))!, completed: nil)
        }
        
        self.usernameLabel.text = "\(self.user.userInfo.firstname!) \(self.user.userInfo.surname!)"
        self.roleLabel.text = self.user.userInfo.userType == UserType.User ? "User" : "Photographer"
        self.countryLabel.text = "Unknown"
    }
}

class SuggestPeopleCollectionViewCell : UICollectionViewCell {
    static let cellIdentifier = "SuggestPeopleCollectionViewCell"
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userTypeLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    var user : UserData!
    func setUserData(_ user:UserData) {
        self.user = user
        
        if !self.user.userImage.isEmpty {
            self.avatarImageView.sd_setImage(with: URL(string: ApiManager.sharedInstance.getImagePath(self.user.userImage))!, completed: nil)
        }
        
        self.usernameLabel.text = "\(self.user.firstName!) \(self.user.lastName!)"
        self.userTypeLabel.text = self.user.type == UserType.User ? "User" : "Photographer"
    }
}


