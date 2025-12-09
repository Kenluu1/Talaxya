//
//  ProfileViewController.swift
//  Lab
//
//  Created by eslilinnn on 30/09/25.
//

import UIKit
import CoreData

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var fullusername: UILabel!
    @IBOutlet weak var usernameLBL: UILabel!
    @IBOutlet weak var emailLBL: UILabel!
    @IBOutlet weak var accountTypeLBL: UILabel!
    
    var currentUserName: String = ""
    var context: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
   
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("Profile Appeared: Fetching latest data...")
        
        if let newName = UserDefaults.standard.string(forKey: "userLogin") {
            self.currentUserName = newName
            print("Current user from session: \(newName)")
        }
        
        
        fullusername.text = self.currentUserName
        usernameLBL.text = self.currentUserName
        
      
        fetchProfileData()
    }

    func fetchProfileData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")

   
        request.predicate = NSPredicate(format: "username ==[c] %@", currentUserName)
        
        do {
            let result = try context.fetch(request)
            
            if result.count > 0 {
                let dataUser = result[0] as! NSManagedObject
                
                let email = dataUser.value(forKey: "email") as? String ?? "-"
                
                
                emailLBL.text = email
                accountTypeLBL.text = "Customer"
                
                print("Profile data updated successfully for: \(currentUserName)")
            } else {
                print("User '\(currentUserName)' not found in database")
            }
        } catch {
            print("Failed to fetch profile: \(error)")
        }
    }
    
    @IBAction func editProfileBTN(_ sender: Any) {
        performSegue(withIdentifier: "ProfileToEdit", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProfileToEdit" {
            if let destinationVC = segue.destination as? CustomerEditViewController {
                
                destinationVC.usernames = usernameLBL.text ?? ""
                
                print("Sending username to Edit Page: \(destinationVC.usernames)")
            }
        }
    }
    
    @IBAction func logOutBTN(_ sender: Any) {
       
        UserDefaults.standard.removeObject(forKey: "userLogin")
        
        print("Logout Success")
        
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}
