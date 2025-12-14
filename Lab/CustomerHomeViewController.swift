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
    
    var context: NSManagedObjectContext!
    var approvedTrainers: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        
        setupTableView()
        
        loadApprovedTrainers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let namaBaru = UserDefaults.standard.string(forKey: "userLogin") {
            name.text = "Welcome, \(namaBaru)"
        }
        
        loadApprovedTrainers()
    }
    
    func setupTableView() {
        guard let tableView = TrainerTableView else {
            return
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 123
        tableView.separatorStyle = .singleLine
        tableView.allowsSelection = false
    }
    
    func loadApprovedTrainers() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TrainerApplication")
        
        request.predicate = NSPredicate(format: "applicationStatus == %@", "Accepted")
        
        do {
            let result = try context.fetch(request)
            approvedTrainers = result as! [NSManagedObject]
            
            TrainerTableView?.reloadData()
            
        } catch {
            showAlert(message: "Failed to load trainers")
        }
    }
    
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

extension CustomerHomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return approvedTrainers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AvailableTrainerCell", for: indexPath) as! AvailableTrainerCell
        
        let trainer = approvedTrainers[indexPath.row]
        
        let trainerName = getTrainerName(from: trainer)
        let specialty = trainer.value(forKey: "specialty") as? String ?? "-"
        let workShift = trainer.value(forKey: "workShift") as? String ?? "-"
        let age = trainer.value(forKey: "age") as? Int ?? 0
        
        cell.nameLbl.text = "Name: \(trainerName)"
        cell.ageLbl.text = "Age: \(age)"
        cell.specialtyLbl.text = "Specialty: \(specialty)"
        cell.workShiftLbl.text = "Work Shift: \(workShift)"
        
        return cell
    }
}

extension CustomerHomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}
