import UIKit
import CoreData

class RegisterViewController: UIViewController {

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    
    var context: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
    }
    
    @IBAction func signUpBTN(_ sender: Any) {

        if nameTF.text?.isEmpty == true ||
           emailTF.text?.isEmpty == true ||
           passwordTF.text?.isEmpty == true ||
           confirmPasswordTF.text?.isEmpty == true {
            
            showAlert(message: "Semua kolom harus diisi!")
            return
        }
        let validate = passwordValidation(password: passwordTF.text!, passwordConfirmation: confirmPasswordTF.text!)
        
        if validate {
            // Cek apakah email sudah terdaftar
            if isEmailExists(email: emailTF.text!) {
                showAlert(message: "Email sudah terdaftar! Silakan gunakan email lain atau login.")
                return
            }
            
            if insertUser() {
                // Clear semua text field setelah berhasil
                nameTF.text = ""
                emailTF.text = ""
                passwordTF.text = ""
                confirmPasswordTF.text = ""
                
                let alert = UIAlertController(title: "Berhasil",
                                              message: "Account created successfully, Click OK to proceed to login.",
                                              preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    
                   
                    if let navigation = self.navigationController {
                        navigation.popViewController(animated: true)
                    }

                    else {
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                }))
 
                self.present(alert, animated: true)
            }
        } else {
            showAlert(message: "password and confirmation not same.")
        }
    }
    
   
    func insertUser() -> Bool {
        let name = nameTF.text
        let email = emailTF.text
        let password = passwordTF.text
        
      
        guard let entity = NSEntityDescription.entity(forEntityName: "Users", in: context) else {
            print("Error: Entity 'Users' not found")
            return false
        }
        
        let newUser = NSManagedObject(entity: entity, insertInto: context)
        
        newUser.setValue(name, forKey: "name")
        newUser.setValue(email, forKey: "email")
        newUser.setValue(password, forKey: "password")
        newUser.setValue("Customer", forKey: "role")
        
        do {
            try context.save()
            print("Data stored!")
            return true
        } catch {
            print("Failed: \(error)")
            return false
        }
    }
    
    func passwordValidation(password: String, passwordConfirmation: String) -> Bool {
        return password == passwordConfirmation
    }
    
    func isEmailExists(email: String) -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        request.predicate = NSPredicate(format: "email == %@", email)
        
        do {
            let result = try context.fetch(request)
            return result.count > 0
        } catch {
            print("Error checking email: \(error)")
            return false
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    @IBAction func backToLoginBTN(_ sender: Any) {
        if let navigation = self.navigationController {
            navigation.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }

}
