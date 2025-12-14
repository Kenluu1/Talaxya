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
    
    // MARK: - Properties
    var context: NSManagedObjectContext!
    var allApplications: [NSManagedObject] = []
    var filteredApplications: [NSManagedObject] = []
     
    // Filter options: All, Pending, Accepted, Rejected
    enum FilterType: Int {
        case all = 0
        case pending = 1
        case accepted = 2
        case rejected = 3
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Context
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        
        // Setup TableView
        setupTableView()
        
        // Load initial data
        loadApplications()
        updateDashboardCards()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Update welcome message
        if let namaBaru = UserDefaults.standard.string(forKey: "userLogin") {
            name.text = "Welcome, \(namaBaru)"
        }
        
        // Reload data setiap kali muncul (untuk update setelah Accept/Reject)
        loadApplications()
        updateDashboardCards()
    }
    
    // MARK: - Setup
    func setupTableView() {
        guard let tableView = applicationsTableView else {
            print("⚠️ ERROR: applicationsTableView outlet belum terhubung di Storyboard!")
            print("   → Buka Storyboard → Control-drag dari TableView ke AdminHomeViewController")
            print("   → Pilih 'applicationsTableView'")
            return
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 200
        tableView.separatorStyle = .none
        tableView.allowsSelection = false // Cell tidak bisa di-tap
        print("✅ TableView setup berhasil")
    }
    
    // MARK: - Data Loading
    func loadApplications() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TrainerApplication")
        
        do {
            let result = try context.fetch(request)
            allApplications = result as! [NSManagedObject]
            
            print("📋 Loaded \(allApplications.count) total applications")
            
            // Apply current filter
            applyFilter()
            
        } catch {
            print("❌ Error loading applications: \(error)")
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
        
        print("🔍 Filtered to \(filteredApplications.count) applications")
        applicationsTableView?.reloadData()
    }
    
    // MARK: - Dashboard Cards
    func updateDashboardCards() {
        // Total Applicant = semua aplikasi
        let totalApplicant = allApplications.count
        totalApplicantLbl.text = "\(totalApplicant)"
        
        // Total Rejected
        let totalRejected = allApplications.filter { app in
            let status = app.value(forKey: "applicationStatus") as? String ?? ""
            return status == "Rejected"
        }.count
        totalRejectedLbl.text = "\(totalRejected)"
        
        // Total Approved
        let totalApproved = allApplications.filter { app in
            let status = app.value(forKey: "applicationStatus") as? String ?? ""
            return status == "Accepted"
        }.count
        totalApprovedLbl.text = "\(totalApproved)"
        
        print("📊 Dashboard updated - Total: \(totalApplicant), Rejected: \(totalRejected), Approved: \(totalApproved)")
    }
    
    // MARK: - Actions
    @IBAction func carousel(_ sender: UISegmentedControl) {
        applyFilter()
    }
    
    // MARK: - Application Status Update
    func updateApplicationStatus(application: NSManagedObject, status: String) {
        application.setValue(status, forKey: "applicationStatus")
        
        do {
            try context.save()
            print("✅ Application status updated to: \(status)")
            
            // Reload data
            loadApplications()
            updateDashboardCards()
            
            // Show success message
            let statusMessage = status == "Accepted" ? "accepted" : "rejected"
            showAlert(message: "Application \(statusMessage) successfully!")
            
        } catch {
            print("❌ Failed to update status: \(error)")
            showAlert(message: "Failed to update application status")
        }
    }
    
    // MARK: - Helper Methods
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

// MARK: - UITableViewDataSource
extension AdminHomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("📊 numberOfRowsInSection dipanggil: \(filteredApplications.count) rows")
        return filteredApplications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "applicantCardCell", for: indexPath) as! applicantCardCell
        
        let application = filteredApplications[indexPath.row]
        
        // Get data from application
        let applicantName = getApplicantName(from: application)
        let applicantEmail = getApplicantEmail(from: application)
        let specialty = application.value(forKey: "specialty") as? String ?? "-"
        let workShift = application.value(forKey: "workShift") as? String ?? "-"
        let age = application.value(forKey: "age") as? Int ?? 0
        let status = application.value(forKey: "applicationStatus") as? String ?? "Pending"
        
        // Populate cell
        cell.nameLbl.text = applicantName
        cell.emailLbl.text = applicantEmail
        cell.specialtyLbl.text = "Specialty: \(specialty)"
        cell.workShiftLbl.text = "Work Shift: \(workShift)"
        cell.ageLbl.text = "Age: \(age)"
        
        // Store application reference
        cell.application = application
        
        // Hide button jika sudah Accepted atau Rejected
        cell.updateButtonVisibility(status: status)
        
        // Setup button actions dengan closure
        cell.onAccept = { [weak self] app in
            self?.updateApplicationStatus(application: app, status: "Accepted")
        }
        
        cell.onReject = { [weak self] app in
            self?.updateApplicationStatus(application: app, status: "Rejected")
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension AdminHomeViewController: UITableViewDelegate {
    // Cell tidak bisa di-select (sesuai requirement)
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}
