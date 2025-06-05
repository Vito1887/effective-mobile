//
//  effective_mobileTests.swift
//  effective-mobileTests
//
//  Created by Alex  Alex  on 04.06.2025.
//

import Testing
import effective_mobile // Импортируем основной модуль для доступа к классам
import CoreData // Для Task Entity

// MARK: - Mock Implementations

// Используем класс, наследующий от NSManagedObject, чтобы имитировать Task из CoreData
// Для полноценного in-memory тестирования CoreData потребуется больше настроек.
// В рамках простого мока ограничимся базовыми свойствами.
class MockTask: Task {
    // Переопределяем необходимые свойства и методы NSManagedObject, если они используются в Interactor
    // Для простоты инициализатор по умолчанию может быть достаточен, если Interactor только читает свойства.
    // Если Interactor выполняет операции с контекстом (сохранение, удаление), этот мок будет недостаточен.
    // fatalError("MockTask requires in-memory CoreData for full testing")
}

class MockToDoAPIService: ToDoAPIServiceProtocol {
    var fetchTodosResult: Result<[TodoItem], Error> = .success([])
    var fetchTodosCalled = false

    func fetchTodos(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        fetchTodosCalled = true
        completion(fetchTodosResult)
    }
}

class MockCoreDataManager: CoreDataManager {
    // Переопределяем init, чтобы избежать работы с реальным NSPersistentContainer
    // Для тестов CoreData нужна своя настройка NSPersistentContainer (in-memory)
     init() {
         // Создаем in-memory Core Data stack для тестов
         guard let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main]) else {
              fatalError("Could not find model")
         }

         let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)

         do {
             try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
         } catch {
              fatalError("Adding in-memory store failed \(error)")
         }

         let container = NSPersistentContainer(name: "effective_mobile", managedObjectModel: managedObjectModel)
         container.persistentStoreCoordinator = persistentStoreCoordinator

         // Устанавливаем основной контекст для мока
         super.init(container: container)

         // Настраиваем контексты на автоматическое слияние изменений
         mainContext.automaticallyMergesChangesFromParent = true
         mainContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
     }

    var savedTasks: [Task] = []
    var fetchTasksCalled = false
    var createTaskCalled = false
    var updateTaskCalled = false
    var deleteTaskCalled = false
    var searchTasksCalled = false

    // Флаги для симуляции ошибок
    var shouldSimulateSaveError = false
    var shouldSimulateUpdateError = false
    var shouldSimulateDeleteError = false
    var shouldSimulateSearchError = false
    var shouldSimulateFetchError = false

    override func fetchTasks() -> [Task] {
        if shouldSimulateFetchError {
            throw NSError(domain: "com.test", code: 5, userInfo: [NSLocalizedDescriptionKey: "Ошибка получения данных"])
        }
        fetchTasksCalled = true
         // В in-memory контексте получаем реальные Task объекты
         let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
         do {
             return try mainContext.fetch(fetchRequest)
         } catch {
             print("Error fetching tasks in mock: \(error)")
             return []
         }
    }

    override func createTask(id: Int, title: String, details: String?, creationDate: Date, isCompleted: Bool) -> Task? {
         createTaskCalled = true
          // В in-memory контексте создаем реальный NSManagedObject
         let context = newBackgroundContext()
         let task = Task(context: context)
         task.id = Int64(id)
         task.title = title
         task.details = details
         task.creationDate = creationDate
         task.isCompleted = isCompleted

         do {
             try context.save()
              // После сохранения в фоновом контексте, изменения должны быть доступны в mainContext благодаря automatic merge
         } catch {
             print("Error creating task in mock: \(error)")
             return nil
         }

         // Возвращаем объект из mainContext, чтобы соответствовать поведению ToDoInteractor
         // В реальных тестах, возможно, потребуется получить объект по ID из mainContext после сохранения
         return fetchTask(byId: id) // Получаем объект из mainContext
    }

     override func updateTask(task: Task, title: String, details: String?, isCompleted: Bool) {
         if shouldSimulateUpdateError {
             throw NSError(domain: "com.test", code: 2, userInfo: [NSLocalizedDescriptionKey: "Ошибка обновления"])
         }
         updateTaskCalled = true
          // В in-memory контексте обновляем объект
          // Для обновления нужно получить объект в текущем контексте (mainContext или background)
          // В данном случае, если task передан из mainContext, можно обновлять напрямую
          // Если из другого контекста, нужно получить его objectID и получить объект в текущем контексте
          // Для простоты мока предположим, что task находится в контексте, используемом для обновления
          task.title = title
          task.details = details
          task.isCompleted = isCompleted
          saveContext() // Сохраняем изменения в mainContext (если task оттуда) или в соответствующем контексте
     }

     override func deleteTask(task: Task) {
         if shouldSimulateDeleteError {
             throw NSError(domain: "com.test", code: 3, userInfo: [NSLocalizedDescriptionKey: "Ошибка удаления"])
         }
         deleteTaskCalled = true
          // В in-memory контексте удаляем объект
          // Аналогично updateTask, нужно получить объект в текущем контексте
         mainContext.delete(task)
         saveContext()
     }

      override func searchTasks(with query: String) -> [Task] {
          if shouldSimulateSearchError {
              throw NSError(domain: "com.test", code: 4, userInfo: [NSLocalizedDescriptionKey: "Ошибка поиска"])
          }
          searchTasksCalled = true
           let context = newBackgroundContext()

           let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
           if !query.isEmpty {
               fetchRequest.predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR details CONTAINS[cd] %@", query, query)
           }

           do {
               let searchResults = try context.fetch(fetchRequest)
                return searchResults
           } catch {
               print("Error searching tasks in mock: \(error)")
               return []
           }
      }

     override func newBackgroundContext() -> NSManagedObjectContext {
          // Возвращаем новый фоновый контекст из in-memory контейнера
          return persistentContainer.newBackgroundContext()
     }

     // Дополнительный метод для создания тестовых Task объектов в in-memory контексте
     func createTestTask(id: Int, title: String, details: String? = nil, isCompleted: Bool = false, creationDate: Date = Date()) -> Task {
         let context = mainContext
         let task = Task(context: context)
         task.id = Int64(id)
         task.title = title
         task.details = details
         task.creationDate = creationDate
         task.isCompleted = isCompleted
          // Не сохраняем сразу, чтобы тесты могли контролировать saveContext
         return task
     }

    override func saveContext() {
        if shouldSimulateSaveError {
            throw NSError(domain: "com.test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Ошибка сохранения"])
        }
        super.saveContext()
    }
}

