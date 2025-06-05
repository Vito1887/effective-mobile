import Foundation
import UIKit // Нужно для UIViewController

// MARK: - View Input (Presenter -> View)
// Методы, которые Презентер вызывает у View для обновления интерфейса
protocol ToDoViewInput: AnyObject {
    func displayTasks(_ tasks: [Task]) // Предполагаем, что Task - это наша сущность CoreData или маппинг
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showErrorMessage(_ message: String)
    // Добавьте другие методы для управления состоянием UI (например, для поиска)
}

// MARK: - View Output (View -> Presenter)
// Методы, которые View вызывает у Презентера в ответ на действия пользователя или события View
protocol ToDoViewOutput: AnyObject {
    func viewDidLoad() // View загрузилась
    func didSelectTask(_ task: Task) // Пользователь выбрал задачу из списка
    func didTapAddTask() // Пользователь нажал кнопку добавления задачи
    func didSearch(with query: String) // Пользователь ввел текст в поиск
    // Добавьте методы для удаления задачи (свайп), изменения статуса (тап по чекбоксу)
     func didTapToggleCompletion(for task: Task)
     func didSwipeToDelete(_ task: Task)
}

// MARK: - Interactor Input (Presenter -> Interactor)
// Методы, которые Презентер вызывает у Интерактора для выполнения бизнес-логики
protocol ToDoInteractorInput: AnyObject {
    func loadTasks()
    func addNewTask(title: String, details: String?)
    func updateTaskStatus(task: Task, isCompleted: Bool)
    func updateTaskDetails(task: Task, title: String, details: String?)
    func deleteTask(task: Task)
    func searchTasks(with query: String)
    // Методы для загрузки из API уже есть в Interactor, но вызываются из loadTasks при необходимости
}

// MARK: - Interactor Output (Interactor -> Presenter)
// Методы, которые Интерактор вызывает у Презентера для передачи результатов операций
protocol ToDoInteractorOutput: AnyObject {
    func didLoadTasks(_ tasks: [Task])
    func didFailToLoadTasks(with error: Error)
    func didAddTask(_ task: Task)
    func didFailToAddTask(with error: Error)
     func taskDidUpdate(_ task: Task)
     func taskDidDelete(_ task: Task)
    // Добавьте другие методы (например, для результатов поиска)
}

// MARK: - Router Input (Presenter -> Router)
protocol ToDoRouterInput: AnyObject {
    func presentAddTaskScreen()
    func presentEditTaskScreen(for task: Task)
    // Добавьте другие методы навигации при необходимости
}

// MARK: - Module Builder
// Протокол для сборки модуля ToDo
protocol ToDoModuleBuilderProtocol: AnyObject {
    // Убедитесь, что здесь есть параметр coreDataManager
    static func buildToDoModule(coreDataManager: CoreDataManager) -> UIViewController
}
