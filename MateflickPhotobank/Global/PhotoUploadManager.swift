//
//  PhotoUploadManager.swift
//  MateflickPhotobank
//
//  Created by Panda on 7/8/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit
import Photos
import MBProgressHUD

class PhotoUploadManager: NSObject {
    static var sharedInstance : PhotoUploadManager = {
        var instance = PhotoUploadManager()
        return instance
    }()
    
    var selectedAssets : [PHAsset] = []
    var downloadedURLs : [URL] = []
    var uploadMediaUrls : [URL] = []
    
    var mediaId: String!
    
    // Download the assets into local
    func downloadAssets(assets:[PHAsset], complete:@escaping(([URL]) -> Void)){
        self.downloadedURLs.removeAll()
        self.selectedAssets = assets
        if selectedAssets.count > 0 {
            DispatchQueue(label: "DownloadAssets").async {
                self.downloadOneAssetFromPhotos(self.selectedAssets[0], index: 0, complete: complete)
            }
        }
    }
    
    func downloadOneAssetFromPhotos(_ asset : PHAsset, index: Int, complete:@escaping(([URL]) -> Void)){
        
        // Get the current authorization state.
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == PHAuthorizationStatus.authorized) {
            // Access has been granted.
            var extensionString = ""            
            if asset.mediaType == .image {
                let option = PHImageRequestOptions()
                option.isSynchronous = true
                option.isNetworkAccessAllowed = true
                
                PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: option, resultHandler: { (image, info) in
                    // get extension of video file
                    var imageFileName = ""
                    if let fileName = (info?["PHImageFileURLKey"] as? NSURL)?.lastPathComponent {
                        extensionString = fileName.fileExtension()
                        imageFileName = fileName
                    }
                    else{
                        if asset.originalFilename != nil{
                            extensionString = asset.originalFilename!.fileExtension()
                        }
                        else{
                            extensionString = "jpg"
                        }
                        
                        imageFileName = String(format: "%@.%@", Date().currentDateTimeStamp, extensionString)
                    }
                    
                    // copy data to local
                    let filePath = self.getDirectory(MEDIA_PHOTO_FOLDER).appendingPathComponent(imageFileName)
                    print("*** download asset path = \(filePath.path)")
                    
                    if image != nil {
                        if let data = UIImageJPEGRepresentation(image!, 0.7) {
                            do {
                                try data.write(to: filePath, options: Data.WritingOptions.atomic)
                                
                                if FileManager.default.fileExists(atPath: filePath.path) {
                                    self.downloadedURLs.append(filePath)
                                }
                                else{
                                    
                                }
                                
                                if index == self.selectedAssets.count - 1 {
                                    if self.downloadedURLs.count == self.selectedAssets.count {
                                        print("*** Downloaded all files from Photos ***")
                                    }
                                    else{
                                        print("*** Failed Downloaded all files from Photos ***")
                                    }
                                    
                                    DispatchQueue.main.async {
                                        complete(self.downloadedURLs)
                                    }
                                }
                                else{
                                    self.downloadOneAssetFromPhotos(self.selectedAssets[index + 1], index: index + 1, complete: complete)
                                }
                            } catch {
                                print("download failed : \(error.localizedDescription)")
                            }
                        }
                    }
                    else {
                        print("Can't get the image asset!")
                        if index == self.selectedAssets.count - 1 {
                            DispatchQueue.main.async {
                                complete(self.downloadedURLs)
                            }
                        }
                        else{
                            self.downloadOneAssetFromPhotos(self.selectedAssets[index + 1], index: index + 1, complete: complete)
                        }
                    }
                })
            }            
        }
        else if (status == PHAuthorizationStatus.denied) {
            // Access has been denied.
            print("Access is denied")
            complete(self.downloadedURLs)
        }
    }
    
    // Upload images
    func uploadImages(_ imageURLs : [URL], isAlbum:Bool, mediaID: String, complete:@escaping(Bool) -> Void){
        self.mediaId = mediaID
        self.uploadMediaUrls = imageURLs
        DispatchQueue(label: "UploadImage").async {
            self.uploadOneMedia(self.uploadMediaUrls[0], index: 0, isAlbum: isAlbum, complete: complete)
        }        
    }
    
    func uploadOneMedia(_ fileURL : URL, index : Int, isAlbum:Bool, complete:@escaping(Bool) -> Void){
        ApiManager.sharedInstance.uploadImageToGallery( mediaId, isAlbum: isAlbum, imageURL: fileURL, complete: { (success, errorMsg) in
            if success {
                print("*** Success : Upload image ***\n")
            }
            else{
                print("*** Failed : Upload image *** \(errorMsg!)\n")
            }
            
            // Delete the image in local
            self.deleteFileAtPath(fileURL)
            
            //check if all images are uploaded
            if index >= self.uploadMediaUrls.count - 1 {
                self.uploadMediaUrls.removeAll()
                DispatchQueue.main.async {
                    complete(true)
                }
            }
            else{
                self.uploadOneMedia(self.uploadMediaUrls[index + 1], index: index + 1, isAlbum: isAlbum, complete: complete)
            }
        })
    }
    
    // get directory path
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    // get event directory
    func getDirectory (_ dirName : String) -> URL{
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dirUrl = documentsDirectory.appendingPathComponent(dirName)
        if !FileManager.default.fileExists(atPath: dirUrl.path) {
            do{
                try FileManager.default.createDirectory(at: dirUrl, withIntermediateDirectories: true, attributes: nil)
                return dirUrl
            }catch {
                NSLog("Couldn't create directory")
            }
        }
        
        NSLog("Created directory path  = \(dirUrl.path)")
        return dirUrl
    }
    
    func deleteFileAtPath(_ fileUrl : URL){
        do {
            try FileManager.default.removeItem(at: fileUrl)
            print("*** Deleted file : path = \(fileUrl.path)")
        } catch {
            print("*** Could not delete file: \(error)")
        }
    }
    
    // Show the MBProgressHUD
    func showLoadingProgress(view: UIView!, label: String = "Processing...") -> Void {
        let loadingHud = MBProgressHUD.showAdded(to: view, animated: true)
        loadingHud.bezelView.backgroundColor = UIColor.black
        loadingHud.contentColor = UIColor.white
        loadingHud.label.text = NSLocalizedString(label, comment: "")
    }
    
    // Dimiss the MBProgressHUD
    func dismissLoadingProgress(view : UIView!) -> Void {
        MBProgressHUD.hide(for: view, animated: true)
    }
}
