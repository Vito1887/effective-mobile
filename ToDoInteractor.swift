import Foundation
import CoreData
import UIKit

class ToDoInteractor: ToDoInteractorInput {

    weak var presenter: ToDoInteractorOutput?

    private let coreDataManager: CoreDataManager
    private let apiService: ToDoAPIServiceProtocol

    init(apiService: ToDoAPIServiceProtocol = NetworkService(), coreDataManager: CoreDataManager) {
        self.apiService = apiService
        self.coreDataManager = coreDataManager
    }

    func loadTasks() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            let existingTasks = self.coreDataManager.fetchTasks()

            if !existingTasks.isEmpty {
                DispatchQueue.main.async {
                    self.presenter?.didLoadTasks(existingTasks)
                }
            } else {
                self.apiService.fetchTodos { result in
                    switch result {
                    case .success(let todoItems):
                        self.saveApiTasksToCoreData(todoItems)

                        let savedTasks = self.coreDataManager.fetchTasks()

                        DispatchQueue.main.async {
                            self.presenter?.didLoadTasks(savedTasks)
                        }

                    case .failure(let error):
                        DispatchQueue.main.async {
                            self.presenter?.didFailToLoadTasks(with: error)
                        }
                    }
                }
            }
        }
    }

    func addNewTask(title: String, details: String?) {
         DispatchQueue.global(qos: .background).async { [weak self] in
             guard let self = self else { return }

             let context = self.coreDataManager.newBackgroundContext()

             context.perform {
                 let newTaskId = Int(Date().timeIntervalSince1970)

                  guard let taskEntity = NSEntityDescription.entity(forEntityName: "Task", in: context) else {
                      print("Error: Could not find Task entity description in background context.")
                       DispatchQueue.main.async {
                       }
                      return
                  }


                 let newTask = Task(entity: taskEntity, insertInto: context)
                 newTask.id = Int64(newTaskId)
                 newTask.title = title
                 newTask.details = details
                 newTask.creationDate = Date()
                 newTask.isCompleted = false

                 if context.hasChanges {
                     do {
                         try context.save()

                         DispatchQueue.main.async {
                             self.presenter?.didAddTask(newTask)
                         }
                     } catch {
                         let nserror = error as NSError
                         print("Unresolved error saving new task in background \(nserror), \(nserror.userInfo)")
                         DispatchQueue.main.async {
                         }
                     }
                 } else {
                      DispatchQueue.main.async {
                          self.presenter?.didAddTask(newTask)
                      }
                 }
             }
         }
     }

     func updateTaskStatus(task: Task, isCompleted: Bool) {
          DispatchQueue.global(qos: .background).async { [weak self] in
              guard let self = self else { return }
               self.coreDataManager.updateTask(task: task, title: task.title ?? "", details: task.details, isCompleted: isCompleted)

              DispatchQueue.main.async {
                   self.presenter?.taskDidUpdate(task)
               }
          }
     }

      func updateTaskDetails(task: Task, title: String, details: String?) {
            DispatchQueue.global(qos: .background).async { [weak self] in
               guard let self = self else { return }

                self.coreDataManager.updateTask(task: task, title: title, details: details, isCompleted: task.isCompleted)

                DispatchQueue.main.async {
                    self.presenter?.taskDidUpdate(task)
                }
           }
      }

     func deleteTask(task: Task) {
          DispatchQueue.global(qos: .background).async { [weak self] in
              guard let self = self else { return }

               self.coreDataManager.deleteTask(task: task)

               DispatchQueue.main.async {
                   self.presenter?.taskDidDelete(task)
               }
          }
     }


    func searchTasks(with query: String) {
         DispatchQueue.global(qos: .userInitiated).async { [weak self] in
             guard let self = self else { return }
             let context = self.coreDataManager.newBackgroundContext()

             context.perform { [weak self] in
                 guard let self = self else { return }
                 let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
                 if !query.isEmpty {
                     fetchRequest.predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR details CONTAINS[cd] %@", query, query)
                 }

                 do {
                     let searchResults = try context.fetch(fetchRequest)
                     DispatchQueue.main.async {
                         self.presenter?.didLoadTasks(searchResults)
                     }
                 } catch {
                     print("Error searching tasks: \(error)")
                     DispatchQueue.main.async {
                         self.presenter?.didFailToLoadTasks(with: error)
                     }
                 }
             }
         }
     }

    private func saveApiTasksToCoreData(_ todoItems: [TodoItem]) {
        let context = coreDataManager.newBackgroundContext()
         context.perform {
            for item in todoItems {
                 let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()

                 fetchRequest.predicate = NSPredicate(format: "id == %d", item.id)

                 do {
                     let existingTasks = try context.fetch(fetchRequest)
                     if existingTasks.first == nil {
                         let taskEntity = NSEntityDescription.entity(forEntityName: "Task", in: context)!
                         let task = Task(entity: taskEntity, insertInto: context)
                         task.id = Int64(item.id)
                         task.title = item.todo
                         task.details = nil
                         task.creationDate = Date()
                         task.isCompleted = item.completed
                     }
                 } catch {
                     print("Error checking for existing task: \(error)")
                 }
             }

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
