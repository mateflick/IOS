//
//  CreateAlbumViewController.swift
//  MateflickPhotobank
//
//  Created by Panda on 7/3/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import LocationPickerViewController
import DatePickerDialog
import AssetsPickerViewController
import Photos
import Toast_Swift
import UITextView_Placeholder

class CreateAlbumViewController: UIViewController {

    @IBOutlet weak var albumTitleText: SkyFloatingLabelTextField!
    @IBOutlet weak var albumLocationText: SkyFloatingLabelTextField!
    @IBOutlet weak var albumDateText: SkyFloatingLabelTextField!
    @IBOutlet weak var albumEventText: SkyFloatingLabelTextField!
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Location
    @IBAction func selectAlbumLocation(_ sender: Any) {
        let locationPicker = LocationPicker()
        locationPicker.pickCompletion = { (pickedLocationItem) in
            // Do something with the location the user picked.
            print("Select location name: " + pickedLocationItem.name)
            print("Select location address: " + pickedLocationItem.formattedAddressString!)
            self.albumLocationText.text = self.getSelectedLocation(pickedLocationItem)
        }
        navigationController!.pushViewController(locationPicker, animated: true)
    }
    
    // Date
    @IBAction func selectAlbumDate(_ sender: Any) {
        DatePickerDialog().show("Album Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .date) {
            (date) -> Void in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                self.albumDateText.text = formatter.string(from: dt)
            }
        }
    }
    
    
    // Upload album image
    @IBAction func selectAlbumImage(_ sender: Any) {
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
    
    // Create the new Album
    @IBAction func createNewAlbum(_ sender: Any) {
        if albumTitleText.text!.isEmpty {
            albumTitleText.errorMessage = "No album title"
            return
        }
        
        if albumLocationText.text!.isEmpty {
            albumLocationText.errorMessage = "No album location"
            return
        }
        
        if albumEventText.text!.isEmpty {
            albumEventText.errorMessage = "No album event"
            return
        }
        
        // Check if network is connected
        if !Reachability.isConnectedToNetwork() {
            self.showNoInternetAlert()
            return
        }
        
        // Call api to create the album
//        {
//
//            "Title":"third album",
//            "Description":"@Israel @Mine @youis album",
//            "Location":"New York, USA",
//            "Event":"No Event",
//            "UserId":"5b3c94e50aefbf71f9a2b9c5"
//        }
        let params : [String : Any] = [
            "Title" : self.albumTitleText.text!,
            "Description" : self.albumDescriptionText.text!,
            "Location" : self.albumLocationText.text!,
            "Event" : "No event",
            "UserId" : UserInfo.sharedInstance.userId
        ]
        
        self.showLoadingProgress(view: self.navigationController?.view, label: "Creating album...")
        ApiManager.sharedInstance.createNewAlbum(params) { (album, errorMsg) in
            DispatchQueue.main.async {
                self.dismissLoadingProgress(view: self.navigationController?.view)
                if album != nil {
                    self.currentAlbum = album!
                    
                    // Check if user selected images
                    if self.isExistAlbumImages() {
                        self.checkSelectedImages()
                    }
                    else{
                        // do something process
                        self.view.makeToast("Created album successfully!")
                        self.clearAssets()
                    }
                }
                else{
                    self.showSimpleAlert(title: "", message: errorMsg, complete: nil)
                }
            }
        }
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
                    self.view.makeToast("Created album successfully!")
                    self.clearAssets()
                }
            }
        }
        else{
            self.view.makeToast("Created album successfully!")
            self.clearAssets()
        }
    }
    
    // clear all assets and images after created album
    func clearAssets(){
        self.selectedImageAssets.removeAll()
        self.cameraImage = nil
        
        NotificationCenter.default.post(name: Notification.Name("notification_created_album"), object: nil)
    }
    
    func isExistAlbumImages() -> Bool {
        return self.cameraImage != nil || self.selectedImageAssets.count > 0
    }
    
    @IBAction func dimiss(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tagFriends(_ sender: Any) {
        if let contactListVC = self.storyboard?.instantiateViewController(withIdentifier: "ContactListVC") as? ContactListViewController {
            contactListVC.delegate = self
            self.navigationController?.pushViewController(contactListVC, animated: true)
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

extension CreateAlbumViewController : ContactListViewDelegate {
    func didSelectContacts(_ contacts: [PhoneContact]) {
        for contact in contacts {
            print("Selected contact name = \(contact.name ?? "")")
            if let username = contact.name, !username.isEmpty {
                self.albumDescriptionText.text = self.albumDescriptionText.text + " @\(username)"
            }
        }
    }
}

extension CreateAlbumViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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

extension CreateAlbumViewController : AssetsPickerViewControllerDelegate {
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
