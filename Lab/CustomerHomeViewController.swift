//
//  CustomerHomeViewController.swift
//  Lab
//
//  Created by eslilinnn on 07/10/25.
//

import UIKit
import CoreData

class CustomerHomeViewController: UIViewController {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var TrainerTableView: UITableView!
    
    // MARK: - Properties
    var context: NSManagedObjectContext!
    var approvedTrainers: [NSManagedObject] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Context
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        
        // Setup TableView
        setupTableView()
        
        // Load approved trainers
        loadApprovedTrainers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let namaBaru = UserDefaults.standard.string(forKey: "userLogin") {
            name.text = "Welcome, \(namaBaru)"
        }
        
        // Reload data setiap kali muncul
        loadApprovedTrainers()
    }
    
    // MARK: - Setup
    func setupTableView() {
        guard let tableView = TrainerTableView else {
            print("⚠️ TrainerTableView outlet belum terhubung di Storyboard")
            return
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 123
        tableView.separatorStyle = .singleLine
        tableView.allowsSelection = false // Cell tidak bisa di-tap (sesuai requirement)
        print("✅ TableView setup berhasil")
    }
    
    // MARK: - Data Loading
    func loadApprovedTrainers() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TrainerApplication")
        
        // Filter hanya yang status "Accepted"
        request.predicate = NSPredicate(format: "applicationStatus == %@", "Accepted")
        
        do {
            let result = try context.fetch(request)
            approvedTrainers = result as! [NSManagedObject]
            
            print("📋 Loaded \(approvedTrainers.count) approved trainers")
            
            TrainerTableView?.reloadData()
            
        } catch {
            print("❌ Error loading approved trainers: \(error)")
            showAlert(message: "Failed to load trainers")
        }
    }
    
    // MARK: - Helper Methods
    func getTrainerName(from application: NSManagedObject) -> String {
        if let userOwner = application.value(forKey: "userOwner") as? NSManagedObject {
            return userOwner.value(forKey: "name") as? String ?? "Unknown"
        }
        return "Unknown"
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension CustomerHomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("📊 numberOfRowsInSection dipanggil: \(approvedTrainers.count) rows")
        return approvedTrainers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AvailableTrainerCell", for: indexPath) as! AvailableTrainerCell
        
        let trainer = approvedTrainers[indexPath.row]
        
        // Get data from trainer application
        let trainerName = getTrainerName(from: trainer)
        let specialty = trainer.value(forKey: "specialty") as? String ?? "-"
        let workShift = trainer.value(forKey: "workShift") as? String ?? "-"
        let age = trainer.value(forKey: "age") as? Int ?? 0
        
        // Populate cell dengan outlet yang ada
        cell.nameLbl.text = "Name: \(trainerName)"
        cell.ageLbl.text = "Age: \(age)"
        cell.specialtyLbl.text = "Specialty: \(specialty)"
        cell.workShiftLbl.text = "Work Shift: \(workShift)"
        
        print("📝 Cell \(indexPath.row): \(trainerName) - \(specialty)")
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CustomerHomeViewController: UITableViewDelegate {
    // Cell tidak bisa di-select (sesuai requirement)
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}
