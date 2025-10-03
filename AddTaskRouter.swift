import UIKit

class AddTaskRouter: AddTaskRouterInput {

    weak var viewController: UIViewController?

    func dismissAddTaskScreen() {
        guard let vc = viewController else { return }

        if let nav = vc.navigationController {
            if nav.presentingViewController == nil || nav.viewControllers.count > 1 {
                nav.popViewController(animated: true)
                return
            }
        }

        vc.presentingViewController?.dismiss(animated: true, completion: nil)
        vc.dismiss(animated: true, completion: nil)
    }
}
