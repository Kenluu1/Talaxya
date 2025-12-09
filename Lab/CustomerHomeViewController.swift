//
//  CustomerHomeViewController.swift
//  Lab
//
//  Created by eslilinnn on 07/10/25.
//

import UIKit




class CustomerHomeViewController: UIViewController {

    @IBOutlet weak var Username: UILabel!
    
    var usernameData: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
          
            if let namaBaru = UserDefaults.standard.string(forKey: "userLogin") {
                Username.text = "Welcome, \(namaBaru)"
            }
        }
    }


