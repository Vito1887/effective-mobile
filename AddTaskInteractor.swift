import Foundation
import CoreData

// Импортируем протоколы, определенные в AddTaskProtocols.swift
// MARK: - Protocols are defined in AddTaskProtocols.swift

// MARK: - Interactor Class
class AddTaskInteractor: AddTaskInteractorInput {

    weak var presenter: AddTaskInteractorOutput?
    // Удаляем любые строки, где пытаемся использовать .shared или где свойство без инициализатора
    // private let coreDataManager = CoreDataManager.shared // Эту или похожую строку нужно удалить
    // private let coreDataManager: CoreDataManager // Эту строку нужно заменить на строку ниже

    // Объявляем свойство, которое будет инициализировано через init
    private let coreDataManager: CoreDataManager

    // MARK: - Initialization
    // Убеждаемся, что инициализатор принимает CoreDataManager
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager // Инициализируем свойство переданным менеджером
    }

    // MARK: - AddTaskInteractorInput Methods

    func saveNewTask(title: String, details: String?) {
        // Выполняем сохранение в CoreData в фоновом потоке
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            // Создаем новый контекст для фоновых операций, используя переданный coreDataManager
            let context = self.coreDataManager.newBackgroundContext()

            context.perform {
                // Генерация уникального ID: простой вариант на основе метки времени
                let newTaskId = Int(Date().timeIntervalSince1970)

                guard let taskEntity = NSEntityDescription.entity(forEntityName: "Task", in: context) else {
                    print("Error: Could not find Task entity description in background context.")
                    // Обрабатываем ошибку на главном потоке
                    DispatchQueue.main.async {
                        self.presenter?.didFailToSaveTask(with: NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not create task entity."]))
                    }
                    return
                }

                let newTask = Task(entity: taskEntity, insertInto: context)
                newTask.id = Int64(newTaskId)
                newTask.title = title
                newTask.details = details
                newTask.creationDate = Date() // Присваиваем Date напрямую
                newTask.isCompleted = false

                // Сохраняем изменения
                if context.hasChanges {
                    do {
                        try context.save()
                        // Оповещаем Presenter на главном потоке об успехе
                        DispatchQueue.main.async {
                            self.presenter?.didSaveTaskSuccessfully()
                        }
                    } catch {
                        let nserror = error as NSError
                        print("Unresolved error saving new task in background \(nserror), \(nserror.userInfo)")
                        // Оповещаем Presenter на главном потоке об ошибке
                        DispatchQueue.main.async {
                            self.presenter?.didFailToSaveTask(with: nserror)
                        }
                    }
                } else {
                     // Оповещаем Presenter об успехе, даже если изменений не было (например, пустые поля)
                     DispatchQueue.main.async {
                         self.presenter?.didSaveTaskSuccessfully()
                     }
                }
            }
        }
    }
}
