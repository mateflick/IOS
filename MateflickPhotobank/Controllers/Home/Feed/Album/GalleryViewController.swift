//
//  GalleryViewController.swift
//  MateflickPhotobank
//
//  Created by Panda on 6/15/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit
import SDWebImage

class GalleryViewController: UIViewController {
    
    @IBOutlet weak var sharePhotoButton: UIButton!
    @IBOutlet weak var instagramPhotoButton: UIButton!
    @IBOutlet weak var facebookPhotoButton: UIButton!
    @IBOutlet weak var twitterPhotoButton: UIButton!
    
    @IBOutlet weak var albumCollectionView: UICollectionView!
    
    let minimumInteritemSpacing : CGFloat = 5
    
    var albums : [AlbumData] = []{
        didSet{
            self.albumCollectionView.reloadData()
        }
    }
    
    var pageNumber = 1
    var totalPageNumber : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.addCreateAlbumButton()
        
        // Notification for updating album
        NotificationCenter.default.addObserver(self, selector: #selector(GalleryViewController.updatedAlbum(notification:)), name: Notification.Name("notification_edited_album"), object: nil)
        
        // Notification for create album
        NotificationCenter.default.addObserver(self, selector: #selector(GalleryViewController.createdNewAlbum(notification:)), name: Notification.Name("notification_created_album"), object: nil)
        
        // load the album list
        self.getAlbumList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidLayoutSubviews() {
        
    }
    
    func addCreateAlbumButton(){
         //create the Add Challenge button
        let addImage : UIImage = UIImage(named: "green_plus")!
        let addButton = UIButton(type: .custom)
        addButton.setImage(addImage, for: .normal)
        addButton.addTarget(self, action: #selector(GalleryViewController.addAlbum), for:.touchUpInside)
        addButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        addButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)

        let addChallengeBarButton = UIBarButtonItem(customView: addButton)
        self.navigationItem.rightBarButtonItem = addChallengeBarButton
    }
    
    @objc func updatedAlbum(notification : Notification) {
//        if let usrinfo = notification.userInfo {
//            let updateAlbum = usrinfo["updated_album"] as! AlbumData
//            for album in albums {
//                if album.albumId == updateAlbum.albumId {
//                    let albumIndex = self.albums.index(of: album)!
//                    self.albums.remove(at: albumIndex)
//                    self.albums.insert(updateAlbum, at: albumIndex)
//                    break
//                }
//            }
//        }
        
        self.albumCollectionView.reloadData()
    }
    
    @objc func createdNewAlbum(notification : Notification){
        self.getAlbumList()
    }
    
    @objc func addAlbum(){
        if let newAlbumVC = self.storyboard?.instantiateViewController(withIdentifier: "CreateAlbumVC") as? CreateAlbumViewController {
            self.navigationController?.pushViewController(newAlbumVC, animated: true)
        }
    }
    
    func getAlbumList(){
        if !Reachability.isConnectedToNetwork() {
            self.showNoInternetAlert()
            return
        }
        
        self.showLoadingProgress(view: self.navigationController?.view)
        let param : [String : Any] = [
            "UserId" : UserInfo.sharedInstance.userId!,
            "page" : pageNumber,
            "pageSize" : 10
        ]
        ApiManager.sharedInstance.getAlbumArray(params: param) { (albums, page, totalPages, errorMsg) in
            DispatchQueue.main.async {
                self.dismissLoadingProgress(view: self.navigationController?.view)
                if albums != nil {
                    self.albums = albums!
                    self.pageNumber = page
                    self.totalPageNumber = totalPages
                }
                else{
                    self.showSimpleAlert(title: "", message: errorMsg, complete: nil)
                }
            }
        }
    }

    @IBAction func selectedSharePhotos(_ sender: Any) {
        
    }
    
    @IBAction func selectedInstagramPhotos(_ sender: Any) {
        
    }
    
    @IBAction func selectedFBPhotos(_ sender: Any) {
        
    }
    
    @IBAction func selectedTwitterPhotos(_ sender: Any) {
        
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



extension GalleryViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : GalleryAlbumCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryAlbumCollectionViewCell.cellIdentifier, for: indexPath) as! GalleryAlbumCollectionViewCell
        let albumData = self.albums[indexPath.row]
        if !albumData.coverImageId.isEmpty {
            let imageLink = "\(ApiManager.sharedInstance.baseURL)\(ApiManager.sharedInstance.downloadImage)\(albumData.coverImageId)"
            print("CoverImage path = \(imageLink)")
            cell.albumThumbImageView.sd_setImage(with: URL(string: imageLink), completed: nil)
        }
        
        cell.albumTitleLabel.text = albumData.title
        
        let attrStr = NSMutableAttributedString(string: albumData.albumDescription)
        let searchPattern = "@"
        var ranges: [NSRange] = [NSRange]()
        
        let regex = try! NSRegularExpression(pattern: searchPattern, options: [])
        ranges = regex.matches(in: attrStr.string, options: [], range: NSMakeRange(0, attrStr.string.count)).map {$0.range}
        if ranges.count > 0 {
            cell.countLabel.text = "\(ranges.count)"
        }
        else{
            cell.countLabel.text = "0"
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let selectedAlbum = self.albums[indexPath.row]
        
        if let editalbumVC = self.storyboard?.instantiateViewController(withIdentifier: "EditAlbumVC") as? EditAlbumViewController {
            editalbumVC.currentAlbum = selectedAlbum
            self.navigationController?.pushViewController(editalbumVC, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.albums.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth : CGFloat
        let cellHeight : CGFloat
        let columnCount = 2
        
        cellWidth = (collectionView.frame.size.width - minimumInteritemSpacing * 2) / (CGFloat)(columnCount)
        cellHeight = cellWidth * 9 / 16.0 // W:H = 4 : 3
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumInteritemSpacing
    }
}

class GalleryAlbumCollectionViewCell : UICollectionViewCell {
    static let cellIdentifier = "GalleryAlbumCollectionViewCell"
    @IBOutlet weak var albumThumbImageView: UIImageView!
    @IBOutlet weak var albumTitleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
}
