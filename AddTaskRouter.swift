import UIKit

class AddTaskRouter: AddTaskRouterInput {

    weak var viewController: UIViewController?

    func dismissAddTaskScreen() {
        viewController?.dismiss(animated: true, completion: nil)
         print("Dismissing Add Task screen")
    }
}
