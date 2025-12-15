//
//  AppDelegate.swift
//  Lab
//
//  Created by eslilinnn on 30/09/25.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Buat akun admin
        createDefaultAdminIfNeeded()
        
        return true
    }
    
    func createDefaultAdminIfNeeded() {
        let context = persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        request.predicate = NSPredicate(format: "role == %@", "Admin")
        
        do {
            let result = try context.fetch(request)
    
            if result.count == 0 {
                createAdmin(name: "Admin", email: "admin@gmail.com", password: "admin", context: context)
            }
        } catch {
            print("Error checking admin: \(error)")
        }
    }
    
    func createAdmin(name: String, email: String, password: String, context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: "Users", in: context) else {
            print("Error: Entity 'Users' not found")
            return
        }
        
        let newAdmin = NSManagedObject(entity: entity, insertInto: context)
        newAdmin.setValue(name, forKey: "name")
        newAdmin.setValue(email, forKey: "email")
        newAdmin.setValue(password, forKey: "password")
        newAdmin.setValue("Admin", forKey: "role")
        
        do {
            try context.save()
            print("Akun admin berhasil dibuat!")
        } catch {
            print("Gagal membuat akun admin: \(error)")
        }
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Lab")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