class MockToDoInteractorOutput: ToDoInteractorOutput {
    var didLoadTasksCalled = false
    var didLoadTasksTasks: [Task]?
    var didFailToLoadTasksCalled = false
    var didFailToLoadTasksError: Error?
    var didAddTaskCalled = false
    var didAddTaskTask: Task?
    var didFailToAddTaskCalled = false
    var didFailToAddTaskError: Error?
    var taskDidUpdateCalled = false
    var taskDidUpdateTask: Task?
    var taskDidDeleteCalled = false
    var taskDidDeleteTask: Task?

    func didLoadTasks(_ tasks: [Task]) {
        didLoadTasksCalled = true
        didLoadTasksTasks = tasks
    }

    func didFailToLoadTasks(with error: Error) {
        didFailToLoadTasksCalled = true
        didFailToLoadTasksError = error
    }

    func didAddTask(_ task: Task) {
        didAddTaskCalled = true
        didAddTaskTask = task
    }

    func didFailToAddTask(with error: Error) {
        didFailToAddTaskCalled = true
        didFailToAddTaskError = error
    }

    func taskDidUpdate(_ task: Task) {
        taskDidUpdateCalled = true
        taskDidUpdateTask = task
    }

    func taskDidDelete(_ task: Task) {
        taskDidDeleteCalled = true
        taskDidDeleteTask = task
    }
}

// MARK: - Mock AddTaskInteractorOutput

class MockAddTaskInteractorOutput: AddTaskInteractorOutput {
    var didSaveTaskSuccessfullyCalled = false
    var didFailToSaveTaskCalled = false
    var didFailToSaveTaskError: Error?

    func didSaveTaskSuccessfully() {
        didSaveTaskSuccessfullyCalled = true
    }

    func didFailToSaveTask(with error: Error) {
        didFailToSaveTaskCalled = true
        didFailToSaveTaskError = error
    }
}

// MARK: - ToDoInteractor Tests

struct ToDoInteractorTests {

