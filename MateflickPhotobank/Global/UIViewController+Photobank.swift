//
//  UIViewController+Photobank.swift
//  MateflickPhotobank
//
//  Created by Panda on 5/24/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import MBProgressHUD
import LocationPickerViewController
import Photos

extension UIViewController{
    /*
     @brief This function is to check email is valid or not
     @param Email address user entered
     */
    func isValidEmail(_ email : String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    /*!
     @brief It displays UIAlertController.
     @discussion This method displays UIAlertController with one button.
     @param title The title of AlertController
     @param message The content of AlertController
     @param closeButtonTitle The title of close button, default title is "Ok"
     @param complete The callback
     @return
     */
    func showSimpleAlert(title: String?, message: String?, closeButtonTitle: String = "Ok", complete:(() -> Void)?) -> Void {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: closeButtonTitle, style: .cancel, handler: { action in
            if complete != nil {
                complete!()
            }
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Show the no internet message
    func showNoInternetAlert(){
        let alertController = UIAlertController(title: MSG_NO_INTERNET_TITLE, message: MSG_NO_INTERNET, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: { action in
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    /*
     @brief This function is to check textfield is empty or null
     @param String
     */
    func isEmpty(_ text:String?) -> Bool {
        if let data = text {
            if data != "" {
                return false
            }
        }
        
        return true
    }
    
    // Set the left menu in navigation bar
    func setNavigationBarItem() {
        self.addLeftBarButtonWithImage(UIImage(named: "menu")!)
        self.slideMenuController()?.removeLeftGestures()
        self.slideMenuController()?.addLeftGestures()
    }
    
    // Crop image and put it on the center position
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    // Open the camera
    func openCamera(_ delegate : UIImagePickerControllerDelegate & UINavigationControllerDelegate){
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = delegate
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    // Open PhotoLibrary
    func openPhotoLibrary(_ delegate : UIImagePickerControllerDelegate & UINavigationControllerDelegate){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = delegate
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    /*!
     @brief It shows MBProgressHUD.
     @discussion It displays MBProgressHUD to the specific view.
     @param view The view to be displayed MBProgressHUD
     @return
     */
    func showLoadingProgress(view: UIView!, label: String = "Loading...") -> Void {
        let loadingHud = MBProgressHUD.showAdded(to: view, animated: true)
        loadingHud.bezelView.backgroundColor = UIColor.black
        loadingHud.contentColor = UIColor.white
        loadingHud.label.text = NSLocalizedString(label, comment: "")
    }
    
    /*!
     @brief It hiddens MBProgressHUD.
     @discussion It hiddens MBProgressHUD from the specific view.
     @param view The view the MBProgressHUD is dismissed
     @return
     */
    func dismissLoadingProgress(view : UIView!) -> Void {
        MBProgressHUD.hide(for: view, animated: true)
    }
    
    // get the full address
    func getSelectedLocation(_ locationItem : LocationItem) -> String{
        var address = ""
        if let addressDictionary = locationItem.addressDictionary {
            if let street = addressDictionary["Street"] as? String {
                address = "\(street)"
            }
            
            if let city = addressDictionary["City"] as? String {
                if address.count > 0 {
                    address = "\(address), "
                }
                address = "\(address)\(city)"
            }
            
            if let country = addressDictionary["Country"] as? String {
                if address.count > 0 {
                    address = "\(address), "
                }
                address = "\(address)\(country)"
            }
        }
        
        return address
    }
    
    // get album dicrectory
    func getAlbumDirectory () -> URL{
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let albumUrl = documentsDirectory.appendingPathComponent("albums")
        if !FileManager.default.fileExists(atPath: albumUrl.path) {
            do{
                try FileManager.default.createDirectory(at: albumUrl, withIntermediateDirectories: true, attributes: nil)
                return albumUrl
            }catch {
                NSLog("Couldn't create album directory")
            }
        }
        
        NSLog("Album directory path  = \(albumUrl.path)")
        return albumUrl
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
    
    // Save image into local
    func saveImageToDirectory(_ image:UIImage, filename:String, directoryName:String, complete:@escaping(Bool, String?)-> Void) {
        let imageURL = getDirectory(directoryName).appendingPathComponent(filename)
        if let imageData = UIImageJPEGRepresentation(image, 1.0), !FileManager.default.fileExists(atPath: imageURL.path) {
            do{
                // Write the image data into local
                try imageData.write(to: imageURL)
                print("Image saved successfully, path = \(imageURL.path)")
                complete(true, nil)
            } catch {
                print("Error saving image : \(error.localizedDescription)")
                complete(false, error.localizedDescription)
            }
        }
        else{
            complete(false, "Image not saved, try again later.")
        }
    }
    
    // Save user profile image
    func saveUserImage(_ image : UIImage, complete:@escaping(URL?) -> Void) {
        let imageURL = getDirectory(MEDIA_PROFILE).appendingPathComponent(IMG_USER_PROFILE)
        if let imageData = UIImageJPEGRepresentation(image, 1.0){
            do{
                // Write the image data into local
                try imageData.write(to: imageURL)
                print("Saved user image path = \(imageURL.path)")
                complete(imageURL)
            } catch {
                print("Error saving image : \(error.localizedDescription)")
                complete(nil)
            }
        }
        else{
            complete(nil)
        }
    }
    
    // Get all files in directory
    func getAllFileUrlsInDirectory(_ dirName : String) -> [URL]{
        let dirUrl = getDirectory(dirName)
        var fileUrls:[URL] = []
        do{
            fileUrls = try FileManager.default.contentsOfDirectory(at: dirUrl, includingPropertiesForKeys: nil, options: [])
            return fileUrls
        } catch {
            print("Error while enumerating files \(dirUrl.path): \(error.localizedDescription)")
        }
        
        return fileUrls
    }
    
    func timeAgoSinceDate(_ date:Date, currentDate:Date, numericDates:Bool) -> String {
        let calendar = Calendar.current
        let now = currentDate
        let earliest = (now as NSDate).earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
        
        if (components.year! >= 2) {
            return "\(components.year!) years ago"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 year ago"
            } else {
                return "Last year"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) months ago"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1 month ago"
            } else {
                return "Last month"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) weeks ago"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1 week ago"
            } else {
                return "Last week"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) days ago"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1 day ago"
            } else {
                return "Yesterday"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) hours ago"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1 hour ago"
            } else {
                return "An hour ago"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!) minutes ago"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1 minute ago"
            } else {
                return "A minute ago"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!) seconds ago"
        } else {
            return "Just now"
        }
        
    }
}

extension UIButton {
    
    func centerVertically(padding: CGFloat = 6.0) {
        guard
            let imageViewSize = self.imageView?.frame.size,
            let titleLabelSize = self.titleLabel?.frame.size else {
                return
        }
        
        let totalHeight = imageViewSize.height + titleLabelSize.height + padding
        
        self.imageEdgeInsets = UIEdgeInsets(
            top: -(totalHeight - imageViewSize.height),
            left: 0.0,
            bottom: 0.0,
            right: -titleLabelSize.width
        )
        
        self.titleEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: -imageViewSize.width,
            bottom: -(totalHeight - titleLabelSize.height),
            right: 0.0
        )
        
        self.contentEdgeInsets = UIEdgeInsets(
            top: 10.0,
            left: 0.0,
            bottom: titleLabelSize.height,
            right: 0.0
        )
    }
    
}

extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
}

extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}

