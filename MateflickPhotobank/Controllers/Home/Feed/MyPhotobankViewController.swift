//
//  MyPhotobankViewController.swift
//  MateflickPhotobank
//
//  Created by Panda on 5/27/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit

class MyPhotobankViewController: UIViewController {

    @IBOutlet weak var photosCollectionView: UICollectionView!
       
    @IBOutlet weak var buyMoreView: UIView!
    @IBOutlet weak var photoSwapView: UIView!
    @IBOutlet weak var galleryView: UIView!
    @IBOutlet weak var eventsView: UIView!
    @IBOutlet weak var familyFriendsView: UIView!
    @IBOutlet weak var photographersView: UIView!    
    @IBOutlet weak var photographerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        self.navigationItem.title = "My PhotoBank"
        
        // Buy More Space
        let buyMoreGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectedBuyMore))
        buyMoreView.addGestureRecognizer(buyMoreGesture)
        buyMoreView.isUserInteractionEnabled = true
        
        // Photo Swap
        let photoSwapGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectedPhotoSwap))
        photoSwapView.addGestureRecognizer(photoSwapGesture)
        photoSwapView.isUserInteractionEnabled = true
        
        // Gallery
        let galleryGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectedGallery))
        galleryView.addGestureRecognizer(galleryGesture)
        galleryView.isUserInteractionEnabled = true
        
        
        // Events
        let eventsGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectedEvents))
        eventsView.addGestureRecognizer(eventsGesture)
        eventsView.isUserInteractionEnabled = true
        
        // Family & Friends
        let familyGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectedFamilyFriends))
        familyFriendsView.addGestureRecognizer(familyGesture)
        familyFriendsView.isUserInteractionEnabled = true
        
        // My Photographers
        let photographerGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectedPhotographers))
        photographersView.addGestureRecognizer(photographerGesture)
        photographersView.isUserInteractionEnabled = true
        if UserInfo.sharedInstance.userdata.type == UserType.User {
            photographerLabel.text = "My Photographers"
        }
        else{
            photographerLabel.text = "My Users"
        }
        
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

    @objc func selectedBuyMore (){
        // Go to BuyMore page
        if let buyMoreVC = self.storyboard?.instantiateViewController(withIdentifier: "BuyMoreSpaceVC") as? BuyMoreSpaceViewController {
            self.navigationController?.pushViewController(buyMoreVC, animated: true)
        }
        
    }
    
    // PhotoSwap
    @objc func selectedPhotoSwap (){
        if let swapVC = self.storyboard?.instantiateViewController(withIdentifier: "PhotoSwapVC") as? PhotoSwapViewController {
            self.navigationController?.pushViewController(swapVC, animated: true)
        }
    }
    
    // Gallery
    @objc func selectedGallery (){
        if let galleryVC = self.storyboard?.instantiateViewController(withIdentifier: "GalleryVC") as? GalleryViewController {
            self.navigationController?.pushViewController(galleryVC, animated: true)
        }
    }
    
    // Called if selected Events button
    @objc func selectedEvents (){
        if let eventsVC = self.storyboard?.instantiateViewController(withIdentifier: "EventsVC") as? EventsViewController {
            self.navigationController?.pushViewController(eventsVC, animated: true)
        }
    }
    
    // Family & Friends
    @objc func selectedFamilyFriends() {
        if let friendsVC = self.storyboard?.instantiateViewController(withIdentifier: "MyFriendsVC") as? MyFriendsViewController {            
            self.navigationController?.pushViewController(friendsVC, animated: true)
        }
    }
    
    // My Photographers
    @objc func selectedPhotographers (){
        if let photographersVC = self.storyboard?.instantiateViewController(withIdentifier: "MyPeopleVC") as? MyPeopleViewController {
            photographersVC.screentype = ScreenType.photographers
            self.navigationController?.pushViewController(photographersVC, animated: true)
        }
    }
}

extension MyPhotobankViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: TableCell.photoBankCollection, for: indexPath)
        
        return cell
    }   
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth : CGFloat
        let cellHeight : CGFloat
        
        cellWidth  = 160
        cellHeight = 110
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
