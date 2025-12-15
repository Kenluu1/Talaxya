//
//  ApplyViewController.swift
//  Lab
//
//  Created by eslilinnn on 07/10/25.
//

import UIKit
import CoreData

class ApplyViewController: UIViewController {

    @IBOutlet weak var specialtyTF: UITextField!
    @IBOutlet weak var workShiftTF: UITextField!
    @IBOutlet weak var ageTF: UITextField!
    

    var context: NSManagedObjectContext!
    var currentUserName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let newName = UserDefaults.standard.string(forKey: "userLogin") {
            self.currentUserName = newName
        }
        
        if UserDefaults.standard.bool(forKey: "skipApplyCheck") {
            UserDefaults.standard.removeObject(forKey: "skipApplyCheck")
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.checkExistingApplication()
        }
    }
    
    func checkExistingApplication() {
        let userRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        userRequest.predicate = NSPredicate(format: "name ==[c] %@", currentUserName)
        
        guard let userResult = try? context.fetch(userRequest),
              userResult.count > 0,
              let currentUser = userResult[0] as? NSManagedObject else {
            return
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TrainerApplication")
        request.predicate = NSPredicate(format: "userOwner == %@", currentUser)
        
        do {
            let result = try context.fetch(request)
            
            if result.count > 0 {
                performSegue(withIdentifier: "Apply", sender: self)
            }
        } catch {
            print("Error checking application: \(error)")
        }
    }
    
    @IBAction func applyBTN(_ sender: Any) {
        if specialtyTF.text?.isEmpty == true ||
           workShiftTF.text?.isEmpty == true ||
           ageTF.text?.isEmpty == true {
            
            showAlert(message: "Semua kolom harus diisi!")
            return
        }
        
        saveApplication()
        performSegue(withIdentifier: "Apply", sender: self)
    }
    
    func saveApplication() {
        guard let entity = NSEntityDescription.entity(forEntityName: "TrainerApplication", in: context) else {
            return
        }
        
        let userRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        userRequest.predicate = NSPredicate(format: "name ==[c] %@", currentUserName)
        
        guard let userResult = try? context.fetch(userRequest),
              userResult.count > 0,
              let currentUser = userResult[0] as? NSManagedObject else {
            showAlert(message: "User tidak ditemukan. Silakan login ulang.")
            return
        }
        
        let newApp = NSManagedObject(entity: entity, insertInto: context)
        
        newApp.setValue(specialtyTF.text, forKey: "specialty")
        newApp.setValue(workShiftTF.text, forKey: "workShift")
        newApp.setValue(Int(ageTF.text ?? "") ?? 0, forKey: "age")
        newApp.setValue("Pending", forKey: "applicationStatus")
        
        newApp.setValue(currentUser, forKey: "userOwner")
        
        do {
            try context.save()
        } catch {
            showAlert(message: "Gagal menyimpan data")
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}
