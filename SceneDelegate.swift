import UIKit
import CoreData // Добавляем импорт CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var coreDataManager: CoreDataManager! // Добавляем свойство для менеджера CoreData

    // persistentContainer должен быть доступен. Если он в AppDelegate, получаем его оттуда.
    // Если он был в SceneDelegate, убедитесь, что он определен здесь.
    // Предполагаем, что persistentContainer находится в AppDelegate.

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // Получаем persistentContainer из AppDelegate (наиболее распространенный подход)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
             fatalError("Cannot get AppDelegate")
        }
        let persistentContainer = appDelegate.persistentContainer

        // Инициализируем CoreDataManager с контейнером
        coreDataManager = CoreDataManager(container: persistentContainer)

        // Создаем главное окно
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        // Собираем ToDo модуль с помощью Module Builder, передавая ему coreDataManager
        let todoViewController = ToDoModuleBuilder.buildToDoModule(coreDataManager: coreDataManager)

        // Встраиваем ToDoViewController в UINavigationController
        let navigationController = UINavigationController(rootViewController: todoViewController)

        // Устанавливаем UINavigationController как корневой View Controller окна
        window.rootViewController = navigationController

        // Делаем окно видимым
        window.makeKeyAndVisible()
    }

    // ... остальные методы SceneDelegate ...
}
