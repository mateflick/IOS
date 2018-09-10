//
//  ProfileViewController.swift
//  MateflickPhotobank
//
//  Created by Panda on 5/27/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit
import SDWebImage

class ProfileViewController: UIViewController {

    @IBOutlet weak var albumCollectionView: UICollectionView!
    @IBOutlet weak var profileImageView: CircleImageView!
    
    @IBOutlet weak var username: UILabel!
    
    @IBOutlet weak var photoCount: UILabel!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var skillLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingsLabel: UILabel!
    
    @IBOutlet weak var usedSpaceLabel: UILabel!
    
    let minimumInteritemSpacing : CGFloat = 10.0
    let columnCount = 2
    
    var currentPage = 1
    var ITEM_COUNT_PER_PAGE = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.loadProfileInformation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setNavigationBarItem()
    }
    
    // Get profile information
    func loadProfileInformation(){
        if !Reachability.isConnectedToNetwork() {
            return
        }
        
        self.showLoadingProgress(view: self.navigationController?.view)
        ApiManager.sharedInstance.getUserProfile { (success, errorMsg) in
            DispatchQueue.main.async {
                self.dismissLoadingProgress(view : self.navigationController?.view)
                if success {
                    self.updateUI()
                }
                else{
                    self.showSimpleAlert(title: "", message: errorMsg, complete: nil)
                }
            }
        }
        
        if UserInfo.sharedInstance.myEvents.count == 0 {
            if !Reachability.isConnectedToNetwork() {
                return
            }
            
            // load my events
            DispatchQueue(label: "LoadMyEvents").async {
                ApiManager.sharedInstance.getUpcomingEvents(self.currentPage, pageSize: self.ITEM_COUNT_PER_PAGE, userId: UserInfo.sharedInstance.userId!) { (eventArray, errorMsg) in
                    DispatchQueue.main.async {
                        if eventArray != nil {
                            UserInfo.sharedInstance.myEvents = eventArray!
                            self.albumCollectionView.reloadData()
                        }
                        else{
                            self.view.makeToast(errorMsg ?? "Failed to load your events")
                        }
                    }
                }
            }
        }
    }
    
    // Update UI
    func updateUI(){
        self.username.text          = "\(UserInfo.sharedInstance.userdata.firstName!) \(UserInfo.sharedInstance.userdata.lastName!)"
        self.photoCount.text        = "\(UserInfo.sharedInstance.userdata.photos)"
        self.likeCount.text         = "\(UserInfo.sharedInstance.userdata.likes)"
        self.followersLabel.text    = "\(UserInfo.sharedInstance.userdata.followers)"
        self.followingsLabel.text   = "\(UserInfo.sharedInstance.userdata.followings)"
        self.skillLabel.text        = "\(UserInfo.sharedInstance.userdata.skills)"
        
        self.usedSpaceLabel.text = "\(UserInfo.sharedInstance.userdata.usedSpace) GB"
        
        if !UserInfo.sharedInstance.userdata.userImage.isEmpty {
            self.profileImageView.sd_setImage(with: URL(string: ApiManager.sharedInstance.getUserProfileImagePath(UserInfo.sharedInstance.userdata.userImage)), placeholderImage: #imageLiteral(resourceName: "avatar"), options: SDWebImageOptions.continueInBackground, completed: nil)
        }
    }
    
    @IBAction func onAddAvatarImage(_ sender: Any) {
        // Show the Actionsheet from taking photo from Gallery or Camera
        let alertVC = UIAlertController(title: "", message: "Upload the profile picture", preferredStyle: .actionSheet)
        let galleryAction = UIAlertAction(title: "Add from Gallery", style: .default) { (action) in
            self.openPhotoLibrary(self)
        }
        
        let cameraAction = UIAlertAction(title: "Use camera", style: .default) { (action) in
            self.openCamera(self)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertVC.addAction(galleryAction)
        alertVC.addAction(cameraAction)
        alertVC.addAction(cancelAction)
        
        self.present(alertVC, animated: true, completion: nil)
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

extension ProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancelled to pick image")
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("Picked Image")
        if let pickerdImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImageView.image = pickerdImage.resize(toTargetSize: CGSize(width: 200, height: 200))
            
            // Save the user image into local
            self.saveUserImage(profileImageView.image!) { (imageURL) in
                if imageURL != nil {
                    DispatchQueue(label: "UploadProfileImage").async {
                        ApiManager.sharedInstance.uploadProfileImage(with: imageURL!, complete: { (success, errorMsg) in
                            if success {
                                print("Successfully uploaded user image")
                            }
                            else{
                                print("Failed to upload user image : \(errorMsg ?? "")")
                            }
                        })
                    }
                }
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
}

extension ProfileViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : MyEventCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyEventCollectionViewCell", for: indexPath) as! MyEventCollectionViewCell
        
        let event = UserInfo.sharedInstance.myEvents[indexPath.row]
        cell.setEvent(event)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return UserInfo.sharedInstance.myEvents.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth : CGFloat
        let cellHeight : CGFloat
        
        cellWidth = (collectionView.frame.size.width - minimumInteritemSpacing) / (CGFloat)(columnCount)
        cellHeight = cellWidth * 3 / 4.0 // W:H = 4 : 3
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumInteritemSpacing
    }
}
