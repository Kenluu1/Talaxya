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
        
        // Setup Context
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        

        print("📝 Halaman Apply dibuka oleh: \(currentUserName)")
    }
    
    @IBAction func applyBTN(_ sender: Any) {
        
        // Validasi Kosong
        if specialtyTF.text?.isEmpty == true ||
           workShiftTF.text?.isEmpty == true ||
           ageTF.text?.isEmpty == true {
            
            showAlert(message: "Semua kolom harus diisi!")
            return
        }
        
      
        saveApplication()
    }
    
 
    func saveApplication() {
  
        guard let entity = NSEntityDescription.entity(forEntityName: "TrainerApplication", in: context) else {
            print("Error: Entity 'TrainerApplication' tidak ditemukan!")
            return
        }
        
        let newApp = NSManagedObject(entity: entity, insertInto: context)
        
      
        newApp.setValue(specialtyTF.text, forKey: "specialty")
        newApp.setValue(workShiftTF.text, forKey: "workShift")
        newApp.setValue(ageTF.text, forKey: "age")
        

        newApp.setValue(currentUserName, forKey: "applicantName")
        
  
        newApp.setValue("Pending", forKey: "status")
        
        do {
            try context.save()
            print("✅ Lamaran Berhasil Disimpan!")
            
            // Munculkan Alert Sukses
            let alert = UIAlertController(title: "Berhasil",
                                          message: "Lamaran terkirim! Status saat ini: Pending.",
                                          preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
 
                self.navigationController?.popViewController(animated: true)
                        
            }))
            
            self.present(alert, animated: true)
            
        } catch {
            print("Gagal simpan: \(error)")
            showAlert(message: "Gagal menyimpan data")
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}