    @Test func testLoadTasks_WhenCoreDataHasData() async throws {
        let mockApiService = MockToDoAPIService()
        let mockCoreDataManager = MockCoreDataManager()
        let mockPresenter = MockToDoInteractorOutput()

        // Создаем тестовые данные в in-memory CoreData
        let task1 = mockCoreDataManager.createTestTask(id: 1, title: "Test Task 1", creationDate: Date().addingTimeInterval(-100))
        let task2 = mockCoreDataManager.createTestTask(id: 2, title: "Test Task 2", creationDate: Date().addingTimeInterval(-200))
        mockCoreDataManager.saveContext() // Сохраняем тестовые данные

        let interactor = ToDoInteractor(apiService: mockApiService, coreDataManager: mockCoreDataManager)
        interactor.presenter = mockPresenter

        interactor.loadTasks()

        // Даем время асинхронным операциям выполниться
        try await Task.sleep(nanoseconds: 100_000_000) // Пример ожидания

        // Проверяем, что CoreData была вызвана, а API - нет
        #expect(mockCoreDataManager.fetchTasksCalled == true)
        #expect(mockApiService.fetchTodosCalled == false)

        // Проверяем, что презентер получил задачи
        #expect(mockPresenter.didLoadTasksCalled == true)
        #expect(mockPresenter.didLoadTasksTasks?.count == 2)
        // Проверяем сортировку (от новых к старым)
        #expect(mockPresenter.didLoadTasksTasks?.first?.id == 1)
        #expect(mockPresenter.didLoadTasksTasks?.last?.id == 2)
        #expect(mockPresenter.didFailToLoadTasksCalled == false)
    }

    @Test func testLoadTasks_WhenCoreDataIsEmptyAndApiSucceeds() async throws {
        let mockApiService = MockToDoAPIService()
        let mockCoreDataManager = MockCoreDataManager()
        let mockPresenter = MockToDoInteractorOutput()

        // Настраиваем мок API для возврата данных
        let apiTodoItem1 = TodoItem(id: 101, todo: "API Task 1", completed: false, userId: 1)
        let apiTodoItem2 = TodoItem(id: 102, todo: "API Task 2", completed: true, userId: 2)
        mockApiService.fetchTodosResult = .success([apiTodoItem1, apiTodoItem2])

        let interactor = ToDoInteractor(apiService: mockApiService, coreDataManager: mockCoreDataManager)
        interactor.presenter = mockPresenter

        interactor.loadTasks()

         // Даем время асинхронным операциям выполниться
        try await Task.sleep(nanoseconds: 1_000_000_000) // Ожидание выполнения сетевого запроса и сохранения

        // Проверяем, что CoreData была вызвана (для начальной проверки), API был вызван, и CoreData сохраняла данные
        #expect(mockCoreDataManager.fetchTasksCalled == true) // Первая проверка на пустые данные
        #expect(mockApiService.fetchTodosCalled == true)
        // Проверка createTaskCalled или saveContext Called в CoreDataManager, если mock CoreDataManager будет более детальным

        // После сохранения из API, Interactor снова фетчит из CoreData и передает презентеру
         #expect(mockCoreDataManager.fetchTasksCalled == true)

        // Проверяем, что презентер получил задачи (после сохранения из API)
        #expect(mockPresenter.didLoadTasksCalled == true)
        #expect(mockPresenter.didLoadTasksTasks?.count == 2)
        // Проверяем, что задачи из API были сохранены (по их ID)
        #expect(mockCoreDataManager.fetchTask(byId: 101) != nil)
        #expect(mockCoreDataManager.fetchTask(byId: 102) != nil)

        #expect(mockPresenter.didFailToLoadTasksCalled == false)
    }

     @Test func testLoadTasks_WhenCoreDataIsEmptyAndApiFails() async throws {
         let mockApiService = MockToDoAPIService()
         let mockCoreDataManager = MockCoreDataManager()
         let mockPresenter = MockToDoInteractorOutput()

         // Настраиваем мок API для возврата ошибки
         let apiError = NSError(domain: "com.test", code: 1, userInfo: [NSLocalizedDescriptionKey: "API Failed"])
         mockApiService.fetchTodosResult = .failure(apiError)

         let interactor = ToDoInteractor(apiService: mockApiService, coreDataManager: mockCoreDataManager)
         interactor.presenter = mockPresenter

         interactor.loadTasks()

         // Даем время асинхронным операциям выполниться
         try await Task.sleep(nanoseconds: 1_000_000_000) // Ожидание выполнения сетевого запроса

          // Проверяем, что CoreData была вызвана (для начальной проверки) и API был вызван
         #expect(mockCoreDataManager.fetchTasksCalled == true)
         #expect(mockApiService.fetchTodosCalled == true)

         // Проверяем, что презентер получил ошибку
         #expect(mockPresenter.didLoadTasksCalled == false)
         #expect(mockPresenter.didFailToLoadTasksCalled == true)
         #expect((mockPresenter.didFailToLoadTasksError as? NSError)?.domain == apiError.domain)
         #expect((mockPresenter.didFailToLoadTasksError as? NSError)?.code == apiError.code)
     }

