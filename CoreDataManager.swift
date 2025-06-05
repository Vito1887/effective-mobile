import CoreData
import Foundation
// import UIKit // Этот импорт больше не нужен для доступа к AppDelegate

class CoreDataManager {

    // static let shared = CoreDataManager() // Больше не Singleton, если получаем контейнер извне

    private let persistentContainer: NSPersistentContainer // Теперь это константа, установленная при инициализации

    // MARK: - Initialization
    init(container: NSPersistentContainer) { // Принимаем контейнер при инициализации
        self.persistentContainer = container
    }

    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext() {
        if mainContext.hasChanges {
            do {
                try mainContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // MARK: - Task Operations (остаются без изменений, используют mainContext)
    // ... createTask, fetchTasks, fetchTask, updateTask, deleteTask ...
     func createTask(id: Int, title: String, details: String?, creationDate: Date, isCompleted: Bool) -> Task? {
         let context = mainContext
         guard let taskEntity = NSEntityDescription.entity(forEntityName: "Task", in: context) else {
             print("Error: Could not find Task entity description.")
             return nil
         }

         let task = Task(entity: taskEntity, insertInto: context)
         task.id = Int64(id) // Core Data Integer 64 is Int64
         task.title = title
         task.details = details
         // task.creationDate = creationDate as NSDate // Убрали 'as NSDate'
         task.creationDate = creationDate
         task.isCompleted = isCompleted

         saveContext()
         return task
     }

     func fetchTasks() -> [Task] {
         let context = mainContext
         let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()

         do {
             let tasks = try context.fetch(fetchRequest)
             return tasks
         } catch {
             print("Error fetching tasks: \(error)")
             return []
         }
     }

     func fetchTask(byId id: Int) -> Task? {
         let context = mainContext
         let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
         fetchRequest.predicate = NSPredicate(format: "id == %d", id)

         do {
             let tasks = try context.fetch(fetchRequest)
             return tasks.first
         } catch {
             print("Error fetching task by ID: \(error)")
             return nil
         }
     }

     func updateTask(task: Task, title: String, details: String?, isCompleted: Bool) {
         task.title = title
         task.details = details
         task.isCompleted = isCompleted
         saveContext()
     }

     func deleteTask(task: Task) {
         mainContext.delete(task)
         saveContext()
     }

     // Метод для создания фонового контекста, теперь в CoreDataManager
     func newBackgroundContext() -> NSManagedObjectContext {
         return persistentContainer.newBackgroundContext()
     }

    // Add other necessary CoreData methods (e.g., for search) as needed
}
