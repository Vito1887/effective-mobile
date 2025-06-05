import UIKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var coreDataManager: CoreDataManager!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("SceneDelegate: scene(_:willConnectTo:options:) called")
        guard let windowScene = (scene as? UIWindowScene) else { return }

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
             fatalError("Cannot get AppDelegate")
        }
        let persistentContainer = appDelegate.persistentContainer

        coreDataManager = CoreDataManager(container: persistentContainer)

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let todoViewController = ToDoModuleBuilder.buildToDoModule(coreDataManager: coreDataManager)

        let navigationController = UINavigationController(rootViewController: todoViewController)

        window.rootViewController = navigationController

        window.makeKeyAndVisible()
    }
}