    @Test func testAddNewTask() async throws {
        let mockApiService = MockToDoAPIService()
        let mockCoreDataManager = MockCoreDataManager()
        let mockPresenter = MockToDoInteractorOutput()
        let interactor = ToDoInteractor(apiService: mockApiService, coreDataManager: mockCoreDataManager)
        interactor.presenter = mockPresenter

        let title = "Тестовая новая задача"
        let details = "Некоторые детали"

        interactor.addNewTask(title: title, details: details)

        // Даем время асинхронной операции Core Data выполниться
        try await Task.sleep(nanoseconds: 500_000_000) // Ожидание сохранения

        // Проверяем, что презентер получил сигнал о добавлении задачи
        #expect(mockPresenter.didAddTaskCalled == true)
        #expect(mockPresenter.didAddTaskTask?.title == title)
        #expect(mockPresenter.didAddTaskTask?.details == details)
        #expect(mockPresenter.didAddTaskTask?.isCompleted == false)
        #expect(mockPresenter.didFailToAddTaskCalled == false)

        // Проверяем, что задача действительно сохранилась в Core Data
        let savedTasks = mockCoreDataManager.fetchTasks()
        #expect(savedTasks.count == 1)
        let savedTask = savedTasks.first!
        #expect(savedTask.title == title)
        #expect(savedTask.details == details)
        #expect(savedTask.isCompleted == false)
    }

    @Test func testUpdateTaskStatus() async throws {
        let mockApiService = MockToDoAPIService()
        let mockCoreDataManager = MockCoreDataManager()
        let mockPresenter = MockToDoInteractorOutput()
        let interactor = ToDoInteractor(apiService: mockApiService, coreDataManager: mockCoreDataManager)
        interactor.presenter = mockPresenter

        // Создаем и сохраняем тестовую задачу для обновления
        let initialTask = mockCoreDataManager.createTestTask(id: 1, title: "Задача для обновления", isCompleted: false)
        mockCoreDataManager.saveContext()

        // Получаем задачу, чтобы передать ее в Interactor (имитация получения из UI)
        guard let taskToUpdate = mockCoreDataManager.fetchTasks().first else {
            fatalError("Failed to create test task for update")
        }

        // Вызываем метод обновления статуса
        interactor.updateTaskStatus(task: taskToUpdate, isCompleted: true)

        // Даем время асинхронной операции Core Data выполниться
        try await Task.sleep(nanoseconds: 500_000_000) // Ожидание сохранения

        // Проверяем, что презентер получил сигнал об обновлении задачи
        #expect(mockPresenter.taskDidUpdateCalled == true)
        #expect(mockPresenter.taskDidUpdateTask?.id == taskToUpdate.id)
        #expect(mockPresenter.taskDidUpdateTask?.isCompleted == true)

        // Проверяем, что статус задачи действительно обновился в Core Data
        let updatedTasks = mockCoreDataManager.fetchTasks()
        #expect(updatedTasks.count == 1)
        #expect(updatedTasks.first?.isCompleted == true)
    }

    @Test func testDeleteTask() async throws {
        let mockApiService = MockToDoAPIService()
        let mockCoreDataManager = MockCoreDataManager()
        let mockPresenter = MockToDoInteractorOutput()
        let interactor = ToDoInteractor(apiService: mockApiService, coreDataManager: mockCoreDataManager)
        interactor.presenter = mockPresenter

        // Создаем и сохраняем тестовую задачу для удаления
        let taskToDelete = mockCoreDataManager.createTestTask(id: 1, title: "Задача для удаления")
        mockCoreDataManager.saveContext()

        // Убеждаемся, что задача существует
        #expect(mockCoreDataManager.fetchTasks().count == 1)

        // Вызываем метод удаления
        interactor.deleteTask(task: taskToDelete)

        // Даем время асинхронной операции Core Data выполниться
        try await Task.sleep(nanoseconds: 500_000_000) // Ожидание удаления

        // Проверяем, что презентер получил сигнал об удалении задачи
        #expect(mockPresenter.taskDidDeleteCalled == true)
        #expect(mockPresenter.taskDidDeleteTask?.id == taskToDelete.id)

        // Проверяем, что задача действительно удалена из Core Data
        let remainingTasks = mockCoreDataManager.fetchTasks()
        #expect(remainingTasks.isEmpty)
    }

