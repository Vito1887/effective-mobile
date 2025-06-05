import Foundation

class AddTaskPresenter: AddTaskViewOutput, AddTaskInteractorOutput {

    weak var view: AddTaskViewInput?
    var interactor: AddTaskInteractorInput!
    var router: AddTaskRouterInput!

    func viewDidLoad() {
        view?.configure(with: nil, initialDetails: nil)
    }

    func didTapSaveButton(title: String?, details: String?) {
        guard let titleText = title?.trimmingCharacters(in: .whitespacesAndNewlines), !titleText.isEmpty else {
            view?.showSaveErrorMessage("Название задачи не может быть пустым.")
            return
        }

        interactor.saveNewTask(title: titleText, details: details?.trimmingCharacters(in: .whitespacesAndNewlines))
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