extension Formatter {
    static var withSeparator : NumberFormatter {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.numberStyle = .decimal
        return formatter
    }
}

extension BinaryInteger {
    var formattedWithSeparator : String {
        return Formatter.withSeparator.string(for: self) ?? ""
    }
}

extension UITextField {
    func showDoneButtonOnKeyboard() {
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(resignFirstResponder))
        
        var toolBarItems = [UIBarButtonItem]()
        toolBarItems.append(flexSpace)
        toolBarItems.append(doneButton)
        
        let doneToolbar = UIToolbar()
        doneToolbar.items = toolBarItems
        doneToolbar.sizeToFit()
        
        inputAccessoryView = doneToolbar
    }
}

extension UITextView {
    func showDoneButtonOnKeyboard() {
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(resignFirstResponder))
        
        var toolBarItems = [UIBarButtonItem]()
        toolBarItems.append(flexSpace)
        toolBarItems.append(doneButton)
        
        let doneToolbar = UIToolbar()
        doneToolbar.items = toolBarItems
        doneToolbar.sizeToFit()
        
        inputAccessoryView = doneToolbar
    }
}


extension UIImage {
    func resize(toTargetSize targetSize: CGSize) -> UIImage {
        
        let newScale = self.scale // change this if you want the output image to have a different scale
        let originalSize = self.size
        
        let widthRatio = targetSize.width / originalSize.width
        let heightRatio = targetSize.height / originalSize.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        let newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: floor(originalSize.width * heightRatio), height: floor(originalSize.height * heightRatio))
        } else {
            newSize = CGSize(width: floor(originalSize.width * widthRatio), height: floor(originalSize.height * widthRatio))
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(origin: .zero, size: newSize)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        let format = UIGraphicsImageRendererFormat()
        format.scale = newScale
        format.opaque = true
        let newImage = UIGraphicsImageRenderer(bounds: rect, format: format).image() { _ in
            self.draw(in: rect)
        }
        
        return newImage
    }
}

