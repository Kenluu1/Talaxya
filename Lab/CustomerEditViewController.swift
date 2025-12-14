//
//  CustomerEditViewController.swift
//  Lab
//
//  Created by eslilinnn on 14/10/25.
//

import UIKit
import CoreData

class CustomerEditViewController: UIViewController {

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    var context: NSManagedObjectContext!
    var currentUserObject: NSManagedObject?
    var usernames: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
    
        var namer = ""
        
      
        if let names = UserDefaults.standard.string(forKey: "userLogin") {
            namer = names
        }
        // 2. Cek Operan
        else if !usernames.isEmpty {
            print("🔍 Sumber 2: Nama ditemukan dari Operan Profile: \(usernames)")
            namer = usernames
        }
        
        // 3. Cari Data
        if !namer.isEmpty {
            fetchCurrentUserData(name: namer)
        } else {
            showAlert(message: "System confused")
        }
    }
    
    func fetchCurrentUserData(name: String) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        request.predicate = NSPredicate(format: "name ==[c] %@", name)
        
        do {
            let result = try context.fetch(request)
            if result.count > 0 {
                currentUserObject = result[0] as? NSManagedObject
                nameTF.text = currentUserObject?.value(forKey: "name") as? String
                emailTF.text = currentUserObject?.value(forKey: "email") as? String
                passwordTF.text = currentUserObject?.value(forKey: "password") as? String
            } else {
                showAlert(message: "Data user cannot be found")
            }
        } catch {
            print("Error fetch: \(error)")
        }
    }

    @IBAction func saveChangesBTN(_ sender: Any) {
        guard let newName = nameTF.text, !newName.isEmpty,
              let newEmail = emailTF.text, !newEmail.isEmpty,
              let newPassword = passwordTF.text, !newPassword.isEmpty else {
            showAlert(message: "Every column must be filled")
            return
        }
        
        guard let userToUpdate = currentUserObject else {
            showAlert(message: "Update failed")
            return
        }
        
     
        userToUpdate.setValue(newName, forKey: "name")
        userToUpdate.setValue(newEmail, forKey: "email")
        userToUpdate.setValue(newPassword, forKey: "password")
        
        do {
            try context.save()
            

            UserDefaults.standard.set(newName, forKey: "userLogin")
            
            let alert = UIAlertController(title: "Success", message: "Profile Updated!", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                if let navigation = self.navigationController {
                    navigation.popViewController(animated: true)
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }))
            present(alert, animated: true)
            
        } catch {
            print("Failed: \(error)")
            showAlert(message: "Failed to save")
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
