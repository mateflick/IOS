//
//  GalleryPicturesViewController.swift
//  MateflickPhotobank
//
//  Created by Igor Ostriz on 09/10/2018.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit

class GalleryPhotosViewController: UIViewController {

    
    @IBOutlet weak var picturesCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    func getPicturesList(){
        if !Reachability.isConnectedToNetwork() {
            self.showNoInternetAlert()
            return
        }
        
//        self.showLoadingProgress(view: self.navigationController?.view)
//        let param : [String : Any] = [
//            "UserId" : UserInfo.sharedInstance.userId!,
//            "page" : pageNumber,
//            "pageSize" : 10
//        ]
//        ApiManager.sharedInstance.getAlbumArray(params: param) { (albums, page, totalPages, errorMsg) in
//            DispatchQueue.main.async {
//                self.dismissLoadingProgress(view: self.navigationController?.view)
//                if albums != nil {
//                    self.albums = albums!
//                    self.pageNumber = page
//                    self.totalPageNumber = totalPages
//                }
//                else{
//                    self.showSimpleAlert(title: "", message: errorMsg, complete: nil)
//                }
//            }
//        }
    }
}
