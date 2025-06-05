import Foundation

class ToDoPresenter: ToDoViewOutput, ToDoInteractorOutput {

    weak var view: ToDoViewInput?
    var interactor: ToDoInteractorInput!
    var router: ToDoRouterInput!

    private var currentTasks: [Task] = []

    func viewDidLoad() {
        view?.showLoadingIndicator()
        interactor.loadTasks()
    }

    func didSelectTask(_ task: Task) {
        router.presentEditTaskScreen(for: task)
    }

    func didTapAddTask() {
        router.presentAddTaskScreen()
    }

    func didSearch(with query: String) {
        interactor.searchTasks(with: query)
    }

    func didTapToggleCompletion(for task: Task) {
        interactor.updateTaskStatus(task: task, isCompleted: !task.isCompleted)
    }

    func didSwipeToDelete(_ task: Task) {
        interactor.deleteTask(task: task)
    }

    func didLoadTasks(_ tasks: [Task]) {
        currentTasks = tasks.sorted(by: { $0.creationDate ?? Date() > $1.creationDate ?? Date() })
        view?.displayTasks(currentTasks)
        view?.hideLoadingIndicator()
    }

    func didFailToLoadTasks(with error: Error) {
        view?.hideLoadingIndicator()
        view?.showErrorMessage("Failed to load tasks: \(error.localizedDescription)")
    }

    func didAddTask(_ task: Task) {
        interactor.loadTasks()
    }

    func didFailToAddTask(with error: Error) {
         view?.showErrorMessage("Failed to add task: \(error.localizedDescription)")
    }

    func taskDidUpdate(_ task: Task) {
        if let index = currentTasks.firstIndex(where: { $0.objectID == task.objectID }) {
            currentTasks[index] = task
             view?.displayTasks(currentTasks.sorted(by: { $0.creationDate ?? Date() > $1.creationDate ?? Date() }))
        } else {
             interactor.loadTasks()
        }
    }

    func taskDidDelete(_ task: Task) {
         if let index = currentTasks.firstIndex(where: { $0.objectID == task.objectID }) {
             currentTasks.remove(at: index)
             view?.displayTasks(currentTasks.sorted(by: { $0.creationDate ?? Date() > $1.creationDate ?? Date() }))
         }
    }
}
