import UIKit
import CoreData

class ToDoModuleBuilder: ToDoModuleBuilderProtocol {

    static func buildToDoModule(coreDataManager: CoreDataManager) -> UIViewController {
        let view = ToDoViewController()
        let apiService = NetworkService()

        let interactor = ToDoInteractor(apiService: apiService, coreDataManager: coreDataManager)
        let presenter = ToDoPresenter()

        let router = ToDoRouter(coreDataManager: coreDataManager)

        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter
        router.viewController = view

        return view
    }
}
