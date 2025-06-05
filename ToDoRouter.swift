import UIKit
// Возможно, потребуется импорт CoreData для Task, если он используется напрямую
// import CoreData

// Импортируем протоколы из ToDoProtocols.swift и AddTaskProtocols.swift
// MARK: - Protocols are defined in ToDoProtocols.swift and AddTaskProtocols.swift

// MARK: - Router Class
class ToDoRouter: ToDoRouterInput {

    weak var viewController: UIViewController? // Ссылка на View Controller (слабая для избежания циклов)
    private let coreDataManager: CoreDataManager // Добавляем свойство для CoreDataManager

    // MARK: - Initialization
    init(coreDataManager: CoreDataManager) { // Принимаем CoreDataManager при инициализации
        self.coreDataManager = coreDataManager
    }


    // MARK: - ToDoRouterInput Methods (реализуем методы навигации)

    func presentAddTaskScreen() {
        // Используем AddTaskModuleBuilder для создания модуля, передавая coreDataManager
        // Убедитесь, что вызов передает coreDataManager
        let addTaskViewController = AddTaskModuleBuilder.buildAddTaskModule(coreDataManager: coreDataManager)

        // Представляем экран добавления задачи модально, обернув его в Navigation Controller
        let navigationController = UINavigationController(rootViewController: addTaskViewController)
        viewController?.present(navigationController, animated: true, completion: nil)

         print("Navigate to Add Task screen")
    }

    func presentEditTaskScreen(for task: Task) {
        // TODO: Implement presenting Edit Task screen with task details
        // Пример:
        // let editTaskViewController = EditTaskModuleBuilder.buildEditTaskModule(with: task, coreDataManager: coreDataManager) // Передаем coreDataManager
        // viewController?.navigationController?.pushViewController(editTaskViewController, animated: true)
        print("Navigate to Edit Task screen for task: \(task.title ?? "")")
    }

    // TODO: Implement other navigation methods if needed
}
