import UIKit

class ToDoRouter: ToDoRouterInput {

    weak var viewController: UIViewController?
    private let coreDataManager: CoreDataManager // Добавляем свойство для CoreDataManager

    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }

    func presentAddTaskScreen() {
        let addTaskViewController = AddTaskModuleBuilder.buildAddTaskModule(coreDataManager: coreDataManager)

        let navigationController = UINavigationController(rootViewController: addTaskViewController)
        viewController?.present(navigationController, animated: true, completion: nil)

         print("Navigate to Add Task screen")
    }

    func presentEditTaskScreen(for task: Task) {
        print("Navigate to Edit Task screen for task: \(task.title ?? "")")
    }
}
