import UIKit
import CoreData // Убедитесь, что импорт CoreData присутствует

@main // Этот атрибут указывает на то, что AppDelegate является точкой входа приложения
class AppDelegate: UIResponder, UIApplicationDelegate {

    // В современных проектах с SceneDelegate, окно обычно управляется SceneDelegate
    // var window: UIWindow? // Эта строка часто удаляется или комментируется при использовании SceneDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Переопределите точку настройки после запуска приложения.
        // Большая часть настройки UI переносится в SceneDelegate.
        // Здесь могут быть инициализация сторонних библиотек, Push Notifications и т.д.
        return true
    }

    // MARK: UISceneSession Lifecycle - Эти методы обрабатывают новые сцены и их жизненный цикл
    // Они важны при использовании SceneDelegate
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack - Это наш стек Core Data, доступный из AppDelegate

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        // Замените "effective_mobile" на имя вашего файла модели данных (.xcdatamodeld)
        // Имя модели данных обычно совпадает с именем проекта, если вы не переименовывали файл модели.
        let container = NSPersistentContainer(name: "effective_mobile")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or ownership information.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support - Метод для сохранения контекста Core Data

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
