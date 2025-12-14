//
//  applicantCardCell.swift
//  Lab
//
//  Created by Arvin Roeslim on 13/12/25.
//

import UIKit
import CoreData

class applicantCardCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var specialtyLbl: UILabel!
    @IBOutlet weak var workShiftLbl: UILabel!
    @IBOutlet weak var ageLbl: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    
    var application: NSManagedObject?
    
    var onAccept: ((NSManagedObject) -> Void)?
    var onReject: ((NSManagedObject) -> Void)?
    
    @IBAction func acceptBtn(_ sender: Any) {
        guard let application = application else { return }
        onAccept?(application)
    }
    
    @IBAction func rejectBtn(_ sender: Any) {
        guard let application = application else { return }
        onReject?(application)
    }
    
    func updateButtonVisibility(status: String) {
        guard let acceptBtn = acceptButton, let rejectBtn = rejectButton else {
            return
        }
        
        if status == "Accepted" || status == "Rejected" {
            acceptBtn.isHidden = true
            rejectBtn.isHidden = true
        } else {
            acceptBtn.isHidden = false
            rejectBtn.isHidden = false
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
