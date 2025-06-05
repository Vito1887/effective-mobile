import Foundation
import UIKit // Для UIViewController

// MARK: - View Input (Presenter -> View)
protocol AddTaskViewInput: AnyObject {
    func configure(with initialTitle: String?, initialDetails: String?) // Настройка полей (полезно и для редактирования)
    func showSaveSuccessMessage()
    func showSaveErrorMessage(_ message: String)
     func dismissView() // Закрыть экран
}

// MARK: - View Output (View -> Presenter)
protocol AddTaskViewOutput: AnyObject {
    func viewDidLoad()
    func didTapSaveButton(title: String?, details: String?) // Убедитесь, что здесь String?
    func didTapCancelButton()
}

// MARK: - Interactor Input (Presenter -> Interactor)
protocol AddTaskInteractorInput: AnyObject {
    func saveNewTask(title: String, details: String?)
     // Если будет использоваться для редактирования, добавить методы для загрузки/сохранения существующей задачи
}

// MARK: - Interactor Output (Interactor -> Presenter)
protocol AddTaskInteractorOutput: AnyObject {
    func didSaveTaskSuccessfully()
    func didFailToSaveTask(with error: Error)
}

// MARK: - Router Input (Presenter -> Router)
protocol AddTaskRouterInput: AnyObject {
    func dismissAddTaskScreen() // Закрыть экран добавления задачи
}

// MARK: - Module Builder
protocol AddTaskModuleBuilderProtocol: AnyObject {
    // Убедитесь, что здесь есть параметр coreDataManager
    static func buildAddTaskModule(coreDataManager: CoreDataManager) -> UIViewController
}
