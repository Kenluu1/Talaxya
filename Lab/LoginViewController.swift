import UIKit
import CoreData

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    var context: NSManagedObjectContext!
    var name: String = ""
    var userRole: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTF.text = ""
        passwordTF.text = ""
    }
    
    @IBAction func signInBTN(_ sender: Any) {
        
        guard let email = emailTF.text, !email.isEmpty,
              let password = passwordTF.text, !password.isEmpty else {
            showAlert(message: "TextField Must Not Be Empty")
            return
        }
        
      
        if isUserExists(email: email, password: password) {
            print("Login Success, User: \(self.name), Role: \(self.userRole)")
            UserDefaults.standard.set(self.name, forKey: "userLogin")
            UserDefaults.standard.set(self.userRole, forKey: "userRole")
            // Clear password field setelah login sukses
            passwordTF.text = ""
            
            // Redirect berdasarkan role
            print("🔀 Checking role for redirect:")
            print("   - userRole value: '\(self.userRole)'")
            print("   - userRole count: \(self.userRole.count)")
            print("   - Is Admin?: \(self.userRole == "Admin")")
            
            if self.userRole.trimmingCharacters(in: .whitespaces) == "Admin" {
                print("✅ Redirecting to Admin Home")
                performSegue(withIdentifier: "LoginToAdminHome", sender: self)
            } else {
                print("✅ Redirecting to Customer Home")
                performSegue(withIdentifier: "LoginToHome", sender: self)
            }
        } else {
            print("Login Failed")
            // Clear password field setelah login gagal (untuk keamanan)
            passwordTF.text = ""
            showAlert(message: "Invalid Credentials")
        }
    }
    
    @IBAction func signUpBTN(_ sender: Any) {
        performSegue(withIdentifier: "LoginToRegister", sender: self)
    }
    
    func isUserExists(email: String, password: String) -> Bool {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        request.predicate = NSPredicate(format: "email == %@ AND password == %@", email, password)
        
        do {
            let result = try context.fetch(request)
            
      
            if result.count > 0 {
                let dataUser = result[0] as! NSManagedObject
                self.name = dataUser.value(forKey: "name") as? String ?? "User"
                
                // Get role dan pastikan tidak nil/kosong
                if let role = dataUser.value(forKey: "role") as? String, !role.isEmpty {
                    self.userRole = role.trimmingCharacters(in: .whitespaces)
                } else {
                    self.userRole = "Customer" // Default jika role kosong/nil
                }
                
                // Debug: Print data yang ditemukan
                print("🔍 Data dari database:")
                print("   - Name: \(self.name)")
                print("   - Email: \(dataUser.value(forKey: "email") as? String ?? "nil")")
                print("   - Role (raw): '\(dataUser.value(forKey: "role") as? String ?? "nil")'")
                print("   - Role (processed): '\(self.userRole)'")
                
                return true
            } else {
                return false
            }
            
        } catch {
            print("Error: \(error)")
            return false
        }
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Warning",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

}
