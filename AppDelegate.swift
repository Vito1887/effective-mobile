import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let win = UIWindow(frame: UIScreen.main.bounds)
        self.window = win

        let persistentContainer = self.persistentContainer
        let coreDataManager = CoreDataManager(container: persistentContainer)
        let rootVC = ToDoModuleBuilder.buildToDoModule(coreDataManager: coreDataManager)
        let nav = UINavigationController(rootViewController: rootVC)
        win.rootViewController = nav
        win.makeKeyAndVisible()
        return true
    }

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
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