    @Test func testSearchTasks_WithQuery() async throws {
        let mockApiService = MockToDoAPIService()
        let mockCoreDataManager = MockCoreDataManager()
        let mockPresenter = MockToDoInteractorOutput()
        let interactor = ToDoInteractor(apiService: mockApiService, coreDataManager: mockCoreDataManager)
        interactor.presenter = mockPresenter

        // Создаем тестовые данные для поиска
        mockCoreDataManager.createTestTask(id: 1, title: "Apple Pie")
        mockCoreDataManager.createTestTask(id: 2, title: "Banana Bread", details: "With bananas")
        mockCoreDataManager.createTestTask(id: 3, title: "Cherry Tart")
        mockCoreDataManager.saveContext()

        // Убеждаемся, что все задачи сохранены
        #expect(mockCoreDataManager.fetchTasks().count == 3)

        let searchQuery = "banana"

        // Вызываем метод поиска
        interactor.searchTasks(with: searchQuery)

        // Даем время асинхронной операции Core Data выполниться
        try await Task.sleep(nanoseconds: 500_000_000) // Ожидание поиска

        // Проверяем, что презентер получил результаты поиска
        #expect(mockPresenter.didLoadTasksCalled == true)
        #expect(mockPresenter.didLoadTasksTasks?.count == 1)
        #expect(mockPresenter.didLoadTasksTasks?.first?.title == "Banana Bread")
        #expect(mockPresenter.didFailToLoadTasksCalled == false)
    }

    @Test func testSearchTasks_WithoutQuery() async throws {
        let mockApiService = MockToDoAPIService()
        let mockCoreDataManager = MockCoreDataManager()
        let mockPresenter = MockToDoInteractorOutput()
        let interactor = ToDoInteractor(apiService: mockApiService, coreDataManager: mockCoreDataManager)
        interactor.presenter = mockPresenter

        // Создаем тестовые данные
        mockCoreDataManager.createTestTask(id: 1, title: "Task 1")
        mockCoreDataManager.createTestTask(id: 2, title: "Task 2")
        mockCoreDataManager.saveContext()

        // Убеждаемся, что все задачи сохранены
        #expect(mockCoreDataManager.fetchTasks().count == 2)

        let searchQuery = ""

        // Вызываем метод поиска с пустой строкой
        interactor.searchTasks(with: searchQuery)

        // Даем время асинхронной операции Core Data выполниться
        try await Task.sleep(nanoseconds: 500_000_000) // Ожидание поиска

        // Проверяем, что презентер получил все задачи
        #expect(mockPresenter.didLoadTasksCalled == true)
        #expect(mockPresenter.didLoadTasksTasks?.count == 2)
        #expect(mockPresenter.didFailToLoadTasksCalled == false)
    }

    @Test func testUpdateTaskStatus_WhenCoreDataUpdateFails() async throws {
        let mockApiService = MockToDoAPIService()
        let mockCoreDataManager = MockCoreDataManager()
        let mockPresenter = MockToDoInteractorOutput()
        let interactor = ToDoInteractor(apiService: mockApiService, coreDataManager: mockCoreDataManager)
        interactor.presenter = mockPresenter

        // Создаем тестовую задачу
        let task = mockCoreDataManager.createTestTask(id: 1, title: "Тестовая задача", isCompleted: false)
        mockCoreDataManager.saveContext()

        // Симулируем ошибку обновления
        mockCoreDataManager.shouldSimulateUpdateError = true

        interactor.updateTaskStatus(task: task, isCompleted: true)

        // Даем время асинхронной операции выполниться
        try await Task.sleep(nanoseconds: 500_000_000)

        // Проверяем, что задача не была обновлена
        let updatedTasks = mockCoreDataManager.fetchTasks()
        #expect(updatedTasks.count == 1)
        #expect(updatedTasks.first?.isCompleted == false)
    }

    @Test func testDeleteTask_WhenCoreDataDeleteFails() async throws {
        let mockApiService = MockToDoAPIService()
        let mockCoreDataManager = MockCoreDataManager()
        let mockPresenter = MockToDoInteractorOutput()
        let interactor = ToDoInteractor(apiService: mockApiService, coreDataManager: mockCoreDataManager)
        interactor.presenter = mockPresenter

        // Создаем тестовую задачу
        let task = mockCoreDataManager.createTestTask(id: 1, title: "Тестовая задача")
        mockCoreDataManager.saveContext()

        // Симулируем ошибку удаления
        mockCoreDataManager.shouldSimulateDeleteError = true

        interactor.deleteTask(task: task)

        // Даем время асинхронной операции выполниться
        try await Task.sleep(nanoseconds: 500_000_000)

        // Проверяем, что задача не была удалена
        let remainingTasks = mockCoreDataManager.fetchTasks()
        #expect(remainingTasks.count == 1)
        #expect(remainingTasks.first?.id == 1)
    }

