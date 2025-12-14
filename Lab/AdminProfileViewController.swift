//
//  AdminProfileViewController.swift
//  Lab
//
//  Created by Arvin Roeslim on 12/12/25.
//

import UIKit
import CoreData

class AdminProfileViewController: UIViewController {
    
    @IBOutlet weak var fullusername: UILabel!
    @IBOutlet weak var usernameLBL: UILabel!
    @IBOutlet weak var emailLBL: UILabel!
    @IBOutlet weak var accountTypeLBL: UILabel!
    
    var currentName: String = ""
    var context: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let newName = UserDefaults.standard.string(forKey: "userLogin") {
            self.currentName = newName
            print("Current admin from session: \(newName)")
        }
        
        fullusername.text = self.currentName
        usernameLBL.text = self.currentName
        
        fetchProfileData()
    }
    
    func fetchProfileData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        request.predicate = NSPredicate(format: "name ==[c] %@", currentName)
        
        do {
            let result = try context.fetch(request)
            
            if result.count > 0 {
                let dataUser = result[0] as! NSManagedObject
                
                let email = dataUser.value(forKey: "email") as? String ?? "-"
                
                emailLBL.text = email
                accountTypeLBL.text = "Admin"
            }
        } catch {
            print("Failed to fetch admin profile: \(error)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AdminProfileToEdit" {
            if let destinationVC = segue.destination as? CustomerEditViewController {
                destinationVC.usernames = usernameLBL.text ?? ""
            }
        }
    }
    
    @IBAction func logOutBTN(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "userLogin")
        
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}
