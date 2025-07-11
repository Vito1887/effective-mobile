import Foundation
import UIKit

protocol AddTaskViewInput: AnyObject {
    func configure(with initialTitle: String?, initialDetails: String?)
    func configureForEditing(task: Task)
    func showSaveSuccessMessage()
    func showSaveErrorMessage(_ message: String)
     func dismissView()
}

protocol AddTaskViewOutput: AnyObject {
    func viewDidLoad()
    func didTapSaveButton(title: String?, details: String?)
    func didTapCancelButton()
}

protocol AddTaskInteractorInput: AnyObject {
    func saveTask(title: String, details: String?, taskToEdit: Task?)
}

protocol AddTaskInteractorOutput: AnyObject {
    func didSaveTaskSuccessfully()
    func didFailToSaveTask(with error: Error)
}

protocol AddTaskRouterInput: AnyObject {
    func dismissAddTaskScreen()
}

protocol AddTaskModuleBuilderProtocol: AnyObject {
    static func buildAddTaskModule(coreDataManager: CoreDataManager, taskToEdit: Task?) -> UIViewController
}
