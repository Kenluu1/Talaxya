import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    var context: NSManagedObjectContext!
    var Usernames: String = ""
    
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
            print("Login Success, User: \(self.Usernames)")
            UserDefaults.standard.set(self.Usernames, forKey: "userLogin")
            performSegue(withIdentifier: "LoginToHome", sender: self)
        } else {
            print("Login Failed")
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
                self.Usernames = dataUser.value(forKey: "username") as? String ?? "User"
                
                return true
            } else {
                return false
            }
            
        } catch {
            print("Error: \(error)")
            return false
        }
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           
        if segue.identifier == "LoginToHome" {
             if let tabBarController = segue.destination as? UITabBarController {
                  
                 if let tabs = tabBarController.viewControllers {
                      
                     for halaman in tabs {
                          
                     
                         if let homeVC = halaman as? CustomerHomeViewController {
                             homeVC.usernameData = self.Usernames
                         }
                         
                         
                         else if let nav = halaman as? UINavigationController,
                                 let homeInNav = nav.topViewController as? CustomerHomeViewController {
                             homeInNav.usernameData = self.Usernames

                         }
                         
                         
                         if let profileVC = halaman as? ProfileViewController {
                             profileVC.currentUserName = self.Usernames
                             
                         }
                         
              
                         else if let nav = halaman as? UINavigationController,
                                 let profileInNav = nav.topViewController as? ProfileViewController {
                             profileInNav.currentUserName = self.Usernames
                             
                         }
                     }
                 }
             }
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
