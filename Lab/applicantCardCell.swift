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
    
    // Property untuk menyimpan data application
    var application: NSManagedObject?
    
    // Closure untuk handle Accept/Reject
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
    
    // Function untuk hide/show button berdasarkan status
    func updateButtonVisibility(status: String) {
        // Cek apakah outlet sudah terhubung
        guard let acceptBtn = acceptButton, let rejectBtn = rejectButton else {
            print("⚠️ Button outlet belum terhubung di Storyboard")
            return
        }
        
        if status == "Accepted" || status == "Rejected" {
            // Hide button jika sudah Accepted atau Rejected
            acceptBtn.isHidden = true
            rejectBtn.isHidden = true
        } else {
            // Show button jika masih Pending
            acceptBtn.isHidden = false
            rejectBtn.isHidden = false
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Cell tidak bisa di-select (sesuai requirement)
    }

}
