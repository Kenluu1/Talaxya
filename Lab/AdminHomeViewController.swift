//
//  AdminHomeViewController.swift
//  Lab
//
//  Created by Arvin Roeslim on 12/12/25.
//

import UIKit
import CoreData

class AdminHomeViewController: UIViewController {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var totalApplicantLbl: UILabel!
    @IBOutlet weak var totalRejectedLbl: UILabel!
    @IBOutlet weak var totalApprovedLbl: UILabel!
    @IBOutlet weak var carousel: UISegmentedControl!
    @IBOutlet weak var applicationsTableView: UITableView!
    
    var context: NSManagedObjectContext!
    var allApplications: [NSManagedObject] = []
    var filteredApplications: [NSManagedObject] = []
    
    enum FilterType: Int {
        case all = 0
        case pending = 1
        case accepted = 2
        case rejected = 3
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        
        setupTableView()
        
        loadApplications()
        updateDashboardCards()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let namaBaru = UserDefaults.standard.string(forKey: "userLogin") {
            name.text = "Welcome, \(namaBaru)"
        }
        
        loadApplications()
        updateDashboardCards()
    }
    
    func setupTableView() {
        guard let tableView = applicationsTableView else {
            return
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 200
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
    }
    
    func loadApplications() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TrainerApplication")
        
        do {
            let result = try context.fetch(request)
            allApplications = result as! [NSManagedObject]
            
            applyFilter()
            
        } catch {
            showAlert(message: "Failed to load applications")
        }
    }
    
    func applyFilter() {
        guard let filterType = FilterType(rawValue: carousel.selectedSegmentIndex) else {
            filteredApplications = allApplications
            applicationsTableView?.reloadData()
            return
        }
        
        switch filterType {
        case .all:
            filteredApplications = allApplications
        case .pending:
            filteredApplications = allApplications.filter { app in
                let status = app.value(forKey: "applicationStatus") as? String ?? ""
                return status == "Pending"
            }
        case .accepted:
            filteredApplications = allApplications.filter { app in
                let status = app.value(forKey: "applicationStatus") as? String ?? ""
                return status == "Accepted"
            }
        case .rejected:
            filteredApplications = allApplications.filter { app in
                let status = app.value(forKey: "applicationStatus") as? String ?? ""
                return status == "Rejected"
            }
        }
        
        applicationsTableView?.reloadData()
    }
    
    func updateDashboardCards() {
        let totalApplicant = allApplications.count
        totalApplicantLbl.text = "\(totalApplicant)"
        
        let totalRejected = allApplications.filter { app in
            let status = app.value(forKey: "applicationStatus") as? String ?? ""
            return status == "Rejected"
        }.count
        totalRejectedLbl.text = "\(totalRejected)"
        
        let totalApproved = allApplications.filter { app in
            let status = app.value(forKey: "applicationStatus") as? String ?? ""
            return status == "Accepted"
        }.count
        totalApprovedLbl.text = "\(totalApproved)"
    }
    
    @IBAction func carousel(_ sender: UISegmentedControl) {
        applyFilter()
    }
    
    func updateApplicationStatus(application: NSManagedObject, status: String) {
        application.setValue(status, forKey: "applicationStatus")
        
        do {
            try context.save()
            
            loadApplications()
            updateDashboardCards()
            
            let statusMessage = status == "Accepted" ? "accepted" : "rejected"
            showAlert(message: "Application \(statusMessage) successfully!")
            
        } catch {
            showAlert(message: "Failed to update application status")
        }
    }
    
    func getApplicantName(from application: NSManagedObject) -> String {
        if let userOwner = application.value(forKey: "userOwner") as? NSManagedObject {
            return userOwner.value(forKey: "name") as? String ?? "Unknown"
        }
        return "Unknown"
    }
    
    func getApplicantEmail(from application: NSManagedObject) -> String {
        if let userOwner = application.value(forKey: "userOwner") as? NSManagedObject {
            return userOwner.value(forKey: "email") as? String ?? "No Email"
        }
        return "No Email"
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension AdminHomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredApplications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "applicantCardCell", for: indexPath) as! applicantCardCell
        
        let application = filteredApplications[indexPath.row]
        
        let applicantName = getApplicantName(from: application)
        let applicantEmail = getApplicantEmail(from: application)
        let specialty = application.value(forKey: "specialty") as? String ?? "-"
        let workShift = application.value(forKey: "workShift") as? String ?? "-"
        let age = application.value(forKey: "age") as? Int ?? 0
        let status = application.value(forKey: "applicationStatus") as? String ?? "Pending"
        
        cell.nameLbl.text = applicantName
        cell.emailLbl.text = applicantEmail
        cell.specialtyLbl.text = "Specialty: \(specialty)"
        cell.workShiftLbl.text = "Work Shift: \(workShift)"
        cell.ageLbl.text = "Age: \(age)"
        
        cell.application = application
        
        cell.updateButtonVisibility(status: status)
        
        cell.onAccept = { [weak self] app in
            self?.updateApplicationStatus(application: app, status: "Accepted")
        }
        
        cell.onReject = { [weak self] app in
            self?.updateApplicationStatus(application: app, status: "Rejected")
        }
        
        return cell
    }
}

extension AdminHomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}
