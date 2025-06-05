import Foundation
import UIKit

protocol ToDoViewInput: AnyObject {
    func displayTasks(_ tasks: [Task])
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showErrorMessage(_ message: String)
}

protocol ToDoViewOutput: AnyObject {
    func viewDidLoad()
    func didSelectTask(_ task: Task)
    func didTapAddTask()
    func didSearch(with query: String)
     func didTapToggleCompletion(for task: Task)
     func didSwipeToDelete(_ task: Task)
}

protocol ToDoInteractorInput: AnyObject {
    func loadTasks()
    func addNewTask(title: String, details: String?)
    func updateTaskStatus(task: Task, isCompleted: Bool)
    func updateTaskDetails(task: Task, title: String, details: String?)
    func deleteTask(task: Task)
    func searchTasks(with query: String)
}

protocol ToDoInteractorOutput: AnyObject {
    func didLoadTasks(_ tasks: [Task])
    func didFailToLoadTasks(with error: Error)
    func didAddTask(_ task: Task)
    func didFailToAddTask(with error: Error)
     func taskDidUpdate(_ task: Task)
     func taskDidDelete(_ task: Task)
}

protocol ToDoRouterInput: AnyObject {
    func presentAddTaskScreen()
    func presentEditTaskScreen(for task: Task)
}

protocol ToDoModuleBuilderProtocol: AnyObject {
    static func buildToDoModule(coreDataManager: CoreDataManager) -> UIViewController
}
