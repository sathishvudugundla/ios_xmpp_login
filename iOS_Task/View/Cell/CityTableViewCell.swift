//
//  CityTableViewCell.swift
//  iOS_Task
//
//  Created by sathish on 20/12/21.
//

import UIKit

class CityTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet var nameLbl: UILabel!
    
    @IBOutlet var TemperatureLbl: UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
