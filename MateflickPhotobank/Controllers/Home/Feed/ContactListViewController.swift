//
//  ContactListViewController.swift
//  MateflickPhotobank
//
//  Created by Panda on 7/11/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit

protocol ContactListViewDelegate {
    func didSelectContacts(_ contacts : [PhoneContact])
}

class ContactListViewController: UIViewController {
    
    var contacts : [PhoneContact] = [] {
        didSet{
            contactsTableView.reloadData()
        }
    }
    
    var selectedContacts : [PhoneContact] = []
    var searchedContacts : [PhoneContact] = []
    var delegate : ContactListViewDelegate!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var contactsTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let allContacts = PhoneContactsManager.getContacts()
        for contact in allContacts {
            contacts.append(PhoneContact(contact: contact))
        }
        
        searchedContacts.append(contentsOf: self.contacts)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismiss(_ sender: Any) {
//        UserInfo.sharedInstance.albumTagUsers = self.selectedContacts
        if self.delegate != nil {
            self.delegate.didSelectContacts(self.selectedContacts)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func initContactsData(){
        
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

extension ContactListViewController : UISearchBarDelegate {
    // MARK :- UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        var searchResults : [PhoneContact] = []
        
        if searchText.count > 0
        {
            for index in 0..<self.searchedContacts.count{
                let contact = self.searchedContacts[index]
                
                if contact.name != nil {
                    let username = contact.name!.lowercased() as NSString
                    if username.range(of: searchText.lowercased()).location != NSNotFound {
                        searchResults.append(contact)
                    }
                }
            }
        } else {
            searchResults.append(contentsOf: self.searchedContacts)
        }
        
        self.contacts.removeAll()
        self.contacts.append(contentsOf: searchResults)
    }
    
    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}


extension ContactListViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell : UITableViewCell = tableView.cellForRow(at: indexPath)!
        tableView.deselectRow(at: indexPath, animated: true)
        
        let contact = self.contacts[indexPath.row]
        
        if currentCell.accessoryType == .checkmark {
            currentCell.accessoryType = .none
            
            if self.selectedContacts.contains(contact) {
                self.selectedContacts.remove(at: self.selectedContacts.index(of: contact)!)
            }
        }
        else{
            currentCell.accessoryType = .checkmark
            if !self.selectedContacts.contains(contact) {
                self.selectedContacts.append(contact)
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell", for: indexPath)
        
        if let username = self.contacts[indexPath.row].name {
            cell.textLabel?.text = username
        }
        
        if self.selectedContacts.contains(self.contacts[indexPath.row]) {
            cell.accessoryType = .checkmark
        }
        else{
            cell.accessoryType = .none
        }
        
        return cell
    }
}
