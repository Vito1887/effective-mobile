import Foundation
import CoreData

class AddTaskInteractor: AddTaskInteractorInput {

    weak var presenter: AddTaskInteractorOutput?

    private let coreDataManager: CoreDataManager

    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }

    func saveTask(title: String, details: String?, taskToEdit: Task?) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            let context = self.coreDataManager.newBackgroundContext()

            context.perform {
                let task: Task
                if let existingTask = taskToEdit {
                    guard let existingTaskInContext = context.object(with: existingTask.objectID) as? Task else {
                         print("Error: Could not find existing task in background context.")
                         DispatchQueue.main.async {
                             self.presenter?.didFailToSaveTask(with: NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not find task for editing."]))
                         }
                         return
                     }
                     task = existingTaskInContext
                     task.title = title
                     task.details = details
                } else {
                    let newTaskId = Int(Date().timeIntervalSince1970)
                    guard let taskEntity = NSEntityDescription.entity(forEntityName: "Task", in: context) else {
                         print("Error: Could not find Task entity description in background context.")
                         DispatchQueue.main.async {
                             self.presenter?.didFailToSaveTask(with: NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not create task entity."]))
                         }
                         return
                     }
                    let newTask = Task(entity: taskEntity, insertInto: context)
                    newTask.id = Int64(newTaskId)
                    newTask.title = title
                    newTask.details = details
                    newTask.creationDate = Date()
                    newTask.isCompleted = false
                    task = newTask
                }

                if context.hasChanges {
                    do {
                        try context.save()
                        DispatchQueue.main.async {
                            self.presenter?.didSaveTaskSuccessfully()
                        }
                    } catch {
                        let nserror = error as NSError
                        print("Unresolved error saving task in background \(nserror), \(nserror.userInfo)")

                        DispatchQueue.main.async {
                            self.presenter?.didFailToSaveTask(with: nserror)
                        }
                    }
                } else {
                     DispatchQueue.main.async {
                         self.presenter?.didSaveTaskSuccessfully()
                     }
                }
            }
        }
    }
}
