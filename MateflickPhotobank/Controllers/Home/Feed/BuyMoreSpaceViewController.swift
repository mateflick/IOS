//
//  BuyMoreSpaceViewController.swift
//  MateflickPhotobank
//
//  Created by Panda on 6/15/18.
//  Copyright © 2018 MateFlick. All rights reserved.
//

import UIKit

class BuyMoreSpaceViewController: UIViewController {
    let typeData : [String] = ["BANK DINNER", "MATE VATERAN", "VATERAN", "MATE BANKER", "BANKER", "MATE FLICKER", "FLICKER", "MATE MARKER", "MATES", "FRESHER"]
    let priceData = [650, 600, 550, 500, 450, 400, 350, 300, 250, 200]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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


extension BuyMoreSpaceViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.typeData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BuyMoreSpaceTableViewCell.cellIdentifier, for: indexPath) as! BuyMoreSpaceTableViewCell
        cell.typeLabel.text = self.typeData[indexPath.row]
        cell.priceLabel.text = "$ \(self.priceData[indexPath.row].formattedWithSeparator)"
        cell.capacityLabel.text = "\(50 - indexPath.row * 5)"
        
        return cell
    }
}

class BuyMoreSpaceTableViewCell : UITableViewCell {
    static let cellIdentifier = "BuyMoreSpaceTableViewCell"
    
    @IBOutlet weak var capacityLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
