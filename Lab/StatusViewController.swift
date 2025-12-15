//
//  StatusViewController.swift
//  Lab
//
//  Created by Arvin Roeslim on 14/12/25.
//

import UIKit
import CoreData

class StatusViewController: UIViewController {

    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var applyAgainBtn: UIButton!

    var context: NSManagedObjectContext!
    var currentUserName: String = ""
    var currentApplication: NSManagedObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        
        if let newName = UserDefaults.standard.string(forKey: "userLogin") {
            self.currentUserName = newName
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkApplicationStatus()
    }
    
    func checkApplicationStatus() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TrainerApplication")
        
        let userRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        userRequest.predicate = NSPredicate(format: "name ==[c] %@", currentUserName)
        
        guard let userResult = try? context.fetch(userRequest),
              userResult.count > 0,
              let currentUser = userResult[0] as? NSManagedObject else {
            return
        }
        
        request.predicate = NSPredicate(format: "userOwner == %@", currentUser)
        
        do {
            let result = try context.fetch(request)
            
            if result.count > 0 {
                currentApplication = result[0] as? NSManagedObject
                let status = currentApplication?.value(forKey: "applicationStatus") as? String ?? "Pending"
                
                updateUIForStatus(status: status)
            } else {
                messageLbl.text = "No application found"
            }
        } catch {
            print("Error fetching application: \(error)")
        }
    }
    
    func updateUIForStatus(status: String) {
        switch status {
        case "Pending":
            messageLbl.text = "Thank you for applying,\nYour application will be\nreviewed by our admin team."
            applyAgainBtn.isHidden = true
            
        case "Rejected":
            messageLbl.text = "We appreciate your interest in becoming a trainer. \nUnfortunately, your application was not accepted at this time. \nYou can apply again if you wish."
            applyAgainBtn.isHidden = false
            
        case "Accepted":
            messageLbl.text = "Congratulations! \nYour application has been accepted. \nWelcome to our trainer team!"
            applyAgainBtn.isHidden = true
            
        default:
            messageLbl.text = "Thank you for applying,\nYour application will be\nreviewed by our admin team"
            applyAgainBtn.isHidden = true
        }
    }
    
    @IBAction func applyAgainBtn(_ sender: Any) {
        deleteRejectedApplication()
        
        UserDefaults.standard.set(true, forKey: "skipApplyCheck")
        
        if let navController = navigationController, navController.viewControllers.count > 1 {
            navController.popViewController(animated: true)
        } else if presentingViewController != nil {
            dismiss(animated: true)
        } else if let tabBarController = tabBarController {
            if let viewControllers = tabBarController.viewControllers {
                for (index, vc) in viewControllers.enumerated() {
                    if let navVC = vc as? UINavigationController,
                       navVC.viewControllers.first is ApplyViewController {
                        tabBarController.selectedIndex = index
                        return
                    }
                    if vc is ApplyViewController {
                        tabBarController.selectedIndex = index
                        return
                    }
                }
            }
        } else {
            print("Tidak bisa kembali")
        }
    }
    
    func deleteRejectedApplication() {
        guard let application = currentApplication else {
            return
        }
        
        context.delete(application)
        
        do {
            try context.save()
        } catch {
            print("Gagal menghapus aplikasi: \(error)")
        }
    }
}
