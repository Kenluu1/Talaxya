//
//  ProfileViewController.swift
//  Lab
//
//  Created by eslilinnn on 30/09/25.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBAction func EditProfileBtn(_ sender: Any) {
        performSegue(withIdentifier: "ProfileToEdit", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
