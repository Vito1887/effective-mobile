import UIKit

// MARK: - Router Class
class AddTaskRouter: AddTaskRouterInput {

    weak var viewController: UIViewController?

    // MARK: - AddTaskRouterInput Methods

    func dismissAddTaskScreen() {
        // Закрываем экран добавления задачи.
        // Если экран был представлен модально:
        viewController?.dismiss(animated: true, completion: nil)
        // Если экран был добавлен в Navigation Stack:
        // viewController?.navigationController?.popViewController(animated: true)
         print("Dismissing Add Task screen")
    }

    // TODO: Implement other navigation methods if needed
}
