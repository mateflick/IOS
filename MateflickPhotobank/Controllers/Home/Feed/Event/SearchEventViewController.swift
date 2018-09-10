//
//  SearchEventViewController.swift
//  MateflickPhotobank
//
//  Created by Panda on 7/14/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit
import Toast_Swift

class SearchEventViewController: UIViewController {
    
    @IBOutlet weak var eventTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var events : [EventData] = [] {
        didSet{
            eventTableView.reloadData()
        }
    }
    
    var searchEvents : [EventData] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.eventTableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getSearchEvents(){
        if !Reachability.isConnectedToNetwork() {
            self.showNoInternetAlert()
            return
        }
        
        self.showLoadingProgress(view: self.navigationController?.view)
        ApiManager.sharedInstance.searchEvents(keyword: searchBar.text!, page: 1, pageSize: 20) { (events, errorMsg) in
            DispatchQueue.main.async {
                self.dismissLoadingProgress(view: self.navigationController?.view)
                
                if events != nil {
                    self.events = events!
                    self.searchEvents.append(contentsOf: self.events)
                    
                    if events!.count == 0 {
                        self.view.makeToast("No search result")
                    }
                }
                else{
                    self.showSimpleAlert(title: "", message: errorMsg, complete: nil)
                }
            }
        }
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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

extension SearchEventViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : SearchEventTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SearchEventTableViewCell", for: indexPath) as! SearchEventTableViewCell
        let event = self.events[indexPath.row]
        cell.setEvent(event)
        
        return cell
    }
}

extension SearchEventViewController : UISearchBarDelegate {
    // MARK :- UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        var searchResults : [EventData] = []
        
        if searchText.count > 0
        {
            for index in 0..<self.searchEvents.count{
                let event = self.searchEvents[index]
                
                if event.name != nil {
                    let eventName = event.name!.lowercased() as NSString
                    let eventLocation = event.location!.lowercased() as NSString
                    if eventName.range(of: searchText.lowercased()).location != NSNotFound || eventLocation.range(of: searchText.lowercased()).location != NSNotFound{
                        searchResults.append(event)
                    }
                }
            }
        } else {
            searchResults.append(contentsOf: self.searchEvents)
        }
        
        self.events.removeAll()
        self.events.append(contentsOf: searchResults)
    }
    
    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        self.getSearchEvents()
    }
}
