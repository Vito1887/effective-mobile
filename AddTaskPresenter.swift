import Foundation

// Импортируем протоколы, определенные в AddTaskProtocols.swift
// MARK: - Protocols are defined in AddTaskProtocols.swift

// MARK: - Presenter Class
class AddTaskPresenter: AddTaskViewOutput, AddTaskInteractorOutput {

    weak var view: AddTaskViewInput?
    var interactor: AddTaskInteractorInput!
    var router: AddTaskRouterInput!

    // MARK: - AddTaskViewOutput Methods (реагируем на действия View)

    func viewDidLoad() {
        // Настройка View при загрузке (например, если используется для редактирования, загрузить данные)
        // Для добавления новой задачи здесь ничего особенного не требуется, View может просто отобразить пустые поля.
        view?.configure(with: nil, initialDetails: nil) // Отображаем пустые поля
    }

    func didTapSaveButton(title: String?, details: String?) { // Убедитесь, что здесь title String?
        // TODO: Basic validation
        // Используем guard let для безопасной распаковки и проверки на пустоту
        guard let titleText = title?.trimmingCharacters(in: .whitespacesAndNewlines), !titleText.isEmpty else {
            // Показываем сообщение об ошибке пользователю через View
            view?.showSaveErrorMessage("Название задачи не может быть пустым.")
            return
        }
        // Вызываем Interactor для сохранения, передавая обрезанную строку названия
        interactor.saveNewTask(title: titleText, details: details?.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    func didTapCancelButton() {
        // Вызываем Router для закрытия экрана
        router.dismissAddTaskScreen()
    }

    // MARK: - AddTaskInteractorOutput Methods (реагируем на результаты от Interactor'а)

    func didSaveTaskSuccessfully() {
        view?.showSaveSuccessMessage() // Показываем сообщение об успехе (опционально)
        router.dismissAddTaskScreen() // Закрываем экран после успешного сохранения
    }

    func didFailToSaveTask(with error: Error) {
        view?.showSaveErrorMessage("Не удалось сохранить задачу: \(error.localizedDescription)") // Показываем ошибку
    }
}
