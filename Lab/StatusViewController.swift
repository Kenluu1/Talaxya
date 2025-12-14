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
    
    // MARK: - Properties
    var context: NSManagedObjectContext!
    var currentUserName: String = ""
    var currentApplication: NSManagedObject?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        
        // Setup Context
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        
        // Get current user name
        if let newName = UserDefaults.standard.string(forKey: "userLogin") {
            self.currentUserName = newName
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Cek status setiap kali muncul
        checkApplicationStatus()
    }
    
    // MARK: - Data Loading
    func checkApplicationStatus() {
        // Fetch aplikasi user dari Core Data
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TrainerApplication")
        
        // Fetch user dulu untuk dapat relasi
        let userRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        userRequest.predicate = NSPredicate(format: "name ==[c] %@", currentUserName)
        
        guard let userResult = try? context.fetch(userRequest),
              userResult.count > 0,
              let currentUser = userResult[0] as? NSManagedObject else {
            print("⚠️ User tidak ditemukan")
            return
        }
        
        // Fetch aplikasi yang punya relasi dengan user ini
        request.predicate = NSPredicate(format: "userOwner == %@", currentUser)
        
        do {
            let result = try context.fetch(request)
            
            if result.count > 0 {
                currentApplication = result[0] as? NSManagedObject
                let status = currentApplication?.value(forKey: "applicationStatus") as? String ?? "Pending"
                
                print("📋 Status aplikasi: \(status)")
                
                // Update UI berdasarkan status
                updateUIForStatus(status: status)
            } else {
                // Tidak ada aplikasi (seharusnya tidak terjadi jika user sudah apply)
                print("⚠️ Tidak ada aplikasi ditemukan")
                messageLbl.text = "No application found"
            }
        } catch {
            print("❌ Error fetching application: \(error)")
        }
    }
    
    // MARK: - UI Update
    func updateUIForStatus(status: String) {
        switch status {
        case "Pending":
            messageLbl.text = "Thank you for applying,\nYour application will be\nreviewed by our admin team"
            applyAgainBtn.isHidden = true // Hide tombol jika Pending
            
        case "Rejected":
            messageLbl.text = "We appreciate your interest in becoming a trainer. \nUnfortunately, your application was not accepted at this time. \nYou can apply again if you wish."
            applyAgainBtn.isHidden = false // Show tombol jika Rejected
            
        case "Accepted":
            messageLbl.text = "Congratulations! \nYour application has been accepted. \nWelcome to our trainer team!"
            applyAgainBtn.isHidden = true // Hide tombol jika Accepted
            
        default:
            messageLbl.text = "Thank you for applying,\nYour application will be\nreviewed by our admin team"
            applyAgainBtn.isHidden = true
        }
    }
    
    // MARK: - Actions
    @IBAction func applyAgainBtn(_ sender: Any) {
        print("🔙 Apply Again button tapped")
        
        // Hapus aplikasi lama yang Rejected sebelum kembali ke Apply page
        deleteRejectedApplication()
        
        // Set flag di UserDefaults untuk skip check di ApplyViewController
        UserDefaults.standard.set(true, forKey: "skipApplyCheck")
        
        // Cek apakah dalam navigation stack
        if let navController = navigationController, navController.viewControllers.count > 1 {
            // Jika dalam navigation stack dan ada view controller sebelumnya, pop kembali
            print("✅ Pop dari navigation stack")
            navController.popViewController(animated: true)
        } else if presentingViewController != nil {
            // Jika di-present modally, dismiss
            print("✅ Dismiss modal")
            dismiss(animated: true)
        } else if let tabBarController = tabBarController {
            // Jika dalam TabBarController, switch ke tab Apply (biasanya index 1)
            // Cari tab yang punya ApplyViewController
            if let viewControllers = tabBarController.viewControllers {
                for (index, vc) in viewControllers.enumerated() {
                    // Cek apakah ini NavigationController yang punya ApplyViewController
                    if let navVC = vc as? UINavigationController,
                       navVC.viewControllers.first is ApplyViewController {
                        print("✅ Switch ke tab Apply (index: \(index))")
                        tabBarController.selectedIndex = index
                        return
                    }
                    // Atau langsung ApplyViewController
                    if vc is ApplyViewController {
                        print("✅ Switch ke tab Apply (index: \(index))")
                        tabBarController.selectedIndex = index
                        return
                    }
                }
            }
            print("⚠️ Tab Apply tidak ditemukan")
        } else {
            print("⚠️ Tidak bisa kembali - tidak dalam navigation stack, modal, atau tab bar")
        }
    }
    
    // MARK: - Delete Application
    func deleteRejectedApplication() {
        guard let application = currentApplication else {
            print("⚠️ Tidak ada aplikasi untuk dihapus")
            return
        }
        
        // Hapus aplikasi dari context
        context.delete(application)
        
        do {
            try context.save()
            print("✅ Aplikasi lama berhasil dihapus")
        } catch {
            print("❌ Gagal menghapus aplikasi: \(error)")
        }
    }
}
