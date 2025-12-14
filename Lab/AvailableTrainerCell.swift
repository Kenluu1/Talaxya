//
//  AvailableTrainerCell.swift
//  Lab
//
//  Created by Arvin Roeslim on 13/12/25.
//

import UIKit

class AvailableTrainerCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var ageLbl: UILabel!
    @IBOutlet weak var specialtyLbl: UILabel!
    @IBOutlet weak var workShiftLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
