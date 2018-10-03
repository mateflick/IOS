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
    
    var timer: Timer = Timer();
    var albums : [AlbumData] = []{
        didSet{
            self.albumCollectionView.reloadData()
        }
    }
    
    var pageNumber = 1
    var totalPageNumber : Int = 0
    var deleteMode = false
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.addCreateAlbumButton()
        
        // Notification for updating album
        NotificationCenter.default.addObserver(self, selector: #selector(GalleryViewController.updatedAlbum(notification:)), name: Notification.Name("notification_edited_album"), object: nil)
        
        // Notification for create album
        NotificationCenter.default.addObserver(self, selector: #selector(GalleryViewController.createdNewAlbum(notification:)), name: Notification.Name("notification_created_album"), object: nil)
        
        // Notification for delete album
        NotificationCenter.default.addObserver(self, selector: #selector(GalleryViewController.deleteAlbum(notification:)), name: Notification.Name("notification_delete_album"), object: nil)

        // create long press gesture
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(GalleryViewController.onLongPress))
        albumCollectionView.addGestureRecognizer(lpgr)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(GalleryViewController.onTap))
        view.addGestureRecognizer(tap)
        
        // load the album list
        self.getAlbumList()
    }

    
    
    
    
    
    
    func addCreateAlbumButton(){
         //create the Add Challenge button
        let addImage : UIImage = UIImage(named: "green_plus")!
        let addButton = UIButton(type: .custom)
        addButton.setImage(addImage, for: .normal)
        addButton.addTarget(self, action: #selector(GalleryViewController.addAlbum), for:.touchUpInside)
        addButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        addButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)

        let barButtonItem = UIBarButtonItem(customView: addButton)
        self.navigationItem.rightBarButtonItem = barButtonItem
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
    
    @objc func createdNewAlbum(notification : Notification) {
        self.getAlbumList()
    }
    
    @objc func deleteAlbum(notification: Notification) {
        let cell =  notification.object as! GalleryAlbumCollectionViewCell
        let albumData = cell.albumData

        let params : [String : Any] = [
            "UserId" : UserInfo.sharedInstance.userId,
            "GalleryId" : albumData?.albumId!
        ]
        
        self.showLoadingProgress(view: self.navigationController?.view, label: "Deleting album...")
        ApiManager.sharedInstance.removeAlbum(params) { (result, errorMsg) in
            DispatchQueue.main.async {
                self.dismissLoadingProgress(view: self.navigationController?.view)
                if result != nil {
                    
                    // find albumData in albums
                    
                    for album in self.albums {
                        if album.albumId == albumData!.albumId {
                            let albumIndex = self.albums.index(of: album)!
                            self.albums.remove(at: albumIndex)

                            if let idx = self.albumCollectionView.indexPath(for: cell) {
                                self.albumCollectionView.deleteItems(at: [idx])
                            }

                            break
                        }
                    }

                }
                else{
                    self.showSimpleAlert(title: "", message: errorMsg, complete: nil)
                }
            }
        }
        
    }
    

    @objc func addAlbum(){
        if let newAlbumVC = self.storyboard?.instantiateViewController(withIdentifier: "CreateAlbumVC") as? CreateAlbumViewController {
            self.navigationController?.pushViewController(newAlbumVC, animated: true)
        }
    }
    
    @objc func onLongPress(gestureRecognizer: UILongPressGestureRecognizer)
    {
        
        switch gestureRecognizer.state {
        case .began:
            print(".began")
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { (t) in
                t.invalidate()
                
                self.deleteMode = !self.deleteMode
                
                print("deleteMode:\(self.deleteMode)")
                
                for cell in self.albumCollectionView.visibleCells as! [GalleryAlbumCollectionViewCell] {
                    cell.deleteMode(self.deleteMode, animated:true)
                }
            })
            return
        case .changed:
            return
        default:
            print(gestureRecognizer.state)
            timer.invalidate()
        }

        
    }
    
    @objc func onTap(gestureRecognizer: UITapGestureRecognizer)
    {
        deleteMode = false
        for cell in self.albumCollectionView.visibleCells as! [GalleryAlbumCollectionViewCell] {
            cell.deleteMode(false, animated:true)
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
        cell.deleteMode(deleteMode)
        
        cell.albumData = albumData
        
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
    @IBOutlet weak var deleteButton: UIButton!
    
    weak var albumData: AlbumData?
    
    
    @IBAction func onDelete(_ sender: UIButton) {
        
        deleteMode(false)
        NotificationCenter.default.post(name: Notification.Name("notification_delete_album"), object: self)


    }
    
    
    
    func deleteMode(_ mode: Bool, animated: Bool = false)
    {
        let currentMode = deleteButton.alpha == 1
        
        if mode == currentMode {
            return
        }
        
        if animated == true {
            UIView.animate(withDuration: 0.35) {
                self.deleteButton.alpha = mode ? 1.0 : 0.0
            }
        }
        else {
            self.deleteButton.alpha = mode ? 1.0 : 0.0
        }

        wiggle(mode)
        
    }
    
    func wiggle(_ on: Bool, animated: Bool = true)
    {
        on ? startWiggle() : stopWiggle()
    }
    
    func startWiggle(duration: Double = 0.25, displacement: CGFloat = 1.0, degreesRotation: CGFloat = 2.0) {
        let negativeDisplacement = -1.0 * displacement
        let position = CAKeyframeAnimation.init(keyPath: "position")
        position.beginTime = 0.8
        position.duration = duration
        position.values = [
            NSValue(cgPoint: CGPoint(x: negativeDisplacement, y: negativeDisplacement)),
            NSValue(cgPoint: CGPoint(x: 0, y: 0)),
            NSValue(cgPoint: CGPoint(x: negativeDisplacement, y: 0)),
            NSValue(cgPoint: CGPoint(x: 0, y: negativeDisplacement)),
            NSValue(cgPoint: CGPoint(x: negativeDisplacement, y: negativeDisplacement))
        ]
        position.calculationMode = "linear"
        position.isRemovedOnCompletion = false
        position.repeatCount = Float.greatestFiniteMagnitude
        position.beginTime = CFTimeInterval(Float(arc4random()).truncatingRemainder(dividingBy: Float(25)) / Float(100))
        position.isAdditive = true
        
        let transform = CAKeyframeAnimation.init(keyPath: "transform")
        transform.beginTime = 2.6
        transform.duration = duration
        transform.valueFunction = CAValueFunction(name: kCAValueFunctionRotateZ)
        transform.values = [
            degreesToRadians(-1.0 * degreesRotation),
            degreesToRadians(degreesRotation),
            degreesToRadians(-1.0 * degreesRotation)
        ]
        transform.calculationMode = "linear"
        transform.isRemovedOnCompletion = false
        transform.repeatCount = Float.greatestFiniteMagnitude
        transform.isAdditive = true
        transform.beginTime = CFTimeInterval(Float(arc4random()).truncatingRemainder(dividingBy: Float(25)) / Float(100))
        
        self.layer.add(position, forKey: nil)
        self.layer.add(transform, forKey: nil)
    }
    
    private func degreesToRadians(_ x: CGFloat) -> CGFloat {
        return .pi * x / 180.0
    }

    func stopWiggle() {
        self.layer.removeAllAnimations()
    }
    
    
    override func prepareForReuse() {
        stopWiggle()
        deleteButton.alpha = 0
    }
}