    @Test func testSearchTasks_WhenCoreDataSearchFails() async throws {
        let mockApiService = MockToDoAPIService()
        let mockCoreDataManager = MockCoreDataManager()
        let mockPresenter = MockToDoInteractorOutput()
        let interactor = ToDoInteractor(apiService: mockApiService, coreDataManager: mockCoreDataManager)
        interactor.presenter = mockPresenter

        // Создаем тестовые задачи
        mockCoreDataManager.createTestTask(id: 1, title: "Первая задача")
        mockCoreDataManager.createTestTask(id: 2, title: "Вторая задача")
        mockCoreDataManager.saveContext()

        // Симулируем ошибку поиска
        mockCoreDataManager.shouldSimulateSearchError = true

        interactor.searchTasks(with: "задача")

        // Даем время асинхронной операции выполниться
        try await Task.sleep(nanoseconds: 500_000_000)

        // Проверяем, что презентер получил ошибку
        #expect(mockPresenter.didFailToLoadTasksCalled == true)
        #expect(mockPresenter.didFailToLoadTasksError != nil)
    }

    @Test func testLoadTasks_WhenCoreDataFetchFails() async throws {
        let mockApiService = MockToDoAPIService()
        let mockCoreDataManager = MockCoreDataManager()
        let mockPresenter = MockToDoInteractorOutput()
        let interactor = ToDoInteractor(apiService: mockApiService, coreDataManager: mockCoreDataManager)
        interactor.presenter = mockPresenter

        // Симулируем ошибку получения данных
        mockCoreDataManager.shouldSimulateFetchError = true

        interactor.loadTasks()

        // Даем время асинхронной операции выполниться
        try await Task.sleep(nanoseconds: 500_000_000)

        // Проверяем, что презентер получил ошибку
        #expect(mockPresenter.didFailToLoadTasksCalled == true)
        #expect(mockPresenter.didFailToLoadTasksError != nil)
    }

    // TODO: Добавить тесты для обработки ошибок CoreData в AddTaskInteractor
    // TODO: Добавить тесты для обработки ошибок CoreData в ToDoInteractor (save, update, delete, search)
}

// MARK: - AddTaskInteractor Tests

struct AddTaskInteractorTests {

    @Test func testSaveTask_AddNewTaskSuccessfully() async throws {
        let mockCoreDataManager = MockCoreDataManager()
        let mockPresenter = MockAddTaskInteractorOutput()
        let interactor = AddTaskInteractor(coreDataManager: mockCoreDataManager)
        interactor.presenter = mockPresenter

        let testTitle = "Новая тестовая задача"
        let testDetails: String? = "Детали новой задачи"

        interactor.saveTask(title: testTitle, details: testDetails, taskToEdit: nil)

        // Даем время асинхронной операции Core Data выполниться
        try await Task.sleep(nanoseconds: 500_000_000) // Ожидание сохранения

        // Проверяем, что презентер получил сигнал об успешном сохранении
        #expect(mockPresenter.didSaveTaskSuccessfullyCalled == true)
        #expect(mockPresenter.didFailToSaveTaskCalled == false)

        // Проверяем, что задача была сохранена в CoreData
        let savedTasks = mockCoreDataManager.fetchTasks()
        #expect(savedTasks.count == 1)
        let savedTask = savedTasks.first
        #expect(savedTask?.title == testTitle)
        #expect(savedTask?.details == testDetails)
        #expect(savedTask?.isCompleted == false)
        #expect(savedTask?.creationDate != nil)
         // ID будет сгенерирован автоматически, сложно предсказать его точное значение, кроме что он не 0
        #expect(savedTask?.id != 0)
    }

