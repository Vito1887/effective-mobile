import Foundation

class AddTaskPresenter: AddTaskViewOutput, AddTaskInteractorOutput {

    weak var view: AddTaskViewInput?
    var interactor: AddTaskInteractorInput!
    var router: AddTaskRouterInput!

    private var taskToEdit: Task?

    init(taskToEdit: Task? = nil) {
        self.taskToEdit = taskToEdit
    }

    func viewDidLoad() {
        if let task = taskToEdit {
            view?.configureForEditing(task: task)
        } else {
            view?.configure(with: nil, initialDetails: nil)
        }
    }

    func didTapSaveButton(title: String?, details: String?) {
        guard let titleText = title?.trimmingCharacters(in: .whitespacesAndNewlines), !titleText.isEmpty else {
            view?.showSaveErrorMessage("Название задачи не может быть пустым.")
            return
        }

        interactor.saveTask(title: titleText, details: details?.trimmingCharacters(in: .whitespacesAndNewlines), taskToEdit: taskToEdit)
    }

    func didTapCancelButton() {
        router.dismissAddTaskScreen()
    }

    func didSaveTaskSuccessfully() {
        view?.showSaveSuccessMessage()
        router.dismissAddTaskScreen()
    }

    func didFailToSaveTask(with error: Error) {
        view?.showSaveErrorMessage("Не удалось сохранить задачу: \(error.localizedDescription)")
    }
}
