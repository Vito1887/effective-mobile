import Foundation
import CoreData
import UIKit // Добавьте UIKit для доступа к AppDelegate (если еще не добавлен)

// Импортируем протоколы из ToDoProtocols.swift
// MARK: - Protocols are defined in ToDoProtocols.swift

// MARK: - Interactor Class
class ToDoInteractor: ToDoInteractorInput {

    weak var presenter: ToDoInteractorOutput?
    // Удаляем строку, где пытаемся использовать .shared или где свойство без инициализатора
    // private let coreDataManager = CoreDataManager.shared // Эта строка должна быть удалена
    // private let coreDataManager: CoreDataManager // Эта строка должна быть заменена на строку ниже

    // Объявляем свойство, которое будет инициализировано через init
    private let coreDataManager: CoreDataManager
    private let apiService: ToDoAPIServiceProtocol

    // MARK: - Initialization
    // Убеждаемся, что инициализатор принимает CoreDataManager и apiService
    init(apiService: ToDoAPIServiceProtocol = NetworkService(), coreDataManager: CoreDataManager) {
        self.apiService = apiService
        self.coreDataManager = coreDataManager // Инициализируем свойство переданным менеджером
    }

    // MARK: - ToDoInteractorInput Methods

    func loadTasks() {
        // Выполняем загрузку данных в фоновом потоке
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            // 1. Проверяем CoreData на наличие задач
            let existingTasks = self.coreDataManager.fetchTasks()

            if !existingTasks.isEmpty {
                // 2. Если задачи есть, возвращаем их Presenter'у на главном потоке
                DispatchQueue.main.async {
                    self.presenter?.didLoadTasks(existingTasks)
                }
            } else {
                // 3. Если задач нет, загружаем из API
                self.apiService.fetchTodos { result in
                    switch result {
                    case .success(let todoItems):
                        // Сохраняем загруженные задачи в CoreData
                        self.saveApiTasksToCoreData(todoItems)

                        // После сохранения, снова загружаем задачи из CoreData (уже сохраненные)
                        let savedTasks = self.coreDataManager.fetchTasks()

                        // Возвращаем сохраненные задачи Presenter'у на главном потоке
                        DispatchQueue.main.async {
                            self.presenter?.didLoadTasks(savedTasks)
                        }

                    case .failure(let error):
                        // Обрабатываем ошибку загрузки из API
                        DispatchQueue.main.async {
                            self.presenter?.didFailToLoadTasks(with: error)
                        }
                    }
                }
            }
        }
    }

    func addNewTask(title: String, details: String?) {
        // TODO: Implement logic to add a new task
        // Выполняем сохранение в CoreData в фоновом потоке
         DispatchQueue.global(qos: .background).async { [weak self] in
             guard let self = self else { return }

             // Создаем новый контекст для фоновых операций, используя переданный coreDataManager
             let context = self.coreDataManager.newBackgroundContext()

             context.perform {
                 let newTaskId = Int(Date().timeIntervalSince1970) // Простой уникальный ID

                  guard let taskEntity = NSEntityDescription.entity(forEntityName: "Task", in: context) else {
                      print("Error: Could not find Task entity description in background context.")
                       DispatchQueue.main.async {
                           // self.presenter?.didFailToAddtask(with: someError) // Implement error handling
                       }
                      return
                  }


                 let newTask = Task(entity: taskEntity, insertInto: context)
                 newTask.id = Int64(newTaskId)
                 newTask.title = title
                 newTask.details = details
                 newTask.creationDate = Date() // Присваиваем Date напрямую
                 newTask.isCompleted = false

                 if context.hasChanges {
                     do {
                         try context.save()
                          // Оповещаем Presenter на главном потоке об успехе
                         DispatchQueue.main.async {
                             self.presenter?.didAddTask(newTask) // Передаем созданную задачу
                         }
                     } catch {
                         let nserror = error as NSError
                         print("Unresolved error saving new task in background \(nserror), \(nserror.userInfo)")
                         DispatchQueue.main.async {
                              // self.presenter?.didFailToAddtask(with: nserror) // Implement error handling
                         }
                     }
                 } else {
                      DispatchQueue.main.async {
                          self.presenter?.didAddTask(newTask) // Передаем созданную задачу, даже если изменений не было
                      }
                 }
             }
         }
     }

     func updateTaskStatus(task: Task, isCompleted: Bool) {
          // Выполняем обновление в CoreData в фоновом потоке
          DispatchQueue.global(qos: .background).async { [weak self] in
              guard let self = self else { return }
              // Используем mainContext для обновления объекта, полученного из mainContext
               self.coreDataManager.updateTask(task: task, title: task.title ?? "", details: task.details, isCompleted: isCompleted)
              // Optionally notify presenter on main thread after saving
              DispatchQueue.main.async {
                   self.presenter?.taskDidUpdate(task) // Уведомляем презентер
               }
          }
     }

      func updateTaskDetails(task: Task, title: String, details: String?) {
           // Выполняем обновление в CoreData в фоновом потоке
            DispatchQueue.global(qos: .background).async { [weak self] in
               guard let self = self else { return }
               // Используем mainContext для обновления объекта, полученного из mainContext
                self.coreDataManager.updateTask(task: task, title: title, details: details, isCompleted: task.isCompleted)
               // Optionally notify presenter on main thread after saving
                DispatchQueue.main.async {
                    self.presenter?.taskDidUpdate(task) // Уведомляем презентер
                }
           }
      }

     func deleteTask(task: Task) {
          // Выполняем удаление в CoreData в фоновом потоке
          DispatchQueue.global(qos: .background).async { [weak self] in
              guard let self = self else { return }
               // Используем mainContext для удаления объекта, полученного из mainContext
               self.coreDataManager.deleteTask(task: task)
               // Optionally notify presenter on main thread after saving
               DispatchQueue.main.async {
                   self.presenter?.taskDidDelete(task) // Уведомляем презентер
               }
          }
     }


    func searchTasks(with query: String) {
         // Выполняем поиск в CoreData в фоновом потоке
         DispatchQueue.global(qos: .userInitiated).async { [weak self] in
             guard let self = self else { return }
              let context = self.coreDataManager.mainContext // Поиск обычно выполняется на mainContext для обновления UI

              let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
              if !query.isEmpty {
                   // Используем CONTAINS[cd] для регистронезависимого поиска без учета диакритики
                  fetchRequest.predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR details CONTAINS[cd] %@", query, query)
              }

              do {
                  let searchResults = try context.fetch(fetchRequest)
                   DispatchQueue.main.async {
                       self.presenter?.didLoadTasks(searchResults) // Отправляем результаты на главный поток
                   }
              } catch {
                  print("Error searching tasks: \(error)")
                  DispatchQueue.main.async {
                      self.presenter?.didFailToLoadTasks(with: error) // Отправляем ошибку на главный поток
                  }
              }
         }
     }


    // MARK: - Private Helper Methods

    private func saveApiTasksToCoreData(_ todoItems: [TodoItem]) {
        let context = coreDataManager.newBackgroundContext() // Используем фоновый контекст для сохранения
         context.perform { // Выполняем операции в контексте на его собственном потоке
            for item in todoItems {
                 // Проверяем, существует ли уже задача с таким ID, чтобы избежать дубликатов
                 let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
                 fetchRequest.predicate = NSPredicate(format: "id == %d", item.id)

                 do {
                     let existingTasks = try context.fetch(fetchRequest)
                     if existingTasks.first == nil {
                         // Если задачи нет, создаем новую
                         let taskEntity = NSEntityDescription.entity(forEntityName: "Task", in: context)!
                         let task = Task(entity: taskEntity, insertInto: context)
                         task.id = Int64(item.id)
                         task.title = item.todo
                         task.details = nil // Description is not in the current API response
                         task.creationDate = Date() // Use current date as creation date is not in API
                         task.isCompleted = item.completed
                     }
                 } catch {
                     print("Error checking for existing task: \(error)")
                 }
             }

             // Сохраняем изменения в фоновом контексте
             if context.hasChanges {
                 do {
                     try context.save()
                      print("Successfully saved tasks from API to CoreData.")
                 } catch {
                     let nserror = error as NSError
                     print("Unresolved error saving background context \(nserror), \(nserror.userInfo)")
                 }
             }
         }
    }
}
