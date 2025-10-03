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
    func didTapDeleteButton()
}

protocol AddTaskInteractorInput: AnyObject {
    func saveTask(title: String, details: String?, taskToEdit: Task?)
    func deleteTask(_ task: Task)
}

protocol AddTaskInteractorOutput: AnyObject {
    func didSaveTaskSuccessfully()
    func didFailToSaveTask(with error: Error)
    func didDeleteTaskSuccessfully()
    func didFailToDeleteTask(with error: Error)
}

protocol AddTaskRouterInput: AnyObject {
    func dismissAddTaskScreen()
}

protocol AddTaskModuleBuilderProtocol: AnyObject {
    static func buildAddTaskModule(coreDataManager: CoreDataManager, taskToEdit: Task?) -> UIViewController
}
