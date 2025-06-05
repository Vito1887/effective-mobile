import UIKit
import CoreData // Добавляем импорт CoreData

// Импортируем протоколы из ToDoProtocols.swift и AddTaskProtocols.swift
// MARK: - Protocols are defined in ToDoProtocols.swift and AddTaskProtocols.swift

// MARK: - Module Builder Class
class ToDoModuleBuilder: ToDoModuleBuilderProtocol {

    // Убедитесь, что метод принимает CoreDataManager
    static func buildToDoModule(coreDataManager: CoreDataManager) -> UIViewController {
        // Создаем экземпляры всех компонентов
        let view = ToDoViewController()
        let apiService = NetworkService() // Создаем NetworkService здесь

        // Передаем apiService и coreDataManager в Interactor
        let interactor = ToDoInteractor(apiService: apiService, coreDataManager: coreDataManager)
        let presenter = ToDoPresenter()

        // Создаем Router, передавая ему coreDataManager
        let router = ToDoRouter(coreDataManager: coreDataManager)

        // Связываем компоненты
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter
        router.viewController = view // Роутеру нужна ссылка на View Controller для навигации

        // Возвращаем View Controller в качестве входной точки модуля
        return view
    }
}