    @Test func testSaveTask_AddNewTaskWithEmptyTitleFails() async throws {
        let mockCoreDataManager = MockCoreDataManager()
        let mockPresenter = MockAddTaskInteractorOutput()
        let interactor = AddTaskInteractor(coreDataManager: mockCoreDataManager)
        interactor.presenter = mockPresenter

        let testTitle = ""
        let testDetails: String? = "Детали без названия"

        // В AddTaskPresenter уже есть проверка на пустой тайтл, но Interactor должен быть устойчив
        // В текущей реализации Interactor не проверяет пустой тайтл, эту проверку делает Presenter
        // Этот тест, скорее, проверяет, что Interactor не крашится и не сохраняет некорректные данные
        // (хотя сохранение с пустым тайтлом возможно с точки зрения Core Data)

        interactor.saveTask(title: testTitle, details: testDetails, taskToEdit: nil)

         // Даем время асинхронной операции Core Data выполниться
        try await Task.sleep(nanoseconds: 500_000_000) // Ожидание сохранения

        // Презентер не должен получать вызов success или failure в данном случае,
        // так как проверка на пустой тайтл происходит в Presenter до вызова Interactor.
        // Однако, если бы Interactor сам делал эту проверку, мы бы ожидали didFailToSaveTask.
        // В рамках текущей архитектуры этот тест скорее документация поведения.

        // Проверяем, что задача НЕ была сохранена в CoreData (если Presenter работает корректно)
        // Если этот тест пройдет, значит, Presenter не вызвал Interactor с пустым тайтлом.
        // Если Interactor был вызван с пустым тайтлом, CoreData сохранит объект с пустым тайтлом.
        // Для полноценного тестирования логики валидации пустых полей, ее нужно перенести в Interactor.

        // Проверим на всякий случай, что ничего не сохранилось (ожидая, что Presenter заблокировал сохранение) - зависит от того, как будет реализован Presenter
         let savedTasks = mockCoreDataManager.fetchTasks()
         #expect(savedTasks.isEmpty)
         #expect(mockPresenter.didSaveTaskSuccessfullyCalled == false)
         #expect(mockPresenter.didFailToSaveTaskCalled == false) // Ожидаем, что Presenter не вызвал saveTask
    }

    @Test func testSaveTask_EditExistingTaskSuccessfully() async throws {
        let mockCoreDataManager = MockCoreDataManager()
        let mockPresenter = MockAddTaskInteractorOutput()
        let interactor = AddTaskInteractor(coreDataManager: mockCoreDataManager)
        interactor.presenter = mockPresenter

        // Создаем и сохраняем тестовую задачу для редактирования
        let initialTask = mockCoreDataManager.createTestTask(id: 999, title: "Исходная задача", details: "Исходные детали", isCompleted: false)
        mockCoreDataManager.saveContext() // Сохраняем исходную задачу

        // Убеждаемся, что исходная задача существует
        let tasksBeforeEdit = mockCoreDataManager.fetchTasks()
        #expect(tasksBeforeEdit.count == 1)
        let taskToEdit = tasksBeforeEdit.first!
        #expect(taskToEdit.id == 999)

        let updatedTitle = "Отредактированная задача"
        let updatedDetails: String? = "Обновленные детали"

        // Вызываем saveTask для редактирования
        interactor.saveTask(title: updatedTitle, details: updatedDetails, taskToEdit: taskToEdit)

        // Даем время асинхронной операции Core Data выполниться
        try await Task.sleep(nanoseconds: 500_000_000) // Ожидание сохранения

        // Проверяем, что презентер получил сигнал об успешном сохранении
        #expect(mockPresenter.didSaveTaskSuccessfullyCalled == true)
        #expect(mockPresenter.didFailToSaveTaskCalled == false)

        // Проверяем, что задача была обновлена в CoreData
        let tasksAfterEdit = mockCoreDataManager.fetchTasks()
        #expect(tasksAfterEdit.count == 1) // Количество задач не должно измениться
        let editedTask = tasksAfterEdit.first!

        #expect(editedTask.id == 999) // ID должен остаться прежним
        #expect(editedTask.title == updatedTitle)
        #expect(editedTask.details == updatedDetails)
        #expect(editedTask.isCompleted == false) // isCompleted не должен измениться при редактировании названия/деталей
        #expect(editedTask.creationDate != nil) // creationDate не должен измениться
    }

