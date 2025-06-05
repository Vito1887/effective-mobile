import UIKit
import Foundation
import CoreData // Добавляем импорт CoreData

// Импортируем протоколы из AddTaskProtocols.swift
// MARK: - Protocols are defined in AddTaskProtocols.swift

// MARK: - Module Builder Class
class AddTaskModuleBuilder: AddTaskModuleBuilderProtocol {

    // Убедитесь, что метод принимает CoreDataManager
    static func buildAddTaskModule(coreDataManager: CoreDataManager) -> UIViewController {
        let view = AddTaskViewController()
        // Передаем coreDataManager в Interactor
        let interactor = AddTaskInteractor(coreDataManager: coreDataManager)
        let presenter = AddTaskPresenter()
        let router = AddTaskRouter()

        // Связываем компоненты
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter
        router.viewController = view // Роутеру нужна ссылка на View Controller для навигации

        // Возвращаем View Controller
        return view
    }
}
