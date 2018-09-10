//
//  EditAlbumViewController.swift
//  MateflickPhotobank
//
//  Created by Panda on 7/12/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import UITextView_Placeholder
import Photos
import AssetsPickerViewController
import Toast_Swift

class EditAlbumViewController: UIViewController {

    @IBOutlet weak var albumTitleText: SkyFloatingLabelTextField!
    @IBOutlet weak var albumDescriptionText: UITextView!
    
    var cameraImage: UIImage?
    var selectedImageAssets : [PHAsset] = []
    var uploadImageURLs : [URL] = [] // the urls to be uploaded    
    
    var currentAlbum : AlbumData!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        albumDescriptionText.showDoneButtonOnKeyboard()
        albumDescriptionText.placeholder = "Album description..."
        albumDescriptionText.placeholderColor = UIColor(red: 154/255.0, green: 154/255.0, blue: 154/255.0, alpha: 1)
        
        albumTitleText.text = currentAlbum.title
        albumDescriptionText.text = currentAlbum.albumDescription
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func updateAlbum(_ sender: Any) {
        if !Reachability.isConnectedToNetwork() {
            self.showNoInternetAlert()
            return
        }
        
        let params : [String : Any] = [
            "Title" : albumTitleText.text!,
            "Description" : albumDescriptionText.text!,
            "GalleryId" : currentAlbum.albumId,
            "UserId" : UserInfo.sharedInstance.userId!
        ]
        
        self.showLoadingProgress(view: self.navigationController?.view, label :"Updating...")
        ApiManager.sharedInstance.updateAlbum(params) { (updatedAlbum, errorMsg) in
            DispatchQueue.main.async {
                self.dismissLoadingProgress(view: self.navigationController?.view)
                if updatedAlbum != nil {
//                    self.currentAlbum = updatedAlbum!
                    self.currentAlbum.title = updatedAlbum!.title
                    self.currentAlbum.albumDescription = updatedAlbum!.albumDescription
                    self.currentAlbum.coverImageId = updatedAlbum!.coverImageId
                    
                    // Check if user selected images
                    if self.isExistAlbumImages() {
                        self.checkSelectedImages()
                    }
                    else{
                        // do something process
                        self.postUpdateAlbum()
                    }
                }
                else{
                    self.showSimpleAlert(title: "", message: errorMsg, complete: nil)
                }
            }
        }
    }
    
    // Upload the new album images
    @IBAction func uploadNewImages(_ sender: Any) {
        // Show the Actionsheet from taking photo from Gallery or Camera
        let alertVC = UIAlertController(title: "", message: "Upload album image", preferredStyle: .actionSheet)
        let galleryAction = UIAlertAction(title: "Add from Gallery", style: .default) { (action) in
            self.showAssetsPicker()
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
    
    // Show the AssetPickerController (Multi-images)
    func showAssetsPicker(){
        // Check the access permission to Photo library
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            // to show
            let pickerConfig = AssetsPickerConfig()
            pickerConfig.albumIsShowEmptyAlbum = false
            
            let picker = AssetsPickerViewController(pickerConfig: pickerConfig)
            picker.pickerDelegate = self
            present(picker, animated: true, completion: nil)
        }
    }
    
    @IBAction func shareAlbum(_ sender: Any) {
        
    }
    
    @IBAction func sellAlbum(_ sender: Any) {
        
    }
    
    func checkSelectedImages(){
        // Upload the images
        if self.selectedImageAssets.count > 0 {
            self.showLoadingProgress(view: self.navigationController?.view)
            PhotoUploadManager.sharedInstance.downloadAssets(assets: self.selectedImageAssets) { (urls) in
                DispatchQueue.main.async {
                    self.dismissLoadingProgress(view: self.navigationController?.view)
                    if urls.count > 0 {
                        self.uploadAlbumImages(imageURLs: urls)
                    }
                }
            }
        }
        else{
            self.uploadCameraImages()
        }
    }
    
    // Upload all images from Photo library
    func uploadAlbumImages(imageURLs: [URL]){
        print("Starting upload the images...")
        self.showLoadingProgress(view: self.navigationController?.view, label: "Uploading images...")
        PhotoUploadManager.sharedInstance.uploadImages(imageURLs, isAlbum: true, mediaID: self.currentAlbum.albumId) { (result) in
            DispatchQueue.main.async {
                self.dismissLoadingProgress(view: self.navigationController?.view)
                self.uploadCameraImages()
            }
        }
    }
    
    // Upload the images taken from camera
    func uploadCameraImages(){
        let imageURLs = self.getAllFileUrlsInDirectory(MEDIA_CAMERA_FOLDER)
        if imageURLs.count > 0 {
            self.showLoadingProgress(view: self.navigationController?.view, label: "Uploading images...")
            PhotoUploadManager.sharedInstance.uploadImages(imageURLs, isAlbum: true, mediaID: self.currentAlbum.albumId) { (result) in
                DispatchQueue.main.async {
                    self.dismissLoadingProgress(view: self.navigationController?.view)
                    // do something process
                    self.postUpdateAlbum()
                }
            }
        }
        else{
            self.postUpdateAlbum()
        }
    }
    
    // Check if exist selecte images
    func isExistAlbumImages() -> Bool {
        return self.cameraImage != nil || self.selectedImageAssets.count > 0
    }
    
    func postUpdateAlbum(){
        self.view.makeToast("Updated album successfully!")
        let usrInfo : [String : Any] = ["updated_album" : self.currentAlbum]
        NotificationCenter.default.post(name: Notification.Name("notification_edited_album"), object: nil, userInfo : usrInfo)
        clearAssets()
    }
    
    // clear all assets and images after created album
    func clearAssets(){
        self.selectedImageAssets.removeAll()
        self.cameraImage = nil
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

extension EditAlbumViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancelled to pick image")
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("Picked Image")
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.cameraImage = pickedImage
            let filename = "\(Date().currentDateTimeStamp).jpg"
            
            self.saveImageToDirectory(pickedImage, filename: filename, directoryName: MEDIA_CAMERA_FOLDER) { (success, errorMsg) in
                if success {
                    self.cameraImage = pickedImage
                }
                else{
                    print(errorMsg ?? "")
                }
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
}

extension EditAlbumViewController : AssetsPickerViewControllerDelegate {
    func assetsPickerCannotAccessPhotoLibrary(controller: AssetsPickerViewController) {
        print("Can't access AssetPhotoLibrary")
    }
    func assetsPickerDidCancel(controller: AssetsPickerViewController) {
        print("Cancelled asset picker")
    }
    func assetsPicker(controller: AssetsPickerViewController, selected assets: [PHAsset]) {
        print("Selected assets")
        // do your job with selected assets
        self.selectedImageAssets = assets
    }
}