     @Test func testSaveTask_EditExistingTaskWithEmptyTitleFails() async throws {
         let mockCoreDataManager = MockCoreDataManager()
         let mockPresenter = MockAddTaskInteractorOutput()
         let interactor = AddTaskInteractor(coreDataManager: mockCoreDataManager)
         interactor.presenter = mockPresenter

         // Создаем и сохраняем тестовую задачу для редактирования
         let initialTask = mockCoreDataManager.createTestTask(id: 998, title: "Исходная задача для редактирования", details: nil, isCompleted: false)
         mockCoreDataManager.saveContext() // Сохраняем исходную задачу

         // Убеждаемся, что исходная задача существует
         let tasksBeforeEdit = mockCoreDataManager.fetchTasks()
         #expect(tasksBeforeEdit.count == 1)
         let taskToEdit = tasksBeforeEdit.first!
         #expect(taskToEdit.id == 998)

         let updatedTitle = ""
         let updatedDetails: String? = "Детали с пустым названием при редактировании"

         // В AddTaskPresenter уже есть проверка на пустой тайтл, аналогично добавлению
         // Этот тест проверяет поведение Interactor'а, если бы он был вызван с пустым тайтлом

         interactor.saveTask(title: updatedTitle, details: updatedDetails, taskToEdit: taskToEdit)

          // Даем время асинхронной операции Core Data выполниться
         try await Task.sleep(nanoseconds: 500_000_000) // Ожидание сохранения

         // Проверяем, что задача НЕ была изменена в CoreData (если Presenter работает корректно)
         // И что презентер не получил success или failure (если Presenter заблокировал вызов Interactor)

          let tasksAfterEdit = mockCoreDataManager.fetchTasks()
          #expect(tasksAfterEdit.count == 1)
          let taskAfterAttempt = tasksAfterEdit.first!

          #expect(taskAfterAttempt.id == 998)
          #expect(taskAfterAttempt.title == "Исходная задача для редактирования") // Ожидаем, что название не изменилось
          #expect(taskAfterAttempt.details == nil) // Ожидаем, что детали не изменились

          #expect(mockPresenter.didSaveTaskSuccessfullyCalled == false)
          #expect(mockPresenter.didFailToSaveTaskCalled == false)
     }

    @Test func testSaveTask_WhenCoreDataSaveFails() async throws {
        let mockCoreDataManager = MockCoreDataManager()
        let mockPresenter = MockAddTaskInteractorOutput()
        let interactor = AddTaskInteractor(coreDataManager: mockCoreDataManager)
        interactor.presenter = mockPresenter

        // Симулируем ошибку сохранения в CoreData
        mockCoreDataManager.shouldSimulateSaveError = true

        let testTitle = "Тестовая задача"
        let testDetails = "Детали задачи"

        interactor.saveTask(title: testTitle, details: testDetails, taskToEdit: nil)

        // Даем время асинхронной операции выполниться
        try await Task.sleep(nanoseconds: 500_000_000)

        // Проверяем, что презентер получил ошибку
        #expect(mockPresenter.didFailToSaveTaskCalled == true)
        #expect(mockPresenter.didSaveTaskSuccessfullyCalled == false)
        #expect(mockPresenter.didFailToSaveTaskError != nil)

        // Проверяем, что задача не была сохранена
        let savedTasks = mockCoreDataManager.fetchTasks()
        #expect(savedTasks.isEmpty)
    }

    @Test func testSaveTask_WhenCoreDataUpdateFails() async throws {
        let mockCoreDataManager = MockCoreDataManager()
        let mockPresenter = MockAddTaskInteractorOutput()
        let interactor = AddTaskInteractor(coreDataManager: mockCoreDataManager)
        interactor.presenter = mockPresenter

        // Создаем тестовую задачу для редактирования
        let initialTask = mockCoreDataManager.createTestTask(id: 1, title: "Исходная задача")
        mockCoreDataManager.saveContext()

        // Симулируем ошибку обновления в CoreData
        mockCoreDataManager.shouldSimulateUpdateError = true

        let updatedTitle = "Обновленная задача"
        let updatedDetails = "Новые детали"

        interactor.saveTask(title: updatedTitle, details: updatedDetails, taskToEdit: initialTask)

        // Даем время асинхронной операции выполниться
        try await Task.sleep(nanoseconds: 500_000_000)

        // Проверяем, что презентер получил ошибку
        #expect(mockPresenter.didFailToSaveTaskCalled == true)
        #expect(mockPresenter.didSaveTaskSuccessfullyCalled == false)
        #expect(mockPresenter.didFailToSaveTaskError != nil)

        // Проверяем, что задача не была обновлена
        let updatedTasks = mockCoreDataManager.fetchTasks()
        #expect(updatedTasks.count == 1)
        #expect(updatedTasks.first?.title == "Исходная задача")
    }

    // TODO: Добавить тесты для обработки ошибок CoreData в AddTaskInteractor
    // TODO: Добавить тесты для других методов ToDoInteractor (update, delete, search)
}
