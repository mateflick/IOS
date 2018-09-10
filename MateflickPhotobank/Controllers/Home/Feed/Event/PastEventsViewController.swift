//
//  PastEventsViewController.swift
//  MateflickPhotobank
//
//  Created by Panda on 7/14/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit

class PastEventsViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var eventCollectionView: UICollectionView!
    @IBOutlet weak var containerView: UIView!
    
    var pastEvents : [EventData] = []{
        didSet{
            self.eventCollectionView.reloadData()
        }
    }
    var searchedEvents : [EventData] = []
    var currentPage = 1
    var ITEM_COUNT_PER_PAGE = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.loadPastEvents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func loadPastEvents(){
        if !Reachability.isConnectedToNetwork() {
            self.showNoInternetAlert()
            return
        }
        
        self.showLoadingProgress(view: self.navigationController?.view)
        ApiManager.sharedInstance.getPastEvents(currentPage, pageSize: ITEM_COUNT_PER_PAGE) { (events, errorMsg) in
            DispatchQueue.main.async {
                self.dismissLoadingProgress(view: self.navigationController?.view)
                if events != nil {
                    self.pastEvents = events!
                    self.searchedEvents.removeAll()
                    self.searchedEvents.append(contentsOf: self.pastEvents)
//                    self.updatePastEventList()
                }
                else{
                    self.showSimpleAlert(title: "", message: errorMsg, complete: nil)
                }
            }
        }
    }
    
    func updatePastEventList(){
        
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

extension PastEventsViewController : UISearchBarDelegate {
    // MARK :- UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        var searchResults : [EventData] = []
        
        if searchText.count > 0
        {
            for index in 0..<self.searchedEvents.count{
                let eventData = self.searchedEvents[index]
                let eventName = eventData.name.lowercased() as NSString
                let eventLocation = eventData.location.lowercased() as NSString
                
                if eventName.range(of: searchText.lowercased()).location != NSNotFound || eventLocation.range(of: searchText.lowercased()).location != NSNotFound{
                    searchResults.append(eventData)
                }
            }
        } else {
            searchResults.append(contentsOf: self.searchedEvents)
        }
        
        self.pastEvents.removeAll()
        self.pastEvents.append(contentsOf: searchResults)
    }
    
    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension PastEventsViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyEventCollectionViewCell", for: indexPath) as! MyEventCollectionViewCell
        let eventData = self.pastEvents[indexPath.row]
        cell.setEvent(eventData)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.pastEvents.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var cellWidth : CGFloat
        var cellHeight : CGFloat
        
        if collectionView.tag == 10 {
            cellWidth = collectionView.frame.size.width * 0.6
            cellHeight = 145
        }
        else{
            cellWidth = (collectionView.frame.size.width - 10) / 2
            cellHeight = cellWidth * 3 / 4.0
        }
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView.tag == 10 {
            return 0
        }
        else{
            return 10
        }
    }
}
