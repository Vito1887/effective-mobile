import UIKit
import Foundation
import CoreData

class AddTaskModuleBuilder: AddTaskModuleBuilderProtocol {

    static func buildAddTaskModule(coreDataManager: CoreDataManager) -> UIViewController {
        let view = AddTaskViewController()

        let interactor = AddTaskInteractor(coreDataManager: coreDataManager)
        let presenter = AddTaskPresenter()
        let router = AddTaskRouter()

        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter
        router.viewController = view

        return view
    }
}
