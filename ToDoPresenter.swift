import Foundation

// MARK: - Presenter Class
class ToDoPresenter: ToDoViewOutput, ToDoInteractorOutput {

    weak var view: ToDoViewInput?
    var interactor: ToDoInteractorInput! // Используем Implicitly Unwrapped Optional, так как будет установлен при сборке модуля
    var router: ToDoRouterInput! // Используем Implicitly Unwrapped Optional

    private var currentTasks: [Task] = [] // Локальное хранилище задач для управления списком

    // MARK: - ToDoViewOutput Methods (реагируем на действия View)

    func viewDidLoad() {
        view?.showLoadingIndicator()
        interactor.loadTasks() // Начинаем загрузку задач при загрузке View
    }

    func didSelectTask(_ task: Task) {
        router.presentEditTaskScreen(for: task) // Переходим на экран редактирования выбранной задачи
    }

    func didTapAddTask() {
        router.presentAddTaskScreen() // Переходим на экран добавления новой задачи
    }

    func didSearch(with query: String) {
        interactor.searchTasks(with: query) // Передаем запрос в Interactor для поиска
    }

    func didTapToggleCompletion(for task: Task) {
        // Переключаем статус и отправляем в Interactor для обновления
        interactor.updateTaskStatus(task: task, isCompleted: !task.isCompleted)
        // View будет обновлена через taskDidUpdate от Interactor'а
    }

    func didSwipeToDelete(_ task: Task) {
        interactor.deleteTask(task: task) // Отправляем в Interactor для удаления
        // View будет обновлена через taskDidDelete от Interactor'а
    }

    // MARK: - ToDoInteractorOutput Methods (реагируем на результаты от Interactor'а)

    func didLoadTasks(_ tasks: [Task]) {
        currentTasks = tasks.sorted(by: { $0.creationDate ?? Date() > $1.creationDate ?? Date() }) // Сортируем по дате создания
        view?.displayTasks(currentTasks) // Передаем отсортированные задачи во View
        view?.hideLoadingIndicator()
    }

    func didFailToLoadTasks(with error: Error) {
        view?.hideLoadingIndicator()
        view?.showErrorMessage("Failed to load tasks: \(error.localizedDescription)") // Показываем ошибку
    }

    func didAddTask(_ task: Task) {
        // При добавлении новой задачи, перезагрузим список для обновления View
        interactor.loadTasks() // Или более оптимизированно: добавить задачу в currentTasks и обновить View
    }

    func didFailToAddTask(with error: Error) {
         view?.showErrorMessage("Failed to add task: \(error.localizedDescription)")
    }

    func taskDidUpdate(_ task: Task) {
        // При обновлении задачи, найдем ее в currentTasks и обновим, затем обновим View
        if let index = currentTasks.firstIndex(where: { $0.objectID == task.objectID }) {
            currentTasks[index] = task // Обновляем объект в локальном массиве
             view?.displayTasks(currentTasks.sorted(by: { $0.creationDate ?? Date() > $1.creationDate ?? Date() })) // Обновляем View, сохраняя сортировку
        } else {
            // Если обновленной задачи нет в текущем списке (например, после поиска), можно перезагрузить список
             interactor.loadTasks()
        }
    }

    func taskDidDelete(_ task: Task) {
        // При удалении задачи, найдем ее в currentTasks и удалим, затем обновим View
         if let index = currentTasks.firstIndex(where: { $0.objectID == task.objectID }) {
             currentTasks.remove(at: index)
             view?.displayTasks(currentTasks.sorted(by: { $0.creationDate ?? Date() > $1.creationDate ?? Date() })) // Обновляем View, сохраняя сортировку
         }
    }

    // TODO: Implement methods for handling search results, etc.
}