extension PHAsset {
    func getAssetURL(completionHandler : @escaping (URL?, _ isImage:Bool) -> Void){
        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
                completionHandler(contentEditingInput!.fullSizeImageURL as URL?, true)
            })
        } else if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completionHandler(localVideoUrl, false)
                } else {
                    completionHandler(nil, false)
                }
            })
        }
    }
    
    var originalFilename: String? {
        var fname:String?        
        if #available(iOS 9.0, *) {
            let resources = PHAssetResource.assetResources(for: self)
            if let resource = resources.first {
                fname = resource.originalFilename
            }
        }
        
        if fname == nil {
            // this is an undocumented workaround that works as of iOS 9.1
            fname = self.value(forKey: "filename") as? String
        }
        
        return fname
    }
}

extension String {
    func fileName() -> String {
        if let fileNameWithoutExtension = NSURL(fileURLWithPath: self).deletingPathExtension?.lastPathComponent {
            return fileNameWithoutExtension
        } else {
            return ""
        }
    }
    
    func fileExtension() -> String {
        
        if let fileExtension = NSURL(fileURLWithPath: self).pathExtension {
            return fileExtension
        } else {
            return ""
        }
    }
    
    func convertStringToDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: self)
        return date!
    }
    
    var length: Int {
        get {
            return self.count
        }
    }
    
    func substring(to : Int) -> String? {
        if (to >= length) {
            return nil
        }
        let toIndex = self.index(self.startIndex, offsetBy: to)
        return self.substring(to: toIndex)
    }
    
    func substring(from : Int) -> String? {
        if (from >= length) {
            return nil
        }
        let fromIndex = self.index(self.startIndex, offsetBy: from)
        return self.substring(from: fromIndex)
    }
    
    func substring(_ r: Range<Int>) -> String {
        let fromIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
        let toIndex = self.index(self.startIndex, offsetBy: r.upperBound)
        return self.substring(with: Range<String.Index>(uncheckedBounds: (lower: fromIndex, upper: toIndex)))
    }
    
    func character(_ at: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: at)]
    }
}

extension Date {
    // Date to Milliseconds
    var currentDateTimeStamp:String {
        print("Current time interval = \(Int64((self.timeIntervalSince1970 * 1000.0).rounded()))")
        return String(Int64((self.timeIntervalSince1970 * 1000.0).rounded()))
    }
    
    func getRemainingDays(to date :Date) -> Int {
        return Calendar.current.dateComponents([.day], from: self, to:date).day ?? 0
    }
    
    // Milliseconds to Date
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
}
