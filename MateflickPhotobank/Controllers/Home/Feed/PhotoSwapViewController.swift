//
//  PhotoSwapViewController.swift
//  MateflickPhotobank
//
//  Created by Panda on 6/16/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit
import CHIPageControl

class PhotoSwapViewController: UIViewController {

    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var uploadAlbumButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: CHIPageControlAji!
    
    let totalPages = 4
    @IBOutlet weak var swapCollectionView: UICollectionView!
    
    let columnCount = 4
    let minimumInteritemSpacing : CGFloat = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.scrollView.delegate = self
        self.scrollView.tag = 101
        self.swapCollectionView.tag = 102
        
        self.configureScrollView()
        self.configurePageControl()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
//        self.uploadButton.centerVertically()
//        self.uploadAlbumButton.centerVertically()
    }
    
    func configureScrollView(){
        // Enable paging.
        scrollView.isPagingEnabled = true
        
        // Set the following flag values.
        scrollView.scrollsToTop = false
        
        // Set the scrollview content size.
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(totalPages), height: scrollView.frame.size.height)
        
        // Load the TestView view from the OnBoardView.xib file and configure it properly.
        for view in self.scrollView.subviews {
            view.removeFromSuperview()
        }
        
        for idx in 0..<totalPages {
            // Load the TestView view.
            let thumbImage : UIImageView = UIImageView(frame: CGRect(x: CGFloat(idx) * scrollView.frame.size.width, y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height))
            
            // Set the proper message to the onboard view's image.
            thumbImage.image = #imageLiteral(resourceName: "sample")
            thumbImage.contentMode = .scaleAspectFill
            
            // Add the test view as a subview to the scrollview.
            scrollView.addSubview(thumbImage)
        }
    }
    
    // Setup the page control
    func configurePageControl() {
        // Set the total pages to the page control.
        pageControl.numberOfPages = totalPages
        
        // Set the initial page.
        pageControl.progress = 0
    }
    
    // Share the photo
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        // Get the image to be shared
        let shareImage = #imageLiteral(resourceName: "sample")
        let shareVC = UIActivityViewController(activityItems: [shareImage], applicationActivities: [])
        shareVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList, UIActivityType.print, UIActivityType.assignToContact, UIActivityType.openInIBooks]
        shareVC.popoverPresentationController?.sourceView = sender
        self.present(shareVC, animated: true, completion: nil)
    }
    
    @IBAction func sellPhoto(_ sender: Any) {
    }
    
    @IBAction func sellAlbum(_ sender: Any) {
        
    }
    
    // Go to Feed page
    @IBAction func gotoFeedPage(_ sender: Any) {
        if self.navigationController != nil {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    // Upload picture
    @IBAction func uploadPicture(_ sender: Any) {
        let alertVC = UIAlertController(title: "", message: "Upload picture", preferredStyle: .actionSheet)
        let galleryAction = UIAlertAction(title: "Upload picture from Gallery", style: .default) { (action) in
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

extension PhotoSwapViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancelled to pick image")
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("Picked Image")
        if let pickerdImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
        }
        
        dismiss(animated: true, completion: nil)
    }
}

extension PhotoSwapViewController : UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.tag == 101 {
            // Calculate the new page index depending on the content offset.
            let currentPage = floor(scrollView.contentOffset.x / UIScreen.main.bounds.size.width)
            
            // change the page position
            self.pageControl.set(progress: Int(currentPage), animated: true)
        }        
    }
}

extension PhotoSwapViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SwapCollectionCell", for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth : CGFloat
        let cellHeight : CGFloat
        
        cellWidth = 120
        cellHeight = collectionView.bounds.size.height - 20
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
}
