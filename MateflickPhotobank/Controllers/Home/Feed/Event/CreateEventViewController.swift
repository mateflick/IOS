//
//  CreateEventViewController.swift
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

class CreateEventViewController: UIViewController {
    
    @IBOutlet weak var eventTitleText: SkyFloatingLabelTextField!
    @IBOutlet weak var locationText: SkyFloatingLabelTextField!
    @IBOutlet weak var eventDateText: SkyFloatingLabelTextField!
    @IBOutlet weak var eventDescriptionText: UITextView!
    
    var cameraImage: UIImage?
    var selectedImageAssets : [PHAsset] = []
    var uploadImageURLs : [URL] = [] // the urls to be uploaded
    
    var currentEvent : EventData!
    
    var eventDate : Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        eventDescriptionText.showDoneButtonOnKeyboard()
        eventDescriptionText.placeholder = "Event description..."
        eventDescriptionText.placeholderColor = UIColor(red: 154/255.0, green: 154/255.0, blue: 154/255.0, alpha: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Select the album
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
    
    // Post the event
    @IBAction func postEvent(_ sender: Any) {
        if eventTitleText.text!.isEmpty {
            eventTitleText.errorMessage = "No event name"
            return
        }
        
        if locationText.text!.isEmpty {
            locationText.errorMessage = "No event location"
            return
        }
        
        if eventDateText.text!.isEmpty {
            eventDateText.errorMessage = "No event date"
            return
        }
        
        // Check if network is connected
        if !Reachability.isConnectedToNetwork() {
            self.showNoInternetAlert()
            return
        }
        
        // Call api
        /*
         {
         "UserId":"5b41aa75a077d47a2967a65e",
         "Description":"This is the test event",
         "Location":"New York, USA",
         "EventDate":"2018-07-12",
         "Name":"First event"
         }
        */
        
        let params :[String: Any] = [
            "UserId" : UserInfo.sharedInstance.userId,
            "Description" : eventDescriptionText.text!,
            "Location" : locationText.text!,
            "EventDate" : self.eventDate.currentDateTimeStamp,
            "Name" : eventTitleText.text!
        ]
        
        self.showLoadingProgress(view: self.navigationController?.view, label: "Creating event...")
        ApiManager.sharedInstance.createNewEvent(params) { (event, errorMsg) in
            DispatchQueue.main.async {
                self.dismissLoadingProgress(view: self.navigationController?.view)
                if event != nil {
                    self.currentEvent = event!
                    
                    if self.isExistEventImages() {
                        self.checkSelectedImages()
                    }
                    else{
                        // do something process
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
                        self.uploadEventImages(imageURLs: urls)
                    }
                }
            }
        }
        else{
            self.uploadCameraImages()
        }
    }
    
    // Upload all images from Photo library
    func uploadEventImages(imageURLs: [URL]){
        print("Starting upload the images...")
        self.showLoadingProgress(view: self.navigationController?.view, label: "Uploading images...")
        PhotoUploadManager.sharedInstance.uploadImages(imageURLs, isAlbum: false, mediaID: self.currentEvent.eventId) { (result) in
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
            PhotoUploadManager.sharedInstance.uploadImages(imageURLs, isAlbum: false, mediaID: self.currentEvent.eventId) { (result) in
                DispatchQueue.main.async {
                    self.dismissLoadingProgress(view: self.navigationController?.view)
                    self.clearAssets()
                }
            }
        }
        else{
            clearAssets()
        }
    }
    
    func isExistEventImages() -> Bool {
        return self.cameraImage != nil || self.selectedImageAssets.count > 0
    }
    
    func clearAssets(){
        self.view.makeToast("Created event successfully!")
        self.selectedImageAssets.removeAll()
        self.cameraImage = nil
        
        NotificationCenter.default.post(name: Notification.Name("notification_created_event"), object: nil)
    }
    
    // Event location
    @IBAction func selectEventLocation(_ sender: Any) {
        let locationPicker = LocationPicker()
        locationPicker.pickCompletion = { (pickedLocationItem) in
            // Do something with the location the user picked.
            print("Select location name: " + pickedLocationItem.name)
            print("Select location address: " + pickedLocationItem.formattedAddressString!)
            self.locationText.text = self.getSelectedLocation(pickedLocationItem)
        }
        navigationController!.pushViewController(locationPicker, animated: true)
    }
    
    
    
    // Event Date
    @IBAction func selectEventDate(_ sender: Any) {
        DatePickerDialog().show("Event Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .date) {
            (date) -> Void in
            if let dt = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                self.eventDateText.text = formatter.string(from: dt)
                self.eventDate = dt
            }
        }
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

extension CreateEventViewController : ContactListViewDelegate {
    func didSelectContacts(_ contacts: [PhoneContact]) {
        for contact in contacts {
            print("Selected contact name = \(contact.name ?? "")")
            if let username = contact.name, !username.isEmpty {
                self.eventDescriptionText.text = self.eventDescriptionText.text + " @\(username)"
            }
        }
    }
}

extension CreateEventViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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

extension CreateEventViewController : AssetsPickerViewControllerDelegate {
    func assetsPickerCannotAccessPhotoLibrary(controller: AssetsPickerViewController) {
        print("Can't not access AssetPhotoLibrary")
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
